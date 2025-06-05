extends RayCast2D

@export var cast_speed := 7000.0
@export var max_length := 1400.0
@export var growth_time := 0.1

var is_casting := false: set = set_is_casting

@onready var fill : Line2D = $FillLine2D
var tween : Tween
@onready var casting_particles := $CastingParticles2D
@onready var collision_particles := $CollisionParticles2D
@onready var beam_particles := $BeamParticles2D

@onready var line_width: float = fill.width
@onready var player = get_parent()  # Assuming player is the parent of the laser

func _ready() -> void:
	set_physics_process(false)
	fill.points[1] = Vector2.ZERO
	#set_process_unhandled_input(true)
	position = Vector2(0, -8)
	enabled = true
	collision_mask = 1

func _physics_process(delta: float) -> void:
	cast_beam()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("fire_laser"):
		set_is_casting(true)
	else:
		set_is_casting(false)

func set_is_casting(cast: bool) -> void:
	is_casting = cast
	
	if is_casting:
		appear()
	else:
		fill.points[1] = Vector2.ZERO
		collision_particles.emitting = false
		disappear()

	set_physics_process(is_casting)
	beam_particles.emitting = is_casting
	casting_particles.emitting = is_casting

func cast_beam() -> void:
	fill.clear_points()
	fill.add_point(Vector2.ZERO)  # Start the beam from the player
	
	var original_position = global_position
	
	# Determine laser direction based on player's facing direction
	var laser_direction = Vector2(player.facing_direction, 0)  # Left (-1) or right (1)
	var current_position = global_position
	var bounces = 0
	var max_bounces = 5  # Adjust for more reflections
	
	beam_particles.emitting = true
	casting_particles.emitting = true
	
	while bounces < max_bounces:
		# Set the raycast properties for this segment
		global_position = current_position  # Update raycast origin
		target_position = laser_direction * max_length  # Set the direction
		
		# Now update the raycast
		force_raycast_update()
		
		if not is_colliding():
			# If no collision, extend the laser to its full length
			var end_point = current_position + (laser_direction * max_length)
			fill.add_point(to_local(end_point))
			break
		
		# If collision occurs, stop at the collision point
		var hit_point = get_collision_point()
		fill.add_point(to_local(hit_point))
		
		# Handle collision
		var collider = get_collider()
		
		# Handle button interaction
		if collider and collider.is_in_group("Buttons"):
			collider.activate_button()
			collision_particles.global_position = hit_point
			collision_particles.emitting = true
		
			break
			
		# Handle reflection for mirrors
		if collider and collider.is_in_group("Mirrors"):
			var normal = get_collision_normal()
			laser_direction = laser_direction.bounce(normal)
			current_position = hit_point  # Update position to collision point
			bounces += 1
		else:
			# For non-mirror collisions, show particles and stop
			collision_particles.global_position = hit_point
			collision_particles.emitting = true
			break
			
	global_position = original_position
	
	# Update particles based on the final length of the beam
	if fill.points.size() > 1:
		beam_particles.position = fill.points[0] + (fill.points[-1] * 0.5)
		beam_particles.process_material.emission_box_extents.x = fill.points[-1].length() * 0.5

# Function to handle the appearance of the laser beam
func appear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(fill, "width", line_width, growth_time * 2).from(0)

# Function to handle the disappearance of the laser beam
func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(fill, "width", 0, growth_time).from_current()
