extends Node

@onready var path: String = "user://high_scores.save"

var high_scores: Array[int]
var quantity: int = 5

func save_game() -> void:
	var save_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var save_string: String = JSON.stringify(high_scores)
	save_file.store_line(save_string)

func load_game() -> void:
	if not FileAccess.file_exists(path):
		return
	var save_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string: String = save_file.get_line()
		var json: JSON = JSON.new()
		var parse_result: Error = json.parse(json_string)
		if parse_result != OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		for item in json_string.split(","):
			high_scores.append(int(item))
	remove_duplicates()

func update(score: int) -> void:
	var position: int = 0
	for record in high_scores:
		if score > record:
			high_scores.insert(position, score)
			break
		position += 1
	if not high_scores.has(score) and high_scores.size() < quantity:
		high_scores.append(score)
	if high_scores.size() > quantity:
		high_scores.resize(quantity)
	remove_duplicates()
	save_game()

func remove_duplicates() -> void:
	var copy: Array[int] = high_scores.duplicate()
	high_scores.clear()
	for item in copy:
			if not high_scores.has(item) and item > 0:
				high_scores.append(item)
	high_scores.sort()
	high_scores.reverse()
