extends Button

@export var level_number: int = 1
@export var is_locked: bool = false

func _ready():
	text = str(level_number)
	set_button_style()
	if is_locked:
		disabled = true

func set_button_style():
	var unlocked_color = Color("#e5e542")
	var locked_color = Color("#e5a542")
	var text_color = Color.BLACK

	var style = StyleBoxFlat.new()
	style.bg_color = locked_color if is_locked else unlocked_color

	# Rounded corners
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12

	# Border width
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2

	style.border_color = Color.DARK_GRAY

	add_theme_stylebox_override("normal", style)
	add_theme_color_override("font_color", text_color)

func _pressed():
	if is_locked:
		return

	var level_path = "res://scenes/levels/level_%d.tscn" % level_number

	if ResourceLoader.exists(level_path):
		get_tree().change_scene_to_file(level_path)
	else:
		print("Level file not found: ", level_path)
