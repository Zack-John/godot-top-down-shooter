extends Node2D


@onready var current_weapon = $Pistol

var weapons: Array = []


func _ready():
	weapons = get_children()


# only gets called when a frame is executed and there is input that hasnt been handled
# called once per 'event'
func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		current_weapon.shoot()
	if event.is_action_pressed("reload"):
		current_weapon.start_reload()


func initialize(team: int):
	for weapon in weapons:
		weapon.initialize(team)


func get_current_weapon():
	return current_weapon


func reload():
	current_weapon.start_reload()
