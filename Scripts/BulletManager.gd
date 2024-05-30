extends Node2D



func handle_bullet_spawned(bullet: Bullet, team: int, pos: Vector2, direction: Vector2):
	# add the bullet as a child of the manager
	add_child(bullet)
	bullet.global_position = pos
	bullet.set_direction(direction)
	bullet.team = team
