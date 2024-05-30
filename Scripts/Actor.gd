extends CharacterBody2D
class_name Actor

signal died

@export var speed = 100

@onready var health = $Health
@onready var ai = $AI
@onready var weapon = $Weapon
@onready var team = $Team


func _ready():
	ai.initialize(self, weapon, team.team)
	weapon.initialize(team.team)


func aim_toward(location: Vector2):
	# FIXME:
	# lerp_angle() was causing issues with not shooting at the player after full rotations, around 0/360, etc
	# so right now we have janky rotation, but can be fixed when i implement sprite flipping
	
	# from comments on episode 9, one of these can potentially fix the weirdness with lerp_angle (in AI script)
	#if abs(get_parent().position.angle_to(player.position)) < 0.5:
	#if rad2deg(actor.position.angle_to(player.position)) < 40:
	weapon.rotation = lerp(weapon.rotation, global_position.direction_to(location).angle(), 0.1)
	#weapon.pistol.rotation = lerp(weapon.pistol.rotation, global_position.direction_to(location).angle(), 0.1)


func velocity_toward(location: Vector2) -> Vector2:
	return global_position.direction_to(location) * speed


func has_reached_position(location: Vector2) -> bool:
	return global_position.distance_to(location) < 5

# another example of duck typing (Ep 9)
func get_team() -> int:
	return team.team


func handle_hit():
	health.health -= 30
	print("enemy hit: ", health.health)
	if health.health <= 0:
		died.emit()
		queue_free()

