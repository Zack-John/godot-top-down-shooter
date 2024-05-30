extends Area2D

class_name Bullet


@export var speed = 6

@onready var kill_timer = $KillTimer


var direction = Vector2.ZERO
var team: int = -1

func _ready():
	kill_timer.start()
	

func _physics_process(_delta):
	# NOTE: area2Ds dont expose kinematic fxns like move_and_slide(), etc
	# so we have to do it ourselves:
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		global_position += velocity


func set_direction(dir: Vector2):
	# 'self' here lets us use the same argument name as our variable
	# self.direction = direction
	direction = dir
	rotation += direction.angle() # add angle to our bullet to face the correct direction


func _on_kill_timer_timeout():
	queue_free()


func _on_body_entered(body: Node):
	# example of 'duck typing' (ep 6)
	if body.has_method("handle_hit"):
		if body.has_method("get_team") and body.get_team() != team:
			body.handle_hit()
		queue_free()
	#else:
		#print("no handle_hit method in body!")
		#queue_free()
