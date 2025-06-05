extends Node2D

@onready var tilemap = $TileMap
@onready var button = $Button

func _ready():
	button.connect("button_pressed", Callable(self, "_on_button_pressed"))

func _on_button_pressed():
	var tiles_to_remove = [Vector2i(5, 6), Vector2i(6, 6), Vector2i(7, 6)]  # Coordinates of tiles to remove
	for tile in tiles_to_remove:
		tilemap.set_cell(0, tile, -1)  # Layer 0, remove tile
