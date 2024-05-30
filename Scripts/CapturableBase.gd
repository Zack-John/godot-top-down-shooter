extends Area2D
class_name CapturableBase


signal base_captured(new_team)


@export var neutral_color = Color(1, 1, 1)
@export var player_color = Color(0, 0.852, 0.085)
@export var enemy_color = Color(0.977, 0.027, 0.027)

@onready var team = $Team
@onready var capture_timer = $CaptureTimer
@onready var sprite_2d = $Sprite2D


var player_unit_count: int = 0
var enemy_unit_count: int = 0
var team_to_capture: int = Team.TeamName.NEUTRAL


func _on_body_entered(body):
	# more duck typing
	if body.has_method("get_team"):
		var team = body.get_team()
		
		if team == Team.TeamName.ENEMY: # can reference enums from other scripts!
			enemy_unit_count += 1
		elif team == Team.TeamName.PLAYER: # can reference enums from other scripts!
			player_unit_count += 1
		
		check_if_base_can_be_captured()

func _on_body_exited(body):
	# more duck typing
	if body.has_method("get_team"):
		var team = body.get_team()
		
		if team == Team.TeamName.ENEMY: # can reference enums from other scripts!
			enemy_unit_count -= 1
		elif team == Team.TeamName.PLAYER: # can reference enums from other scripts!
			player_unit_count -= 1
	
		check_if_base_can_be_captured()


func check_if_base_can_be_captured():
	var majority_team = get_team_with_majority()
	
	if player_unit_count == 0 and enemy_unit_count == 0:
		print("nobody on the base, stopping timer!")
		majority_team = Team.TeamName.NEUTRAL
		team_to_capture = Team.TeamName.NEUTRAL
		capture_timer.stop()
		
	# if there is no majority team...
	if majority_team == Team.TeamName.NEUTRAL:
		return
	
	# if majority is the team that currently owns the base...
	elif majority_team == team.team:
		print("owning team regained majority, stopping capture countdown!")
		team_to_capture = Team.TeamName.NEUTRAL # prob dont need this, but might as well be explicit
		capture_timer.stop()
	
	else:
		# check if this is already the majority so we dont reset the clock
		if team_to_capture == majority_team:
			print("this team is already the majority team")
			return
			
		print("new team has majority, starting capture countdown!")
		team_to_capture = majority_team
		capture_timer.start()


func get_team_with_majority() -> int:
	if enemy_unit_count == player_unit_count:
		return Team.TeamName.NEUTRAL

	elif enemy_unit_count > player_unit_count:
		return Team.TeamName.ENEMY

	else:
		return Team.TeamName.PLAYER


func set_team(new_team: int):
	team.team = new_team
	#emit_signal("base_captured", new_team)
	base_captured.emit(new_team)
	
	match new_team:
		Team.TeamName.NEUTRAL:
			sprite_2d.modulate = neutral_color
		Team.TeamName.ENEMY:
			sprite_2d.modulate = enemy_color
		Team.TeamName.PLAYER:
			sprite_2d.modulate = player_color


func _on_capture_timer_timeout():
	set_team(team_to_capture)
