extends CenterContainer

func _ready() -> void:
	HighScoreList.load_game()

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")

func _on_high_score_button_pressed() -> void:
	get_tree().change_scene_to_file("res://high_scores.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
