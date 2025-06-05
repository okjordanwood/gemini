extends Area2D
@onready var timer = $Timer

func _ready():
	print("Killzone initialized!")
	# Debug check for game manager
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		print("Found game manager!")
	else:
		print("Game manager not found!")

func _on_body_entered(body):
	if body.is_in_group("player") and not body.is_dead:
		print("Player hit killzone!")
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			game_manager.handle_player_death()
		else:
			print("No game manager found, falling back to scene reload")
			timer.start()

func _on_timer_timeout():
	get_tree().reload_current_scene()
