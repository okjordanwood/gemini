extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get reference to game manager
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		# Set sliders to the saved values from the game manager
		$VBoxContainer/MasterVolumeSlider/HSlider.value = game_manager.master_volume_db
		$VBoxContainer/MusicVolumeSlider/HSlider.value = game_manager.music_volume_db
		$VBoxContainer/SfxVolumeSlider/HSlider.value = game_manager.sfx_volume_db
	
	$VBoxContainer/MasterVolumeSlider/HSlider.grab_focus()
	
	 # Connect signals
	$VBoxContainer/MasterVolumeSlider/HSlider.connect("value_changed", Callable(self, "_on_master_volume_slider_value_changed"))
	$VBoxContainer/MusicVolumeSlider/HSlider.connect("value_changed", Callable(self, "_on_music_volume_slider_value_changed"))
	$VBoxContainer/SfxVolumeSlider/HSlider.connect("value_changed", Callable(self, "_on_sfx_volume_slider_value_changed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Handle volume slider changes
func _on_master_volume_slider_value_changed(value: float) -> void:
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.set_master_volume(value)

func _on_music_volume_slider_value_changed(value: float) -> void:
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.set_music_volume(value)

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.set_sfx_volume(value)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/menu.tscn")

func _on_help_button_pressed() -> void:
	print("Help button pressed")
	get_tree().change_scene_to_file("res://scenes/menus/HelpScreen.tscn")

func _on_credits_button_pressed() -> void:
	print("Credits button pressed")
	get_tree().change_scene_to_file("res://scenes/menus/CreditsScreen.tscn")
