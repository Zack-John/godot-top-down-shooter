extends Node


@export var health = 100 :
	set(new_health):
		health = clamp(new_health, 0, 100)
	get:
		return health

#func set_health(new_health):
	#health = clamp(new_health, 0, 100)

