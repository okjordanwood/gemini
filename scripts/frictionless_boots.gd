extends Area2D

# Signal emitted when boots are collected
signal boots_collected

# Visual feedback sprite for the boots
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Add this item to the collectible group for easy identification
	add_to_group("collectible")
	
	# Connect the body entered signal
	body_entered.connect(_on_body_entered)
	
	# Implemented a simple hover animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "position:y", -5.0, 1.0)
	tween.tween_property(sprite, "position:y", 5.0, 1.0)

## Called when a body enters the boots' collision area
func _on_body_entered(body):
	print("Fresh new Js don't crease")
	
	#if body.is_in_group("player"):
	if body.has_method("collect_item"):
		# Emit signal before collection
		boots_collected.emit()
		
		# Add boots to player's inventory
		body.collect_item("friction_boots", "Frictionless Boots")
		
		# Simple collection animation to let player know boots
		# have been collected
		# when collected, the boots will:
			# quickly grow to 1.5x their size
			# fade away to invisible
			# then get removed from the scene
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		
		# Remove the boots after collection
		tween.tween_callback(queue_free)
	body.is_frictionless = true
	queue_free()
