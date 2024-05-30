extends Node2D
class_name AI

signal state_changed(new_state)


enum State {
	PATROL,
	ENGAGE,
	ADVANCE
}


@onready var patrol_timer = $PatrolTimer


var speed = 100

# NOTE: eventually will want to pull all of the state specific stuff
# into their own controllers (I think devduck does something like this)

var actor: Actor = null
var weapon: Weapon = null
var target: CharacterBody2D = null
var team: int = -1

var current_state = -1 : set = set_state 

# PATROL STATE
var origin: Vector2 = Vector2.ZERO
var patrol_location: Vector2 = Vector2.ZERO
var patrol_location_reached := false
var actor_velocity: Vector2 = Vector2.ZERO

# ADVANCE STATE
var next_base_location: Vector2 = Vector2.ZERO



func _ready():
	set_state(State.PATROL)


func _physics_process(_delta):
	# NOTE: 'match' is basically a 'switch' statement
	match current_state:
		State.PATROL:
			if not patrol_location_reached:
				actor_velocity = actor.velocity_toward(patrol_location)
				actor.velocity = actor_velocity
				actor.move_and_slide()
				# NOTE: lerp_angle causes shooting issues in engage state, 
				# might have weirdness here too
				actor.aim_toward(patrol_location)
				
				if actor.has_reached_position(patrol_location):
					patrol_location_reached = true
					actor_velocity = Vector2.ZERO
					patrol_timer.start()
		
		State.ENGAGE:
			if target != null and weapon != null:
				actor.aim_toward(target.global_position)
				
				# NOTE: we are dealing with radians, so vals will be small floats
				var angle_to_target = actor.global_position.direction_to(target.global_position).angle()
				
				if abs(weapon.rifle.rotation - angle_to_target) < 0.1:
					weapon.shoot()
			else:
				print("Error: in engage state, but no weapon/target!")
		
		State.ADVANCE:
			if actor.has_reached_position(next_base_location):
				set_state(State.PATROL)
			else:
				actor.velocity = actor.velocity_toward(next_base_location)
				actor.move_and_slide()
				# NOTE: lerp_angle causes shooting issues in engage state, 
				# might have weirdness here too
				actor.aim_toward(patrol_location)
		
		_:
			print("Error: found a state for our enemy that should not exist..?")


# use this fxn to inject dependancies at runtime
# NOTE: we use this fxn that our parent calls because we cant guarantee that
# sibling nodes (like the weapon node) will be ready when we call _ready on this,
# but by the time our parent is ready, all of its children are ready too -- so its
# safe to call an init function like this one in our parent script
func initialize(_actor: CharacterBody2D, _weapon: Weapon, _team: int):
	self.actor = _actor
	self.weapon = _weapon
	self.team = _team
	
	weapon.connect("weapon_out_of_ammo", handle_reload)


func handle_reload():
	weapon.start_reload()


# handle state switching
func set_state(new_state):
	if new_state == current_state:
		return

	if new_state == State.PATROL:
		origin = global_position # NOTE: this sets origin to the AI node position
		patrol_timer.start()
		patrol_location_reached = true # we enter the patrol state when we arrive at the dest
	
	if new_state == State.ADVANCE:
		if actor.has_reached_position(next_base_location):
			set_state(State.PATROL)
		#else:
			#actor_velocity = actor.velocity_toward(next_base_location)
	
	current_state = new_state
	emit_signal("state_changed", current_state)


func _on_patrol_timer_timeout():
	var patrol_range: float = 50
	var random_x = randf_range(-patrol_range, patrol_range)
	var random_y = randf_range(-patrol_range, patrol_range)
	
	# we add the vector2 to our origin because the center of the random range values is 0,
	# but we want the actual new position to be relative to our origin
	patrol_location = Vector2(random_x, random_y) + origin
	patrol_location_reached = false

	#actor_velocity = actor.velocity_toward(patrol_location)


func _on_detection_area_body_entered(body):
	#if body.is_in_group("player"):
	# method checking here is another example of 'duck typing'
	if body.has_method("get_team") and body.get_team() != team:
		current_state = State.ENGAGE
		target = body # get reference to the player


func _on_detection_area_body_exited(body):
	if target and body == target:
		set_state(State.ADVANCE)
		target = null
