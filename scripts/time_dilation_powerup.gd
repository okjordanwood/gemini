extends Area2D

@export var time_dilation_factor: float = 0.5
@export var effect_duration: float = 5.0

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		# Slow down the entire game's time scale
		Engine.time_scale = time_dilation_factor
		
		# Create a timer to manage the duration of the effect
		var timer = Timer.new()
		timer.wait_time = effect_duration
		timer.one_shot = true
		
		# Connect the timer's timeout signal to reset the time scale
		timer.connect("timeout", Callable(self, "_on_effect_timeout"))
		
		# Add the timer as a child of this area
		add_child(timer)
		
		# Start the timer
		timer.start()
		
		# Hide the area and disable monitoring to prevent multiple triggers
		hide()
		set_deferred("monitoring", false)

func _on_effect_timeout() -> void:
	# Reset the time scale back to normal
	Engine.time_scale = 1.0
	
	# Remove this area from the scene
	queue_free()
