extends CanvasLayer

# References to UI elements
@onready var panel = $ScoreboardPanel
@onready var level_name_label = $ScoreboardPanel/VBoxContainer/LevelNameLabel
@onready var time_label = $ScoreboardPanel/VBoxContainer/StatsContainer/TimeLabel
@onready var deaths_label = $ScoreboardPanel/VBoxContainer/StatsContainer/DeathsLabel
@onready var score_label = $ScoreboardPanel/VBoxContainer/StatsContainer/ScoreLabel
@onready var grade_label = $ScoreboardPanel/VBoxContainer/GradeContainer/GradeLabel
@onready var continue_button = $ScoreboardPanel/VBoxContainer/ButtonsContainer/ContinueButton
@onready var retry_button = $ScoreboardPanel/VBoxContainer/ButtonsContainer/RetryButton
@onready var menu_button = $ScoreboardPanel/VBoxContainer/ButtonsContainer/MenuButton
@onready var star_container = $ScoreboardPanel/VBoxContainer/StarContainer
@onready var stars = []

# Level stats
var level_time: float = 0.0
var death_count: int = 0
var score: int = 0
var grade: String = "C"
var star_count: int = 0
var level_name: String = ""
var next_level_path: String = ""

# Animation properties
@export var appear_time: float = 0.5
@export var star_delay: float = 0.3

# Level progression mapping
var level_progression = {
	"res://scenes/levels/level_1.tscn": "res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_2.tscn": "res://scenes/levels/level_3.tscn",
	"res://scenes/levels/level_3.tscn": "res://scenes/levels/level_4.tscn",
	"res://scenes/levels/level_4.tscn": "res://scenes/levels/level_5.tscn",
	"res://scenes/levels/level_5.tscn": "res://scenes/levels/level_6.tscn",
	"res://scenes/levels/level_6.tscn": "res://scenes/levels/level_7.tscn",
	"res://scenes/levels/level_7.tscn": "res://scenes/levels/level_8.tscn",
	"res://scenes/levels/level_8.tscn": "res://scenes/menus/menu.tscn"
}

func _ready():
	# Set up initial state
	panel.modulate.a = 0
	panel.visible = false
	
	# Find all star nodes
	for i in range(1, 4):  # Assuming 3 stars max
		if star_container.has_node("Star" + str(i)):
			var star = star_container.get_node("Star" + str(i))
			stars.append(star)
			star.modulate.a = 0  # Start invisible
	
	# Connect button signals
	continue_button.pressed.connect(_on_continue_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

# Call this when a level is completed
func show_scoreboard(level_stats: Dictionary):
	# Extract stats from the dictionary
	level_name = level_stats.get("level_name", "Level")
	level_time = level_stats.get("time", 0.0)
	death_count = level_stats.get("deaths", 0)
	score = level_stats.get("score", 0)
	star_count = level_stats.get("stars", 0)
	grade = level_stats.get("grade", "C")
	
	# Determine next level path based on current scene
	var current_scene_path = get_tree().current_scene.scene_file_path
	next_level_path = level_progression.get(current_scene_path, "res://scenes/menus/menu.tscn")
	
	# Update the UI
	level_name_label.text = level_name + " Complete!"
	time_label.text = "Time: " + format_time(level_time)
	deaths_label.text = "Deaths: " + str(death_count)
	score_label.text = "Score: " + str(score)
	grade_label.text = grade
	
	# Make the panel visible
	panel.visible = true
	
	# Animate panel appearance
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, appear_time).set_ease(Tween.EASE_OUT)
	
	# Animate stars after a delay
	tween.tween_callback(animate_stars)
	
	# Ensure the game is paused while showing the scoreboard
	get_tree().paused = true

# Format time as minutes:seconds.milliseconds
func format_time(time_in_seconds: float) -> String:
	var minutes = int(time_in_seconds / 60)
	var seconds = int(time_in_seconds) % 60
	var milliseconds = int((time_in_seconds - int(time_in_seconds)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

# Animate the stars appearing one by one
func animate_stars():
	for i in range(min(star_count, stars.size())):
		var star = stars[i]
		var tween = create_tween()
		tween.tween_property(star, "modulate:a", 1.0, 0.3).set_delay(i * star_delay)
		tween.parallel().tween_property(star, "scale", Vector2(1.2, 1.2), 0.2).set_delay(i * star_delay)
		tween.tween_property(star, "scale", Vector2(1.0, 1.0), 0.1)

# Continue to the next level
func _on_continue_pressed():
	hide_scoreboard()
	if next_level_path:
		get_tree().paused = false
		get_tree().change_scene_to_file(next_level_path)
	else:
		# If no next level specified, go to main menu
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/menus/menu.tscn")

# Retry the current level
func _on_retry_pressed():
	hide_scoreboard()
	get_tree().paused = false
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)

# Go back to the main menu
func _on_menu_pressed():
	hide_scoreboard()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/menu.tscn")

# Hide the scoreboard with animation
func hide_scoreboard():
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): 
		panel.visible = false
		# Ensure game is unpaused when scoreboard is hidden
		get_tree().paused = false
	)
