extends Node2D


@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var firepoint = $FirePoint
@onready var gun_direction = $GunDirection
@onready var muzzle_flash = $MuzzleFlash
@onready var animation_player = $AnimationPlayer


signal rifle_finished_reload


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "reload":
		print("emitting finished reload signal!")
		emit_signal("rifle_finished_reload")
