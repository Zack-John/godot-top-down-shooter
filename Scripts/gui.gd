extends CanvasLayer


@onready var health_bar = $MarginContainer/Rows/TopRow/HealthBar
@onready var current_ammo = $MarginContainer/Rows/BottomRow/AmmoSection/CurrentAmmo
@onready var max_ammo = $MarginContainer/Rows/BottomRow/AmmoSection/MaxAmmo


var player: Player = null


func set_weapon(weapon):
	set_current_ammo(player.weapon.current_ammo)
	set_max_ammo(player.weapon.max_ammo)
	weapon.connect("weapon_fired", set_current_ammo)


func set_player(_player: Player):
	player = _player
	
	set_new_health_value(player.health_stat.health)
	player.connect("player_health_changed", set_new_health_value)
	
	set_weapon(player.weapon_manager.get_current_weapon())


func set_new_health_value(new_health: int):
	var bar_style = health_bar.get("theme_override_styles/fill")
	var original_color = Color("#8b0804")
	var highlight_color = Color("#ff7e7e")
	
	# this could use some tuning, doesnt look great atm
	var health_tween = create_tween()
	health_tween.tween_property(health_bar, "value", new_health, 0.4).set_ease(Tween.EASE_IN).set_delay(Tween.TRANS_LINEAR)
	health_tween.tween_property(bar_style, "bg_color", highlight_color, 0.2).set_ease(Tween.EASE_IN).set_delay(Tween.TRANS_LINEAR)
	health_tween.tween_property(bar_style, "bg_color", original_color, 0.2).set_ease(Tween.EASE_OUT).set_delay(Tween.TRANS_LINEAR)

	#health_bar.value = new_health

func set_current_ammo(new_ammo: int):
	current_ammo.text = str(new_ammo)


func set_max_ammo(new_max_ammo: int):
	max_ammo.text = str(new_max_ammo)
