extends GutTest

# Function to create a mock player for testing
func _create_mock_player():
	var player_script = preload("res://scripts/bread_man.gd")
	var player_instance = CharacterBody2D.new()
	
	var animated_sprite = AnimatedSprite2D.new()
	animated_sprite.name = "AnimatedSprite2D"
	player_instance.add_child(animated_sprite)
	
	player_instance.set_script(player_script)
	add_child(player_instance)
	
	return player_instance

# Test for basic movement
func test_player_movement():
	var player = _create_mock_player()
	
	Input.action_press("move_right")
	player._physics_process(0.016)
	assert(player.velocity.x > 0, "Player is moving right!")
	#assert(player.velocity.x < 0, "Player is not moving right!")
	Input.action_release("move_right")
	
	player.velocity = Vector2.ZERO
	
	Input.action_press("move_left")
	player._physics_process(0.016) 
	assert(player.velocity.x < 0, "Player is moving left!")
	#assert(player.velocity.x > 0, "Player is not moving left!")
	Input.action_release("move_left")

# Test for gravity inversion
func test_gravity_inversion():
	var player = _create_mock_player()
	
	assert(player.gravity_direction == 1.0, "Gravity direction is correct initially!")
	#assert(player.gravity_direction == 1.0, "Gravity direction is not correct initially!")
	
	# Directly modify gravity direction
	player.gravity_direction = -1.0
	
	assert(player.gravity_direction == -1.0, "Gravity was inverted!")
	#assert(player.gravity_direction == -1.0, "Gravity was not inverted!")

# Test for jumping
# func test_player_jump():
#	var player = _create_mock_player()
	
#	# Temporarily modify the method to always return true
#	var original_is_on_floor = player.is_on_floor
#	player.is_on_floor = func(): return true
#	
#	Input.action_press("jump")
#	player._physics_process(0.016)
#	
#	assert(player.velocity.y < 0, "Player did not jump properly!")
#	Input.action_release("jump")
#	
#	# Restore original method
#	player.is_on_floor = original_is_on_floor
