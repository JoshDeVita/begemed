extends CenterContainer

func _on_continue_button_pressed() -> void:
	resume_game()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		resume_game()

func resume_game() -> void:
	hide()
	get_tree().paused = false
