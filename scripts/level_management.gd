extends Node

# This script should be attached to your main level scene
# It handles connections between player, doors, and buttons

func _ready():
	# Get all important nodes
	var player = get_tree().get_first_node_in_group("player")
	var doors = get_tree().get_nodes_in_group("door")
	var buttons = get_tree().get_nodes_in_group("button")
	
	if player:
		# Connect the player's door interaction signal to our handler
		player.door_interaction.connect(_on_player_door_interaction)
		print("Player door interaction connected")
	else:
		print("WARNING: No player found in the scene!")
		
	# Connect door signals
	for door in doors:
		print("Found door in scene:", door.name)
		if door.has_signal("level_completed"):
			door.level_completed.connect(_on_level_completed)
			print("Door level_completed signal connected")
		else:
			print("WARNING: Door doesn't have level_completed signal!")
	
	# Connect button signals to door unlock function
	for button in buttons:
		print("Found button in scene:", button.name)
		if button.has_signal("button_pressed"):
			# Connect button to door unlocking
			button.button_pressed.connect(_on_button_pressed.bind(button))
			print("Button press signal connected")
		else:
			print("WARNING: Button doesn't have button_pressed signal!")

func _on_player_door_interaction(door):
	print("Player interacted with door")
	
	if door.is_locked:
		# Show a message that the door is locked and needs a button
		if has_node("/root/NotificationManager"):
			NotificationManager.show_notification("This door is locked. Find a button to unlock it.", 3.0)
		else:
			print("Door is locked. Find a button to unlock it.")
	else:
		# The door is already unlocked, try to proceed to next level
		print("Player interacted with unlocked door")
		door.emit_signal("level_completed")

func _on_button_pressed(button):
	print("Button pressed:", button.name, "- Action:", button.action)
	
	# If the button is specifically for door unlocking
	if button.action == "unlock_door" or button.action == "remove_tiles3":
		var doors = get_tree().get_nodes_in_group("door")
		for door in doors:
			if door.is_locked:
				door.open_door()
				
				# Show notification
				if has_node("/root/NotificationManager"):
					NotificationManager.show_notification("The door has been unlocked.", 3.0)
				else:
					print("The door has been unlocked.")
				break

func _on_level_completed():
	print("Level completed! Transitioning to next level...")
	
	# You can add any level completion effects here
	# Such as a sound effect, particles, or transition animation
	
	# The actual scene change happens in the door script
