extends Node

@export var Player: PackedScene
@export var Door: PackedScene
@export var player_spawn: Vector2 = Vector2(0, 0)
@export var player_speed: float = 250.0
@export var gravity: float = 1.0
@export var gravity_mod: float = 1.0
@export var ice_friction: float = 0.1
@export var door_position: Vector2 = Vector2(0, 0)
@export var enable_inverted_gravity: bool = false
@export var enable_laser:bool = false

var current_player: CharacterBody2D = null
var level_bounds := Rect2()

func _ready() -> void:
	initialize_level()

func initialize_level():
	# Spawn the player
	if Player:
		var new_player = Player.instantiate()
		get_tree().current_scene.add_child(new_player)
		current_player = new_player
		new_player.position = player_spawn
		new_player.set_speed(player_speed);
		new_player.set_room_gravity(gravity)
		new_player.set_gravity_modifier(gravity_mod)
		new_player.can_invert_gravity = enable_inverted_gravity
		new_player.ice_friction = ice_friction
		setup_laser_functionality()

	# Spawn the door
	if Door:
		var new_door = Door.instantiate()
		get_tree().current_scene.add_child(new_door)
		new_door.position = door_position
		new_door.z_index = 10
		new_door.z_as_relative = false
		
	# Reset time scale to default
	Engine.time_scale = 1

# Add a method to toggle gravity inversion at runtime if needed
func toggle_gravity_inversion(can_invert: bool) -> void:
	if current_player:
		current_player.can_invert_gravity = can_invert

# Add this function to your room_manager.gd script
func setup_laser_functionality() -> void:
	if current_player and enable_laser:
		# Enable the laser component if it exists
		var laser = current_player.find_child("LaserBeam2D", true, false)
		if laser:
			laser.set_process_unhandled_input(true)
		else:
			print("Warning: LaserBeam2D node not found on player")
	else:
		# Disable the laser functionality
		var laser = current_player.find_child("LaserBeam2D", true, false)
		if laser:
			laser.set_process_unhandled_input(false)
