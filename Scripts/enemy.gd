extends CharacterBody2D

const SPEED = 50

var health = 100

# TODO: implement a more dynamic solution (apparently provided later in GDQuest top-down tutorial)
@onready var player = get_node("/root/Main/Player")

func _ready():
	pass

func _physics_process(delta):
	var move_direction: Vector2 = global_position.direction_to(player.global_position)
	velocity = move_direction * SPEED
	move_and_slide()


func handle_hit():
	health -= 20
	if health <= 0:
		queue_free()
