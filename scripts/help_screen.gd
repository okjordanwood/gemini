extends Control


# Node enters the scene tree
func _ready():
	for child in get_tree().get_root().get_children():
		if child.name == "GameHud":  
			child.visible = false




func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/options_menu.tscn")
