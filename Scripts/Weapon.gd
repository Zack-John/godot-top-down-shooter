extends Node2D
class_name Weapon


signal weapon_out_of_ammo
signal weapon_fired(new_ammo_count) # used for updating GUI


@export var BulletScene: PackedScene

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var muzzle_flash = $MuzzleFlash
@onready var fire_point = $FirePoint
@onready var gun_direction = $GunDirection
@onready var animation_player = $AnimationPlayer
@onready var attack_cooldown = $AttackCooldown


var team = -1 # used for preventing bullet friendly fire

var max_ammo: int = 10
var current_ammo = max_ammo :
	set(new_ammo):
		current_ammo = clamp(new_ammo, 0, max_ammo)
		if current_ammo == 0:
			print("[ammo setter] current_ammo == 0")
			weapon_out_of_ammo.emit()
		
		print("[ammo setter] shot fired")
		weapon_fired.emit(current_ammo)


func initialize(_team: int):
	self.team = _team


func start_reload():
	animation_player.play("reload")


func _stop_reload():
	print("reload stopping!")
	current_ammo = max_ammo


func shoot():
	if current_ammo != 0 and attack_cooldown.is_stopped():
			var bullet = BulletScene.instantiate() # instantiate the scene IN MEMORY
			var direction = (gun_direction.global_position - fire_point.global_position).normalized()
			
			GlobalSignals.emit_signal("bullet_fired", bullet, team, fire_point.global_position, direction)
			
			attack_cooldown.start()
			animation_player.play("muzzle_flash")
			
			current_ammo -= 1 # this should be calling my set fxn now


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "reload":
		_stop_reload()
