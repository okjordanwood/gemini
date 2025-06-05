extends Node2D

@onready var raycast = $RayCast2D
var player: Node2D = null
var max_range = 300.0  # detection radius value
var idle_rotation_speed = 2.0  # radians per second for idle rotation speed

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	raycast.enabled = true
	raycast.target_position = Vector2(max_range, 0)

func _process(delta: float) -> void:
	if player:
		var direction_vector = player.global_position - global_position
		var distance = direction_vector.length()
		# Only faces the player if they are in the max_range
		if distance <= max_range:
			rotation = direction_vector.angle()
			# Update raycast and check l.o.s. 
			raycast.force_raycast_update()
			if raycast.is_colliding():
				var collider = raycast.get_collider()
				if collider.is_in_group("player"):
					# Ray hits the player
					pass
		else:
			# Player is out of range, spin idly
			rotation += idle_rotation_speed * delta
	else:
		# No player found, spin idly
		rotation += idle_rotation_speed * delta
