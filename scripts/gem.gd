extends Area2D

const POINT_VALUE := 25

var game_manager

func _ready():
	var existing_managers = get_tree().get_nodes_in_group("game_manager")
	if !existing_managers:
		print("ERROR: no game manager found")
		pass
	game_manager = existing_managers[0]

# Disappears when player contacts
func _on_body_entered(body):
	game_manager.add_score(POINT_VALUE)
	print("+1 gem")
	queue_free()
