extends Control

var pause_menu_scene = preload("res://scenes/menus/pause_menu.tscn")
var game_manager

func _ready():
	# Get game manager reference
	var existing_managers = get_tree().get_nodes_in_group("game_manager")
	if !existing_managers.is_empty():
		game_manager = existing_managers[0]
	
	# Initially hide pause menu
	visible = false

func _unhandled_input(event):
	# Check for Esc key press
	if event.is_action_pressed("pause"):
		if not visible:
			# Pause game
			get_tree().paused = true
			visible = true
		else:
			# Resume game
			get_tree().paused = false
			visible = false

func _on_resume_pressed():
	get_tree().paused = false
	visible = false

func _on_restart_pressed():
	# Reset game state
	if game_manager:
		game_manager.score = 0
		game_manager.player_lives = 3
	
	# Reload current scene
	get_tree().reload_current_scene()

func _on_quit_pressed():
	# Return to start menu
	get_tree().change_scene_to_file("res://scenes/menus/start_menu.tscn")
