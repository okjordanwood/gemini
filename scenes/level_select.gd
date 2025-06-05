extends Control

@onready var button_grid = $VBoxContainer/ButtonScroll/CenterContainer/ButtonGridWrapper/ButtonGrid
const TOTAL_LEVELS := 8
const LEVEL_BUTTON_SCENE := preload("res://scenes/level_select_button.tscn")

func _ready():
	
	if get_tree().get_current_scene().has_node("/root/GameHud"):
		get_node("/root/GameHud").visible = false
	# Making sure that user can access levels that are already completed
	for i in range(1, TOTAL_LEVELS + 1):
		var button = LEVEL_BUTTON_SCENE.instantiate()
		button.level_number = i

		var game_manager = get_tree().get_first_node_in_group("game_manager")
		var unlocked_level = game_manager.highest_level_completed + 1
		
		button.disabled = i > unlocked_level

		button_grid.add_child(button)
		
		if i == unlocked_level:
			button.grab_focus()
			
		var completed_levels = game_manager.highest_level_completed
		var total_levels = TOTAL_LEVELS
		var progress_percent = round(float(completed_levels) / total_levels * 100.0)

		$LevelProgressBar.value = progress_percent
	

func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/menu.tscn")
	
