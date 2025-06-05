extends CanvasLayer

# Node references
#@onready var lives_counter = $TopBar/LivesContainer/LivesDisplay/LivesCounter
@onready var score_counter = $TopBar/ScoreContainer/ScoreCounter
@onready var level_name = $TopBar/LevelContainer/LevelName
@onready var game_over_panel = $GameOverPanel
@onready var pause_panel = $PausePanel
@onready var notification_panel = $NotificationPanel
@onready var notification_label = $NotificationPanel/NotificationLabel
@onready var notification_timer = $NotificationTimer
#@onready var heart1 = $TopBar/LivesContainer/LivesDisplay/MarginContainer/Heart1
#@onready var heart2 = $TopBar/LivesContainer/LivesDisplay/MarginContainer/Heart2
#@onready var heart3 = $TopBar/LivesContainer/LivesDisplay/MarginContainer/Heart3
@onready var time_label = $TopBar/TimeContainer/TimeLabel

# Animation references
@onready var transition_rect = $TransitionRect
@onready var collected_item_animation = $CollectedItemAnimation

# Settings
@export var notification_duration: float = 3.0
@export var fade_duration: float = 0.3

# Timer tracking
var level_time := 0.0
var tracking_time := false

# State tracking
var game_paused: bool = false
var current_level_name: String = ""
var is_menu_scene: bool = false
var menu_scene_paths = [
	"res://scenes/menus/start_menu.tscn",
	"res://scenes/menus/options_menu.tscn",
	"res://scenes/menus/high_score_menu.tscn",
	"res://scenes/menus/menu.tscn",
	"res://scenes/menus/level_select.tscn",
	"res://scenes/menus/TutorialScreen.tscn"
]
var last_checked_scene: String = ""

func _enter_tree():
	# Ensure this is added to the HUD group
	add_to_group("hud")

func _ready():
	# Debug print when HUD is initialized
	print("HUD initialized!")

	# Get the style from the existing panel
	var panel_style = $NotificationPanel.get_theme_stylebox("panel")

	# Remove the problematic panel
	$NotificationPanel.queue_free()

	# Create a new notification panel
	var new_panel = PanelContainer.new()
	new_panel.name = "NotificationPanel"
	new_panel.visible = false
	new_panel.custom_minimum_size = Vector2(500, 60)

	# Set panel style
	if panel_style:
		new_panel.add_theme_stylebox_override("panel", panel_style)

	# Set up proper anchors
	new_panel.anchor_left = 0.5
	new_panel.anchor_right = 0.5
	new_panel.anchor_top = 0
	new_panel.anchor_bottom = 0

	# Position it below the top bar
	new_panel.position = Vector2(-250, 56)

	# Create notification label
	var label = Label.new()
	label.name = "NotificationLabel"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = 3 # Assuming 3 is AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 18)
	label.text = "Notification text goes here"

	# Add label to panel
	new_panel.add_child(label)

	# Add panel to HUD
	add_child(new_panel)

	# Update notification panel reference
	notification_panel = new_panel
	notification_label = label
	
	# Check if we're in a menu scene
	var current_scene_path = get_tree().current_scene.scene_file_path
	is_menu_scene = menu_scene_paths.has(current_scene_path)

	# Hide the HUD if we're in a menu scene
	if is_menu_scene:
		$TopBar.visible = false
	else:
		$TopBar.visible = true
		start_timer()

		
	# Initially hide UI elements that should start hidden
	game_over_panel.visible = false
	pause_panel.visible = false
	notification_panel.visible = false
	transition_rect.modulate.a = 0  # Start with transparent transition
	
	# Get the game manager and connect signals
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		# Connect signals from game manager
		game_manager.connect("score_changed", _on_score_changed)
		game_manager.connect("game_over", _on_game_over)
		game_manager.connect("player_died", _on_player_died)
		
		# Initialize UI with current values
		_on_score_changed(game_manager.score)
	else:
		push_error("No game_manager found! HUD will not function correctly.")
	
	# Set the level name
	update_level_name()
	
	# Make the notification manager use our show_notification function
	if has_node("/root/NotificationManager"):
		var notification_manager = get_node("/root/NotificationManager")
		notification_manager.register_hud(self)
		

func _process(delta):
	# Check if the scene has changed
	if get_tree().current_scene and get_tree().current_scene.scene_file_path != last_checked_scene:
		var current_scene_path = get_tree().current_scene.scene_file_path
		last_checked_scene = current_scene_path

		# Check if we're in a menu scene
		is_menu_scene = menu_scene_paths.has(current_scene_path)

		# Update visibility based on scene type
		if is_menu_scene:
			$TopBar.visible = false
		else:
			$TopBar.visible = true
			start_timer()

			# If coming back to a game scene, make sure we have updated data
			var game_manager = get_tree().get_first_node_in_group("game_manager")
			if game_manager:
				_on_score_changed(game_manager.score)
				update_level_name()
				
	# Always track time when not in a menu scene
	if not is_menu_scene and tracking_time and not get_tree().paused:
		level_time += delta
		time_label.text = "                                     Time: %.1fs" % level_time


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if is_menu_scene:
			return  # Do nothing if we are in a menu scene
		toggle_pause()


func update_level_name():
	# Get current scene path and extract level name
	var scene_path = get_tree().current_scene.scene_file_path
	var level_filename = scene_path.get_file().get_basename()
	
	# Format the level name to look nice
	var formatted_name = level_filename.capitalize()
	formatted_name = formatted_name.replace("_", " ")
	
	# Update the label
	level_name.text = formatted_name
	current_level_name = formatted_name

func _on_score_changed(new_score: int):
	score_counter.text = str(new_score)
	
	# Add a brief animation to the score counter
	var tween = create_tween()
	tween.tween_property(score_counter, "modulate", Color(0.5, 1, 0.5, 1), 0.2)
	tween.tween_property(score_counter, "modulate", Color(1, 1, 1, 1), 0.2)

func _on_player_died():
	# Create a brief screen flash effect when player dies
	transition_rect.modulate.a = 0.5
	var tween = create_tween()
	tween.tween_property(transition_rect, "modulate:a", 0.0, 0.5)

func _on_game_over():
	stop_timer()
	# Hide the timer UI label
	time_label.visible = false

	# Save the player's total score
	if get_tree().has_group("game_manager"):
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		save_high_score(game_manager.score)

	# Hide the timer UI label
	time_label.visible = false

	# Show the game over panel with animation
	game_over_panel.modulate.a = 0
	game_over_panel.visible = true
	
	var tween = create_tween()
	tween.tween_property(game_over_panel, "modulate:a", 1.0, fade_duration)


func toggle_pause():
	game_paused = !game_paused
	get_tree().paused = game_paused
	pause_panel.visible = game_paused
	
	if game_paused:
		# Fade in pause panel
		pause_panel.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(pause_panel, "modulate:a", 1.0, fade_duration)
	
func show_notification(message: String, duration: float = 3.0):
	# Stop any existing timer
	if !notification_timer.is_stopped():
		notification_timer.stop()
	
	# Set the message text
	notification_label.text = message
	
	# Show notification panel
	notification_panel.modulate.a = 0
	notification_panel.visible = true
	
	# Animate fade in
	var tween = create_tween()
	tween.tween_property(notification_panel, "modulate:a", 1.0, fade_duration)
	
	# Set timer for hiding
	notification_timer.wait_time = duration
	notification_timer.start()

func _on_notification_timer_timeout():
	# Animate fade out
	var tween = create_tween()
	tween.tween_property(notification_panel, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(func(): notification_panel.visible = false)

func _on_resume_button_pressed():
	toggle_pause()

func _on_restart_button_pressed():
	# Reset the game state and restart the current level
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("reset_player_state"):
		game_manager.reset_player_state()

	get_tree().paused = false
	
	# Hide both panels
	game_over_panel.visible = false
	pause_panel.visible = false

	# Reset the timer
	start_timer()

	# Reload the current scene
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	# Return to the main menu
	get_tree().paused = false
	
	# Hide both panels
	game_over_panel.visible = false
	pause_panel.visible = false
	
	get_tree().change_scene_to_file("res://scenes/menus/menu.tscn")

func play_item_collected_animation(item_texture, position):
	# Set the collected item's texture
	collected_item_animation.texture = item_texture
	collected_item_animation.global_position = position
	
	# Play animation sequence
	var tween = create_tween()
	tween.tween_property(collected_item_animation, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(collected_item_animation, "scale", Vector2(1.0, 1.0), 0.2)
	tween.tween_property(collected_item_animation, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): 
		collected_item_animation.modulate.a = 1.0
	)

func start_level_transition():
	# Fade to black
	transition_rect.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(transition_rect, "modulate:a", 1.0, 0.5)
	tween.tween_callback(func(): 
		# Actual level change would happen here or be triggered elsewhere
		pass
	)
	
	# After a delay, fade back in at the new level
	tween.tween_interval(0.3)
	tween.tween_property(transition_rect, "modulate:a", 0.0, 0.5)
	
func start_timer():
	print("HUD: Starting timer")
	level_time = 0.0
	tracking_time = true

func stop_timer():
	print("HUD: Stopping timer")
	tracking_time = false

func get_level_time() -> float:
	return level_time

func save_high_score(new_score: int) -> void:
	print("Trying to save high score:", new_score) # ADD THIS LINE
	var scores = []

	# Load existing scores
	if FileAccess.file_exists("user://high_scores.txt"):
		var file = FileAccess.open("user://high_scores.txt", FileAccess.READ)
		while not file.eof_reached():
			var line = file.get_line()
			if line.is_valid_int():
				scores.append(line.to_int())
		file.close()

	# Add new score
	scores.append(new_score)

	# Sort scores from highest to lowest
	scores.sort_custom(func(a, b): return b - a)
	while scores.size() > 10:
		scores.pop_back()

	# Save updated scores 
	var save_file = FileAccess.open("user://high_scores.txt", FileAccess.WRITE)
	for score in scores:
		save_file.store_line(str(score))
	save_file.close()

	print("High scores updated!")
