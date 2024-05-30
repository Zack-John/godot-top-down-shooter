extends Node2D


enum BaseCaptureStartOrder {
	FIRST,
	LAST
}

@export var base_capture_start_order: BaseCaptureStartOrder
@export var team_name : Team.TeamName = Team.TeamName.NEUTRAL
@export var unit : PackedScene = null
@export var max_units_alive: int = 4

@onready var team = $Team
@onready var unit_container = $UnitContainer
@onready var respawn_timer = $RespawnTimer

var target_base: CapturableBase = null
var capturable_bases: Array = []
var respawn_points: Array = []
var next_spawn_to_use: int = 0


func _ready():
	# could move this into initialize() if i wanted to
	team.team = team_name


func initialize(capturable_bases: Array, respawn_points: Array):
	# make sure i didnt forget to init something :V
	if capturable_bases.size() == 0 or respawn_points.size() == 0 or unit == null:
		push_error("You forgot to properly init mapAI!")
		
	self.respawn_points = respawn_points
	for respawn in respawn_points:
		spawn_unit(respawn.global_position)
	
	self.capturable_bases = capturable_bases
	for base in capturable_bases:
		base.connect("base_captured", handle_base_captured)
	
	check_for_next_capturable_base()


# NOTE: 
# - dont really need new_team at the moment, but may need it later
# - this is not terribly performant, but would need a lot of actors and bases to see a problem
func handle_base_captured(_new_team: int):
	check_for_next_capturable_base()


func check_for_next_capturable_base():
	var next_base = get_next_capturable_base()
	if next_base != null:
		target_base = next_base
		assign_next_capturable_base_to_units(next_base)


func get_next_capturable_base():
	# assume base capture start order is FIRST
	var list_of_bases = range(capturable_bases.size())
	
	# if order is LAST, flip array
	if base_capture_start_order == BaseCaptureStartOrder.LAST:
		list_of_bases = range(capturable_bases.size() - 1, -1, -1)
	
	for i in list_of_bases:
		var base: CapturableBase = capturable_bases[i]
		if team.team != base.team.team:
			print("assigning team %d to capture base %d" % [team.team, i])
			return base
			
	return null


func assign_next_capturable_base_to_units(base: CapturableBase):
	# dont know if i need this, but might as well be explicit
	if base == null:
		return
		
	for unit in unit_container.get_children():
		set_unit_to_advance_to_next_base(unit)


func spawn_unit(spawn_location: Vector2):
	var unit_instance = unit.instantiate()
	unit_container.add_child(unit_instance)
	unit_instance.global_position = spawn_location
	unit_instance.connect("died", handle_unit_death)
	set_unit_to_advance_to_next_base(unit_instance)


func set_unit_to_advance_to_next_base(unit: Actor):
	if target_base != null:
		var ai: AI = unit.ai
		ai.next_base_location = target_base.global_position
		ai.set_state(AI.State.ADVANCE)


func handle_unit_death():
	if respawn_timer.is_stopped() and unit_container.get_children().size() < max_units_alive:
		respawn_timer.start()


func _on_spawn_timer_timeout():
	var respawn = respawn_points[next_spawn_to_use]
	spawn_unit(respawn.global_position)
	
	next_spawn_to_use += 1
	if next_spawn_to_use == respawn_points.size():
		next_spawn_to_use = 0
	
	if unit_container.get_children().size() < max_units_alive:
		respawn_timer.start()
