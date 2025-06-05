extends Camera2D

# Optional export variables for manual override if needed
@export var tilemap_path: NodePath
@export var follow_target: NodePath
@export var auto_detect: bool = true  # Enable auto-detection of tilemap and player

# Node references
var tilemap: TileMap
var target: Node2D

@export var use_smoothing: bool = true
@export var smoothing_speed: float = 10.0

func _ready() -> void:
	position_smoothing_enabled = use_smoothing
	if use_smoothing:
		position_smoothing_speed = smoothing_speed
	
	# First try manual paths if provided
	if not tilemap_path.is_empty():
		tilemap = get_node_or_null(tilemap_path)
	
	if not follow_target.is_empty():
		target = get_node_or_null(follow_target)
	
	# If auto_detect is enabled or manual paths failed, try to auto-detect
	if auto_detect or not tilemap or not target:
		_auto_detect_nodes()
	
	# Set up camera limits based on tilemap
	_set_camera_limits()
	
	# for light-level-1.tscn - set zoom to 2
	var current_scene_path = get_tree().current_scene.scene_file_path
	if current_scene_path.ends_with("level_5.tscn") or current_scene_path.ends_with("level_4.tscn"):
		print("Camera: Setting special zoom for light level 1")
		zoom = Vector2(2, 2)
	else:
		# Reset to default zoom for other scenes
		zoom = Vector2(1, 1)

func _auto_detect_nodes() -> void:
	# Look for player
	if not target:
		target = get_tree().get_first_node_in_group("player")
		if target:
			print("Camera: Auto-detected player: ", target.name)
		else:
			print("Camera: Could not find player in 'player' group!")
	
	# Look for tilemap
	if not tilemap:
		# Try to find a TileMap node in the current scene
		for child in get_tree().current_scene.get_children():
			if child is TileMap:
				tilemap = child
				print("Camera: Auto-detected tilemap: ", tilemap.name)
				break
		
		# If still not found, try to search deeper
		if not tilemap:
			var possible_tilemaps = get_tree().get_nodes_in_group("level_tilemap")
			if possible_tilemaps.size() > 0:
				tilemap = possible_tilemaps[0]
				print("Camera: Found tilemap in 'level_tilemap' group: ", tilemap.name)
			else:
				# Last resort - find any TileMap in the scene
				var all_tilemaps = []
				_find_nodes_of_type(get_tree().current_scene, "TileMap", all_tilemaps)
				if all_tilemaps.size() > 0:
					tilemap = all_tilemaps[0]
					print("Camera: Found tilemap by deep search: ", tilemap.name)
				else:
					print("Camera: Could not find any TileMap in the scene!")

# Helper function to find nodes of a specific type
func _find_nodes_of_type(node, type_name, result_array):
	# Check if the node is an instance of the specified class
	if node.get_class() == type_name or node.is_class(type_name):
		result_array.append(node)
	
	for child in node.get_children():
		_find_nodes_of_type(child, type_name, result_array)

func _set_camera_limits() -> void:
	if not tilemap:
		print("Camera: No tilemap available to set camera limits!")
		return
	
	var used_rect = tilemap.get_used_rect()
	
	var tile_size = Vector2(64, 64)  # Default fallback
	if tilemap.tile_set:
		tile_size = tilemap.tile_set.tile_size
	
	# Calculate world coordinates of tilemap boundaries
	var map_limits = {
		"left": tilemap.global_position.x + (used_rect.position.x * tile_size.x),
		"top": tilemap.global_position.y + (used_rect.position.y * tile_size.y),
		"right": tilemap.global_position.x + ((used_rect.position.x + used_rect.size.x) * tile_size.x),
		"bottom": tilemap.global_position.y + ((used_rect.position.y + used_rect.size.y) * tile_size.y)
	}
	
	# Set camera limits
	limit_left = map_limits["left"]
	limit_top = map_limits["top"]
	limit_right = map_limits["right"]
	limit_bottom = map_limits["bottom"]
	
	print("Camera: Limits set to L:", limit_left, " T:", limit_top, " R:", limit_right, " B:", limit_bottom)

func _process(delta: float) -> void:
	# Check if player has been spawned after camera initialization
	if auto_detect and not target:
		target = get_tree().get_first_node_in_group("player")
		if target:
			print("Camera: Player found during runtime!")
	
	# Follow the target if available
	if target:
		global_position = target.global_position
	else:
		# If no target and we need one, show an error
		if not has_meta("error_shown"):
			print("Camera: No follow target available!")
			set_meta("error_shown", true)
