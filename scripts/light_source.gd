extends Node2D

signal light_beam_updated

@export var beam_color: Color = Color.WHITE
@export var beam_intensity: float = 1.0
@export var beam_angle: float = 0.0

@onready var ray_cast: RayCast2D = $RayCast2D

func _ready():
	if not has_node("RayCast2D"):
		var new_ray_cast = RayCast2D.new()
		new_ray_cast.name = "RayCast2D"
		add_child(new_ray_cast)
	
	ray_cast = $RayCast2D
	ray_cast.enabled = true

func rotate_beam(angle: float):
	beam_angle = angle
	ray_cast.rotation_degrees = angle
	emit_signal("light_beam_updated")

func change_color(new_color: Color):
	beam_color = new_color
	emit_signal("light_beam_updated")

func get_beam_intersection() -> Dictionary:
	if ray_cast.is_colliding():
		print("Collision detected with: ", ray_cast.get_collider().name)
		return {
			"point": ray_cast.get_collision_point(),
			"object": ray_cast.get_collider(),
			"color": beam_color,
			"intensity": beam_intensity
		}
	print("No collision detected.")
	return {}
