extends Area2D

# Define what the buttons do
@export var action: String = "remove_tiles1"  # Options: remove_tiles1, remove_tiles2, remove_tiles3, unlock_door
@export_node_path("TileMap") var tilemap_path = NodePath("../TileMap")
@onready var tilemap = get_node(tilemap_path) if not tilemap_path.is_empty() else $"../TileMap"
@export var affects_door: bool = false  # Set to true if this button unlocks a door
@export_node_path("Area2D") var target_door_path = NodePath()  # Optional specific door to target

# Tile positions for different actions
@export var tile_positions: Array[Vector2i] = []
@export var tile_positions2: Array[Vector2i] = [
	Vector2i(45, 40), 
	Vector2i(46, 40), 
	Vector2i(47, 40),
	Vector2i(48, 40),
	Vector2i(49, 40), 
	Vector2i(50, 40)
]
@export var tile_positions3: Array[Vector2i] = [
	Vector2i(122, 91), Vector2i(123, 91), Vector2i(124, 91),
	Vector2i(122, 92), Vector2i(123, 92), Vector2i(124, 92)
]
@export var add_tile_positions: Array[Vector2i] = [
	Vector2i(23, 22), Vector2i(24, 22), Vector2i(19, 19), Vector2i(20, 19),
	Vector2i(24, 16), Vector2i(25, 16), Vector2i(26, 16)
]
@export var add_tile_source_id: int = 1
@export var add_tile_atlas_coords: Vector2i = Vector2i(1, 0)
@export var tile_positions4: Array[Vector2i] = [
	Vector2i(25, 13), Vector2i(26, 13), Vector2i(27, 13),
	Vector2i(28, 13), Vector2i(29, 13), Vector2i(30, 13), Vector2i(31, 13)
]
@export var tile_positions5: Array[Vector2i] = [
	Vector2i(139, 2), Vector2i(139, 3), Vector2i(139, 4), Vector2i(139, 5)
]
var is_activated = false
signal button_pressed

func _ready():
	add_to_group("button")
	
	# Set up tile positions from ranges if needed
	if action == "remove_tiles1" and tile_positions.is_empty():
		setup_tile_positions()

func setup_tile_positions():
	var tile_ranges = [
		[Vector2i(134, 60), Vector2i(137, 60)],
		[Vector2i(130, 61), Vector2i(136, 61)],
		[Vector2i(126, 62), Vector2i(136, 62)],
		[Vector2i(112, 63), Vector2i(136, 63)],
		[Vector2i(109, 64), Vector2i(128, 64)],
		[Vector2i(106, 65), Vector2i(126, 65)],
		[Vector2i(105, 66), Vector2i(123, 65)],
		[Vector2i(103, 67), Vector2i(120, 67)],
		[Vector2i(100, 68), Vector2i(114, 68)],
		[Vector2i(99, 69), Vector2i(112, 69)],
		[Vector2i(98, 70), Vector2i(110, 70)],
		[Vector2i(97, 71), Vector2i(122, 71)],
		[Vector2i(96, 72), Vector2i(124, 72)],
		[Vector2i(110, 73), Vector2i(126, 73)],
		[Vector2i(111, 74), Vector2i(127, 74)],
		[Vector2i(113, 75), Vector2i(130, 75)],
		[Vector2i(115, 76), Vector2i(132, 76)],
		[Vector2i(117, 77), Vector2i(133, 77)],
		[Vector2i(118, 78), Vector2i(138, 78)],
		[Vector2i(119, 79), Vector2i(153, 79)]
	]
	
	# Loop through each range and generate tile positions
	for range in tile_ranges:
		var start = range[0]
		var end = range[1]
		for x in range(start.x, end.x + 1):  # Loop through X range
			tile_positions.append(Vector2i(x, start.y))  # Y remains the same

# Called when player interacts with button or something walks over it
func activate_button():
	if is_activated:
		return  # Prevent multiple activations

	is_activated = true
	print("Button activated!")
	emit_signal("button_pressed")

	# Perform the action based on the assigned type
	match action:
		"remove_tiles1":
			remove_tiles1()
			if has_node("/root/NotificationManager"):
				NotificationManager.show_notification("Some blocks near you have disappeared. You must find the button that activates the door.", 5.0)
			else:
				print("Notification: Some blocks near you have disappeared. You must find the button that activates the door.")
		"remove_tiles2":
			remove_tiles2()
			if has_node("/root/NotificationManager"):
				NotificationManager.show_notification("Some blocks near you have disappeared.", 3.0)
			else:
				print("Notification: Some blocks near you have disappeared.")
		"remove_tiles3":
			remove_tiles3()
			if has_node("/root/NotificationManager"):
				NotificationManager.show_notification("The door has been unlocked.", 3.0)
			else:
				print("Notification: The door has been unlocked.")
		"add_tiles":
			add_tiles()
			remove_tiles4()
			if has_node("/root/NotificationManager"):
				NotificationManager.show_notification("New platforms have appeared, and some have disappeared...", 3.0)
			else:
				print("Notification: New platforms have appeared!")
		"remove_tiles5":
			remove_tiles5()
			if has_node("/root/NotificationManager"):
				NotificationManager.show_notification("Some blocks near you have disappeared.", 3.0)
			else:
				print("Notification: Some blocks near you have disappeared.")
		_:
			print("Unknown action:", action)

func unlock_targeted_door():
	# First try to get specific door if path is provided
	if not target_door_path.is_empty():
		var door = get_node(target_door_path)
		if door and door.has_method("open_door"):
			door.open_door()
			return
			
	# Otherwise find all doors and unlock them
	var doors = get_tree().get_nodes_in_group("door")
	for door in doors:
		if door.has_method("open_door"):
			door.open_door()

# Function to remove tiles from the TileMap
func remove_tiles1():
	if tilemap:
		for tile_pos in tile_positions:
			# Use the proper layer index (1 in your code)
			tilemap.set_cell(1, tile_pos, -1)  # -1 removes the tile
		print("Tiles removed at:", tile_positions)
	else:
		print("ERROR: TileMap not assigned!")
		
func remove_tiles2():
	if tilemap:
		for tile_pos in tile_positions2:
			tilemap.set_cell(1, tile_pos, -1)  # -1 removes the tile
		print("Tiles removed at:", tile_positions2)
	else:
		print("ERROR: TileMap not assigned!")
		
func remove_tiles3():
	if tilemap:
		for tile_pos in tile_positions3:
			tilemap.set_cell(1, tile_pos, -1)  # -1 removes the tile
		print("Tiles removed at:", tile_positions3)
	else:
		print("ERROR: TileMap not assigned!")
		
func remove_tiles4():
	if tilemap:
		for tile_pos in tile_positions4:
			tilemap.set_cell(1, tile_pos, -1)  # -1 removes the tile
		print("Tiles removed at:", tile_positions4)
	else:
		print("ERROR: TileMap not assigned!")
		
func remove_tiles5():
	if tilemap:
		for tile_pos in tile_positions5:
			tilemap.set_cell(1, tile_pos, -1)  # -1 removes the tile
		print("Tiles removed at:", tile_positions5)
	else:
		print("ERROR: TileMap not assigned!")

func _show_notification(text: String, duration: float = 3.0):
	# Check if notification manager exists
	if Engine.has_singleton("NotificationManager") or has_node("/root/NotificationManager"):
		NotificationManager.show_notification(text, duration)
	else:
		print("NOTIFICATION: ", text)

# Connect interaction signal for player
func _on_body_entered(body):
	if body.is_in_group("player"):
		activate_button()

func add_tiles():
	if tilemap:
		for tile_pos in add_tile_positions:
			# Add tiles with the specified source ID and atlas coordinates
			tilemap.set_cell(1, tile_pos, add_tile_source_id, add_tile_atlas_coords)
			print("Tiles added at:", add_tile_positions)
	else:
		print("ERROR: TileMap not assigned!")
