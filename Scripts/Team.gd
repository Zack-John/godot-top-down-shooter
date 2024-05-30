extends Node2D
class_name Team


enum TeamName {
	NEUTRAL,
	PLAYER,
	ENEMY
 }


#var player_color = Color(0, 0.852, 0.085)
#var enemy_color = Color(0.977, 0.027, 0.027)


@export var team: TeamName = TeamName.NEUTRAL
