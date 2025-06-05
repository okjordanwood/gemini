extends Node2D
# Make this accessible as a singleton
const SAVE_FILE_PATH := "user://game_save.dat"
const NUMBER_OF_LEVELS := 8
# Scene references
@export var death_y_threshold_bottom := 1620.0  # Bottom boundary
@export var death_y_threshold_top := -1000.0    # Top boundary
@export var respawn_delay := 1.0
# Audio
@onready var background_music: AudioStreamPlayer = $BackgroundMusic
# Game state
var current_checkpoint: Vector2
var level_score := 0
var score := 0
var game_paused := false
var is_respawning := false
var current_scene_path := ""
var level_time: float = 0.0
var level_start_time: float = 0.0
var time_paused: float = 0.0
var player_deaths: int = 0 
var highest_level_completed: int = 0
var percent_progress : int = 0
var waiting_for_death_animation := false
var master_volume_db: float = 0.0
var music_volume_db: float = -10.0
var sfx_volume_db: float = -5.0

# Signals
signal player_died
signal game_over
signal score_changed(new_score: int)

func _enter_tree():
	# Make sure we don't duplicate the game manager
	var existing_managers = get_tree().get_nodes_in_group("game_manager")
	for manager in existing_managers:
		if manager != self:
			queue_free()
			return
	
	# Make this node persist between scene changes
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("game_manager")

func _ready() -> void:
	print("Game Manager initialized and added to group!")
	# Keep position at origin
	global_position = Vector2.ZERO
	
	# Store current scene path
	current_scene_path = get_tree().current_scene.scene_file_path
	
	# Setup background music if it doesn't exist
	print("Checking for BackgroundMusic node...")
	if !has_node("BackgroundMusic"):
		print("Creating new BackgroundMusic node...")
		var audio_player = AudioStreamPlayer.new()
		audio_player.name = "BackgroundMusic"
		add_child(audio_player)
		# Load background music
		print("Loading background music file...")
		var music = load("res://assets/music/background_music.wav")
		if music:
			print("Music file loaded successfully!")
			audio_player.stream = music
			audio_player.volume_db = -10  # Adjust volume as needed
			audio_player.bus = "Music"
			background_music = audio_player
			# Start playing immediately
			audio_player.play()
		else:
			print("ERROR: Failed to load music file!")
	else:
		print("BackgroundMusic node already exists")
		background_music = $BackgroundMusic
		if !background_music.playing:
			background_music.play()
			
	reset_level()
	player_deaths = 0
	
	# Connect to the player's death animation completion signal if available
	connect_to_player()
	
	# Wait for the scene to be fully loaded
	await get_tree().create_timer(0.1).timeout
	connect_to_player()  # Try again to connect after a short delay

func connect_to_player() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Connect to both signals from player
		if !player.is_connected("player_died", _on_player_died):
			player.connect("player_died", _on_player_died)
			print("Connected to player_died signal")
		
		if player.has_signal("death_animation_finished") and !player.is_connected("death_animation_finished", _on_death_animation_finished):
			player.connect("death_animation_finished", _on_death_animation_finished)
			print("Connected to death_animation_finished signal")

func _process(delta: float) -> void:
	if is_respawning or waiting_for_death_animation:  # Don't check for death while respawning
		return
		
	var player = get_tree().get_first_node_in_group("player")
	if player and (player.global_position.y > death_y_threshold_bottom or player.global_position.y < death_y_threshold_top):
		handle_player_death()
		
	if not get_tree().paused:
		if not is_respawning:
			level_time = Time.get_ticks_msec() / 1000.0 - level_start_time - time_paused
	else:
		# increases the start time while paused, essentially ignoring any time while paused
		time_paused += delta 
		
func reset_level():
	level_start_time = Time.get_ticks_msec() / 1000.0
	level_time = 0.0
	time_paused = 0
	level_score = 0
	
func _on_player_died() -> void:
	print("GameManager received player_died signal")
	# Flag that we're waiting for death animation
	waiting_for_death_animation = true

func _on_death_animation_finished() -> void:
	print("GameManager received death_animation_finished signal")
	if waiting_for_death_animation:
		waiting_for_death_animation = false
		handle_player_death()
		
func handle_player_death() -> void:
	if is_respawning:
		return
		
	print("GameManager handling player death!")
	is_respawning = true
	emit_signal("player_died")
	
	# If we're not waiting for death animation, add a delay before reloading
	if !waiting_for_death_animation:
		await get_tree().create_timer(respawn_delay).timeout
	
	if is_respawning:
		print("Reloading scene after death")
		get_tree().reload_current_scene()
		is_respawning = false
		player_deaths += 1
		
		# Reconnect to the player after scene reload (on next frame)
		await get_tree().process_frame
		connect_to_player()

func add_score(points: int) -> void:
	score += points
	level_score += points
	emit_signal("score_changed", score)

func toggle_background_music() -> void:
	if background_music:
		if background_music.playing:
			background_music.stop()
		else:
			background_music.play()

func set_background_music_volume(volume_db: float) -> void:
	if background_music:
		background_music.volume_db = volume_db
		
# keep track of game progress
func level_completed(level_number: String) -> void:
	if int(level_number) > highest_level_completed:
		highest_level_completed = int(level_number)
		percent_progress = (100 * highest_level_completed) / NUMBER_OF_LEVELS
		print("Completed ", highest_level_completed, "/", NUMBER_OF_LEVELS, 
		" levels (", percent_progress, "%).")
		
func set_master_volume(volume_db: float) -> void:
	master_volume_db = volume_db
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)
	
func set_music_volume(volume_db: float) -> void:
	music_volume_db = volume_db
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume_db)
	# Also update background music directly
	if background_music:
		background_music.volume_db = volume_db
	
func set_sfx_volume(volume_db: float) -> void:
	sfx_volume_db = volume_db
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), volume_db)
