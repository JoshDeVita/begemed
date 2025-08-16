extends CenterContainer
class_name HighScoreUI

var label: Label = Label.new()

func _ready() -> void:
	var place: int = 0
	for score in HighScoreList.high_scores:
		place += 1
		var scorelabel: Label = label.duplicate()
		scorelabel.text = "#" + str(place) + " - " + str(score)
		get_node("PanelContainer/VBoxContainer").add_child(scorelabel)
	get_node("PanelContainer/VBoxContainer").move_child(get_node("PanelContainer/VBoxContainer/Button"), get_node("PanelContainer/VBoxContainer").get_children().size())

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
