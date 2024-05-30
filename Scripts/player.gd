extends CharacterBody2D
class_name Player


signal player_health_changed(new_health)
signal player_died


const SPEED = 140.0


@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var health_stat = $Health
@onready var team = $Team
@onready var camera_transform = $CameraTransform
#@onready var weapon = $Weapon
@onready var weapon_manager = $WeaponManager


var weapon = null

########################
###  MAIN FUNCTIONS  ###
########################

func _ready():
	weapon_manager.initialize(team.team)
	weapon = weapon_manager.get_current_weapon()


func _physics_process(_delta):
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var mouse_pos = get_global_mouse_position()
	
	# NOTE: no delta in velocity calculation bc move_and_slide() applies it
	# FIXME: normalize here? cant tell if diagonals are faster or not...
	velocity = input_direction * SPEED
	
	move_and_slide()
	handle_animations(velocity, mouse_pos)


########################
### HELPER FUNCTIONS ###
########################

func handle_animations(curr_velocity, mouse_pos):
	# play idle or run animations
	if curr_velocity != Vector2.ZERO:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	# flip player sprite based on mouse position
	if mouse_pos.x > position.x:
		animated_sprite_2d.flip_h = false
	elif mouse_pos.x < position.x:
		animated_sprite_2d.flip_h = true
	
	# handle weapon positioning
	weapon.look_at(mouse_pos)
	
	if mouse_pos.x > weapon.global_position.x:
		weapon.animated_sprite_2d.flip_v = false
		weapon.fire_point.position.y = -6
		weapon.gun_direction.position.y = -6
		weapon.muzzle_flash.position.y = -6
	elif mouse_pos.x < global_position.x:
		weapon.animated_sprite_2d.flip_v = true
		weapon.fire_point.position.y = 6
		weapon.gun_direction.position.y = 6
		weapon.muzzle_flash.position.y = 6


func get_team() -> int:
	return team.team


func handle_hit():
	health_stat.health -= 20
	player_health_changed.emit(health_stat.health)
	
	if health_stat.health == 0:
		die()


func die():
	player_died.emit()
	queue_free()


func set_camera_transform(camera_path: NodePath):
	camera_transform.remote_path = camera_path
