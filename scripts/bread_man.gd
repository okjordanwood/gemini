extends CharacterBody2D

const JUMP_VELOCITY = -400.0
const NORMAL_GRAVITY = 980.0
const WALL_STICK_SPEED = 100.0
const GRAVITY_FLIP_FORCE = 400.0  # Force applied when flipping gravity
const DEATH_Y_THRESHOLD = 2000  # Y position at which player dies
const TILE_LAYER = 1
const HAZARD_TYPE = "acid" 

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var line = $Body/Line2D
@onready var ray = $RayCast2D
@onready var laser_sound: AudioStreamPlayer = $LaserSound

var on_ladder: bool = false
var SPEED = 250.0
var facing_direction = 1
var gravity_direction := 1.0
var is_wall_sticking := false
var current_gravity_scale := 1.0
var room_gravity_scale := 1.0  # New variable for room-specific gravity
# the amount that gravity changes per second
# if > 1, gravity increases over time
# if < 1, gravity decreases
# if == 1, gravity stays constant
var room_gravity_modifier := 1.0
var modified_room_gravity := room_gravity_scale # allows you to modify the room's current gravity without overwriting the original
# Add this variable to your existing variables section
var can_invert_gravity: bool = true  # Developer can set this to control gravity inversion ability
var current_door: Node2D = null  # Keeps track of door the player is near
var initial_position: Vector2  # Store initial spawn position
var max_bounces = 10
var ice_friction := 0.1 # how quickly sideways movement is slowed down, from 0 to infinity
var is_frictionless: bool = false  # Flag to indicate frictionless boots
var is_dead = false  # Track if player is currently dead
var god_mode: bool = false
var teleport_indicator: Node2D = null
var death_animation_playing = false  # New variable to track death animation

signal door_interaction(door: Node2D)
signal player_died  # New signal for death

func _ready() -> void:
	add_to_group("player")
	initial_position = position  # Store initial position
	
	if !has_node("DeathSound"):
		death_sound = AudioStreamPlayer.new()
		death_sound.name = "DeathSound"
		add_child(death_sound)
		
		# Try to load death sound
		var death_sound_path = "res://assets/sounds/hurt.wav"
		var death_resource = load(death_sound_path)
		if death_resource:
			death_sound.stream = death_resource
			death_sound.volume_db = -5
			print("Death sound loaded successfully")
		else:
			print("WARNING: Could not load death sound from: ", death_sound_path)
	
	# Load jump sound
	if !has_node("JumpSound"):
		var audio_player = AudioStreamPlayer.new()
		audio_player.name = "JumpSound"
		add_child(audio_player)
		var sound = load("res://assets/sounds/jump.wav")
		if sound:
			audio_player.stream = sound
			audio_player.volume_db = -10  # Adjust volume as needed
			jump_sound = audio_player
		else:
			print("ERROR: Failed to load jump sound!")
			
	# Load death sound
	if !has_node("DeathSound"):
		var audio_player = AudioStreamPlayer.new()
		audio_player.name = "DeathSound"
		add_child(audio_player)
		var sound = load("res://assets/sounds/hurt.wav")  # Make sure to add this sound file
		if sound:
			audio_player.stream = sound
			audio_player.volume_db = -5  # Adjust volume as needed
			death_sound = audio_player
		else:
			print("ERROR: Failed to load death sound!")
			
	# Load laser sound
	if !has_node("LaserSound"):
		var audio_player = AudioStreamPlayer.new()
		audio_player.name = "LaserSound"
		add_child(audio_player)
		var sound = load("res://assets/music/rayo-laser-101851.wav")
		if sound:
			audio_player.stream = sound
			audio_player.volume_db = 0  # Adjust volume as needed
			laser_sound = audio_player
	else:
		print("ERROR: Failed to load laser sound!")
			
	# Create teleport indicator
	setup_teleport_indicator()
	
func set_speed(new_speed: float) -> void:
	SPEED = new_speed
# from room_management.gd, changes how gravity changes
func set_gravity_direction(new_gravity_direction: int) -> void:
	current_gravity_scale = new_gravity_direction

func set_on_ladder(value: bool) -> void:
	on_ladder = value

# New function to set room-specific gravity
func set_room_gravity(gravity_scale: float) -> void:
	room_gravity_scale = gravity_scale
	
func set_gravity_modifier(gravity_modifier: float) -> void:
	room_gravity_modifier = gravity_modifier

func calculate_gravity_force() -> float:
	return NORMAL_GRAVITY * gravity_direction * current_gravity_scale * modified_room_gravity

func is_on_ground() -> bool:
	# Check if we're on ground based on gravity direction
	return (gravity_direction > 0 and is_on_floor()) or (gravity_direction < 0 and is_on_ceiling())

func handle_gravity_manipulation() -> void:
	# Invert gravity (player can walk upside down)
	if can_invert_gravity and Input.is_action_just_pressed("invert_gravity"):  # set to 'I' on input map
		gravity_direction *= -1.0
		animated_sprite.flip_v = gravity_direction < 0
		# Apply an initial force in the direction of the new gravity
		velocity.y = GRAVITY_FLIP_FORCE * gravity_direction
		
	# Wall sticking mechanics
	if is_on_wall() and Input.is_action_pressed("stick_to_wall"):  # set to 'Left Shift' on input map
		is_wall_sticking = true
		velocity.y = WALL_STICK_SPEED * sign(velocity.y)  # Slow down vertical movement
		current_gravity_scale = 0.1  # Reduced gravity while sticking
	else:
		is_wall_sticking = false
		current_gravity_scale = 1.0

func check_death() -> void:
	if position.y > DEATH_Y_THRESHOLD and !is_dead:
		# Critical: Set is_dead immediately to prevent multiple death processing
		is_dead = true
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			# Properly disable all physics processing before game manager handles death
			set_physics_process(false)
			play_death_animation()
			game_manager.handle_player_death()
		else:
			# Fallback if no game manager exists
			die()

func die() -> void:
	# Only use this function as a fallback - prefer GameManager's handle_player_death
	emit_signal("player_died")
	# This is for when there is no GameManager
		# Play death animation
	play_death_animation()
	
func play_death_animation() -> void:
	# Freeze player movement
	set_physics_process(false)
	
	# Play death animation
	if animated_sprite and animated_sprite.sprite_frames.has_animation("death"):
		death_animation_playing = true
		animated_sprite.play("death")
		
		# Play death sound
		if death_sound:
			death_sound.play()
	else:
		# If no death animation exists, just reset player after a delay
		print("WARNING: No death animation found!")
		var timer = get_tree().create_timer(1.0)
		timer.timeout.connect(reset_after_death)

func reset_after_death() -> void:
	# Reset player position and state
	position = initial_position
	velocity = Vector2.ZERO
	gravity_direction = 1.0
	animated_sprite.flip_v = false
	modified_room_gravity = room_gravity_scale
	
	# Reset flags
	is_dead = false
	death_animation_playing = false
	
	# Return to idle animation
	if animated_sprite:
		animated_sprite.play("idle")
	
	# Re-enable physics
	set_physics_process(true)

func _on_animation_finished() -> void:
	# Check if it was the death animation that finished
	if death_animation_playing and animated_sprite.animation == "death":
		reset_after_death()
	
func _physics_process(delta: float) -> void:
	if god_mode:
		# Just do minimal processing needed for god mode
		if is_dead:
			return
		check_death()
		return
		
	# Don't process movement if dead
	if is_dead:
		return
	
	if check_hazard_tiles():
		return

	# Add gravity manipulation before regular gravity
	handle_gravity_manipulation()
	
	# Apply gravity modifier globally, for any level that needs it
	if room_gravity_modifier != 1.0:
		# Only change gravity over time if modifier is not 1.0
		modified_room_gravity *= pow(room_gravity_modifier, delta)
	else:
		# Keep gravity constant when modifier is 1.0
		modified_room_gravity = room_gravity_scale

	# Add the gravity.
	if not is_on_ground():
		velocity.y += calculate_gravity_force() * delta
		
	if on_ladder and Input.is_key_pressed(KEY_UP):
		velocity.y = -SPEED
	# Handle Jump.
	if Input.is_action_pressed("jump") and is_on_ground():
		velocity.y = JUMP_VELOCITY * gravity_direction
		if jump_sound:
			jump_sound.play()
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	
	
	if is_frictionless:
		if direction:
			velocity.x = move_toward(velocity.x, SPEED * direction, SPEED * delta * ice_friction)
			animated_sprite.play("walk")
			
			# Track direction properly
			if direction < 0:
				facing_direction = -1
			elif direction > 0:
				facing_direction = 1
			animated_sprite.flip_h = facing_direction == -1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta * ice_friction)
			animated_sprite.play("idle")
	else: # normal friction
		if direction:
			velocity.x = direction * SPEED
			animated_sprite.play("walk")
			
			# Track direction properly
			if direction < 0:
				facing_direction = -1
			elif direction > 0:
				facing_direction = 1
			animated_sprite.flip_h = facing_direction == -1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animated_sprite.play("idle")
	
	# Door interaction
	if Input.is_action_just_pressed("interact") and current_door:  # set to 'E' on input map
		print("Player trying to interact with door")
		emit_signal("door_interaction", current_door)
	
	move_and_slide()
	
	check_hazard_tiles()
	

func _on_door_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("door"):
		current_door = body
		print("Player near door: ", body.name)

func _on_door_detector_body_exited(body: Node2D) -> void:
	if body == current_door:
		current_door = null
		print("Player left door area")

func _on_hit_box_body_entered(body: Node2D) -> void:
	if !is_dead:
		# Critical: Set is_dead immediately to prevent multiple death processing
		is_dead = true
		# Properly disable all physics processing
		set_physics_process(false)
		play_death_animation()
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			game_manager.handle_player_death()
			
			
func setup_teleport_indicator() -> void:
	# Create a simple visual indicator for teleport location
	teleport_indicator = Node2D.new()
	teleport_indicator.name = "TeleportIndicator"
	
	# Add a ColorRect as a child to make it visible
	var indicator = ColorRect.new()
	indicator.name = "Indicator"
	indicator.color = Color(0, 1, 0, 0.5)  # Semi-transparent green
	indicator.size = Vector2(16, 16)
	indicator.position = Vector2(-8, -8)  # Center it
	teleport_indicator.add_child(indicator)
	
	# Add it to the scene but keep it hidden initially
	get_parent().add_child(teleport_indicator)
	teleport_indicator.visible = false
	
	
func _process(delta: float) -> void:
	# Handle laser sound
	if Input.is_action_pressed("fire_laser"):  # Assuming 'P' is mapped to "laser" in your input map
		if laser_sound and !laser_sound.playing:
			laser_sound.play()
	else:
		if laser_sound and laser_sound.playing:
			laser_sound.stop()
	
	# Handle god mode toggle
	if Input.is_action_just_pressed("god_mode"):  # Define this in project input settings
		god_mode = !god_mode
		print("God mode: ", "ON" if god_mode else "OFF")
		
		# Show a notification if we have a HUD
		var game_hud = get_node_or_null("/root/GameHud")
		if game_hud and game_hud.has_method("show_notification"):
			game_hud.show_notification("God Mode: " + ("ON" if god_mode else "OFF"), 2.0)
	
	# Handle teleport in god mode
	if god_mode:
		# Show teleport indicator at mouse position
		var mouse_pos = get_global_mouse_position()
		if teleport_indicator:
			teleport_indicator.global_position = mouse_pos
			teleport_indicator.visible = true
		
		# Teleport on click
		if Input.is_action_just_pressed("teleport"):  # Usually left mouse button
			global_position = mouse_pos
			velocity = Vector2.ZERO  # Reset velocity to prevent momentum
	else:
		# Hide indicator when not in god mode
		if teleport_indicator:
			teleport_indicator.visible = false
			
			
func check_hazard_tiles() -> bool:
	var tilemap = get_node_or_null("../TileMap")
	if not tilemap:
		tilemap = get_tree().get_first_node_in_group("tilemap")
	if not tilemap:
		return false

	var collision = $CollisionShape2D
	var points_to_check = []

	if collision.shape is CircleShape2D:
		var radius = collision.shape.radius
		# Check center and points around the circle
		points_to_check = [
			global_position,                           # Center
			global_position + Vector2(0, -radius),     # Top
			global_position + Vector2(radius, 0),      # Right
			global_position + Vector2(0, radius),      # Bottom
			global_position + Vector2(-radius, 0)      # Left
		]
	elif collision.shape is RectangleShape2D:
		var extents = collision.shape.extents
		# Check corners and center
		points_to_check = [
			global_position,                                       # Center
			global_position + Vector2(-extents.x, -extents.y),     # Top-left
			global_position + Vector2(extents.x, -extents.y),      # Top-right
			global_position + Vector2(-extents.x, extents.y),      # Bottom-left
			global_position + Vector2(extents.x, extents.y)        # Bottom-right
		]
	else:
		# Fallback for other shape types - just check the center
		points_to_check = [global_position]

	# Get the number of layers in the tilemap
	var layer_count = tilemap.get_layers_count()

	# Check each layer
	for layer in range(layer_count):
		for point in points_to_check:
			var tile_pos = tilemap.local_to_map(point)
			var tile_data = tilemap.get_cell_tile_data(layer, tile_pos)
			if tile_data and tile_data.get_custom_data("type") == HAZARD_TYPE:
				if not is_dead and not god_mode:
					is_dead = true
					set_physics_process(false)
					var game_manager = get_tree().get_first_node_in_group("game_manager")
					if game_manager:
						game_manager.handle_player_death()
					return true
	return false
