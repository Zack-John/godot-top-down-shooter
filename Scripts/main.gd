extends Node2D


const PLAYER = preload("res://Scenes/player.tscn")


# NOTE: the dollarsign syntax is shorthand for a NodePath
@onready var bullet_manager = $BulletManager
@onready var capturable_base_manager = $CapturableBaseManager
@onready var ally_map_ai = $AllyMapAI
@onready var enemy_map_ai = $EnemyMapAI
@onready var camera_2d = $Camera2D
@onready var gui = $GUI


func _ready():
	# from docs: "Note: This function is called automatically when the project is run."
	# not sure if i need this call in godot 4...
	randomize()
	
	# connect player_fired_bullet signal to bullet_manager's handle_bullet_spawned() fxn
	GlobalSignals.connect("bullet_fired", Callable(bullet_manager, "handle_bullet_spawned"))
	
	# NOTE: it might be better to do an onready var here, but since we're only using
	# this in one spot, we can just get the nodes in this ready fxn
	var ally_respawns = $AllyRespawnPoints
	var enemy_respawns = $EnemyRespawnPoints
	
	var bases = capturable_base_manager.get_capturable_bases()
	
	ally_map_ai.initialize(bases, ally_respawns.get_children())
	enemy_map_ai.initialize(bases, enemy_respawns.get_children())
	
	spawn_player()


func spawn_player():
	var player = PLAYER.instantiate()
	add_child(player)
	player.set_camera_transform(camera_2d.get_path())
	player.connect("player_died", spawn_player)
	
	gui.set_player(player)
