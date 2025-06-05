extends Area2D

signal door_opened
signal level_completed

@export var is_locked: bool = false
@export var next_level_path: String = ""  # Optional explicit path override
@onready var sprite: Sprite2D = $DoorAsset
@onready var collision_shape: CollisionShape2D = $DoorHitBox

var scoreboard_scene = preload("res://scenes/level_complete_scoreboard.tscn")
var game_manager


const LEVEL_PATH = "res://scenes/levels/level_"

func _ready():
	add_to_group("door")
	# Set the visual state based on lock status
	update_door_visual()
	# start timer
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	game_manager.reset_level()

func update_door_visual():
	if sprite:
		sprite.frame = 0 if is_locked else 1  # Assuming frame 0 is closed, frame 1 is open

func open_door():
	print("open_door() method called!")
	if is_locked:
		print("Door unlocked permanently!")
		is_locked = false
		update_door_visual()
		emit_signal("door_opened")
	else:
		print("Door was already unlocked")

func _on_body_entered(body):
	print("OH YEAH")
	if not is_locked and body.is_in_group("player"):
		# Calculate level statistics
		game_manager = get_tree().get_first_node_in_group("game_manager")
		var level_stats = {
			"level_name": get_level_name(),
			"time": game_manager.level_time if game_manager else 0.0,
			"deaths": game_manager.player_deaths if game_manager else 0,
			"score": game_manager.score if game_manager else 0,
			"stars": calculate_stars(),
			"grade": calculate_grade(),
			"next_level": next_level_path
		}
		game_manager.player_deaths = 0

		# Show scoreboard instead of immediately going to next level
		var scoreboard = scoreboard_scene.instantiate()
		get_tree().root.add_child(scoreboard)
		scoreboard.show_scoreboard(level_stats)
		
		# Level change now happens through the scoreboard buttons
		emit_signal("level_completed")
		
		# Start transition effect if GameHUD exists
		if has_node("/root/GameHUD"):
			get_node("/root/GameHUD").start_level_transition()
		
		# Get current level number
		var current_level = get_tree().current_scene.scene_file_path
		var level_number = 1  # Default to level 1 if we can't extract number
		
		# Update game manager
		game_manager.level_completed(current_level)
		
		# Save the cumulative score after completing the level
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("save_high_score"):
			hud.save_high_score(game_manager.score)

			

func calculate_stars() -> int:
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if not game_manager:
		return 1

	# Star calculation based on time and deaths
	var time = game_manager.level_time
	var deaths = game_manager.player_deaths

	# Customize these thresholds for your game
	if time < 60 and deaths == 0:
		return 3
	elif time < 120 and deaths <= 2:
		return 2
	else:
		return 1

func calculate_grade() -> String:
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if not game_manager:
		return "C"

	# Grade calculation
	var time = game_manager.level_time
	var deaths = game_manager.player_deaths

	# Customize these thresholds for your game
	if time < 45 and deaths == 0:
		return "S"
	elif time < 60 and deaths <= 1:
		return "A"
	elif time < 90 and deaths <= 2:
		return "B"
	elif time < 120 and deaths <= 3:
		return "C"
	else:
		return "D"
		
func get_level_name() -> String:
	var scene_path = get_tree().current_scene.scene_file_path
	var file_name = scene_path.get_file().get_basename()

	# Format the level name to look nice
	var formatted_name = file_name.capitalize()
	formatted_name = formatted_name.replace("_", " ")

	return formatted_name
