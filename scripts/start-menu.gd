extends Control

var game_manager_scene = preload("res://scenes/game_manager.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Start menu initialized!")
	# Instance the game manager if it doesn't exist
	var game_manager
	var existing_managers = get_tree().get_nodes_in_group("game_manager")
	if existing_managers.is_empty():
		game_manager = game_manager_scene.instantiate()
		# Add to root so it persists between scenes
		get_tree().root.call_deferred("add_child", game_manager)
		print("Game manager instantiated at root level")
	else:
		print("Game manager already exists")
		game_manager = get_tree().get_first_node_in_group("game_manager")
	
	$VBoxContainer/StartButton.grab_focus()
	game_manager.player_deaths = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_button_pressed():
	# Make sure game manager exists before starting
	if get_tree().get_nodes_in_group("game_manager").is_empty():
		print("ERROR: Game manager not found before starting game!")
		return
	
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.score = 0
		game_manager.level_score = 0
	
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_LevelSelectButton_pressed():
	
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")


func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/options_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_high_scores_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/high_score_menu.tscn")

func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/TutorialScreen.tscn")
