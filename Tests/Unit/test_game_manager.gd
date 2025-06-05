# res://tests/Unit/test_game_manager.gd
# BGFJKBGJKESBJKSFDBJKVBDJKSBVJKSBHFIOHESIOFHIOEFHEIOG
extends GutTest

var game_manager_script = preload("res://scripts/game_manager.gd")
var game_manager

func before_each():
	# Create a new instance of the script
	game_manager = Node2D.new()
	game_manager.set_script(game_manager_script)
	add_child(game_manager)
	
	# Manually call _enter_tree and _ready methods
	game_manager._enter_tree()
	game_manager._ready()

func after_each():
	# Clean up the game manager after each test
	game_manager.queue_free()

func test_initial_lives():
	assert_eq(game_manager.player_lives, 3, "Player should start with 3 lives")

func test_add_score():
	var initial_score = game_manager.score
	game_manager.add_score(10)
	assert_eq(game_manager.score, initial_score + 10, "Score should increase by 10")

func test_player_death():
	var initial_lives = game_manager.player_lives
	game_manager.handle_player_death()
	assert_eq(game_manager.player_lives, initial_lives - 1, "Lives should reduce by 1 on death")
