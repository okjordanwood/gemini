extends Control

@export var display: Label

const NUMBER_OF_SCORES = 10

var scores: Array[int]

func _ready():
	scores.clear()
	
	if FileAccess.file_exists("user://high_scores.txt"):
		var scores_file = FileAccess.open("user://high_scores.txt", FileAccess.READ)
		while scores_file.get_position() < scores_file.get_length():
			var score = scores_file.get_line()
			if score.is_valid_int():
				scores.append(int(score))
		scores_file.close()
	else:
		# Optional: create an empty file so it exists
		var save_file = FileAccess.open("user://high_scores.txt", FileAccess.WRITE)
		save_file.close()

	display_scores(NUMBER_OF_SCORES)

func _process(delta):
	pass
	
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/menu.tscn")
		
func update_scores():
	scores.sort()
	scores.reverse()
	
func display_scores(number: int):
	update_scores()
	
	var text = ""
	
	if scores.size() == 0:
		text = "No scores yet!"
	else:
		for i in range(min(number, scores.size())):
			text += str(scores[i]) + "\n"
	
	display.text = text

func save_scores():
	update_scores()
	var scores_file = FileAccess.open("user://high_scores.txt", FileAccess.WRITE)
	for i in range(min(NUMBER_OF_SCORES, scores.size())):
		scores_file.store_line(str(scores[i]))
	scores_file.close()

func add_score(score: int):
	scores.append(score)
	save_scores()
