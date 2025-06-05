extends Control

@onready var restart_button = $VBoxContainer/RestartButton
@onready var main_menu_button = $VBoxContainer/MainMenuButton

func _ready():
	restart_button.connect("pressed", _on_restart_pressed)
	main_menu_button.connect("pressed", _on_main_menu_pressed)

func _on_restart_pressed():
	# Reset the player lives in the game manager
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.reset_player_lives()
	
	# Go back to the current level
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")  # Adjust path to your first level

func _on_main_menu_pressed():
	# Reset the player lives in the game manager
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.reset_player_lives()
	
	# Go to main menu
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")  # Adjust path to your main menu
