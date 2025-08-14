extends NinePatchRect

@onready var score_label: Label = $ScoreLabel
var current_score: int = 0

func _ready() -> void:
	update_score(current_score)

func _on_grid_update_score(score_to_add: int) -> void:
	update_score(score_to_add)

func update_score(score_to_add: int) -> void:
	current_score += score_to_add
	score_label.text = "Score: " + str(current_score)
