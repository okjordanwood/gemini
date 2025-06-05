extends Area2D

signal activated
signal deactivated

@export var required_color: Color = Color.WHITE
@export var activation_threshold: float = 0.5

var is_active: bool = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func receive_light(light_color: Color, intensity: float):
	print("Received light with color: ", light_color, " and intensity: ", intensity)
	if light_color.is_equal_approx(required_color) and intensity > activation_threshold:
		activate()
	else:
		deactivate()

func activate():
	if not is_active:
		is_active = true
		emit_signal("activated")
		# Add visual feedback (e.g., color change, animation)
		modulate = Color(1.2, 1.2, 1.2)  # Slight brightness increase

func deactivate():
	if is_active:
		is_active = false
		emit_signal("deactivated")
		modulate = Color.WHITE

func _on_body_entered(body):
	# Optional: Additional interaction when player enters
	pass

func _on_body_exited(body):
	# Optional: Additional interaction when player exits
	pass

func _on_RayCast2D_body_entered(body):
	if body.is_in_group("light_sources"):
		var light_info = body.get_beam_intersection()  # Call on the light source instance
		if light_info:  # Check if light_info is valid
			receive_light(light_info["color"], light_info["intensity"])
