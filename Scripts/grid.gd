extends Node2D

@export var height: int
@export var width: int
@export var x_start: int
@export var y_start: int
@export var offset: int

#region Class variables
enum States {WAIT, PLAY}
var state: States

enum Directions {WEST, EAST, NORTH, SOUTH}
var direction: Dictionary[Directions, Vector2] = {
	Directions.WEST: Vector2(-1, 0),
	Directions.EAST: Vector2(1, 0),
	Directions.NORTH: Vector2(0, 1),
	Directions.SOUTH: Vector2(0, -1),
}

var gems: Array[Array]
var all_gems: Array[PackedScene] = [
	preload("res://gems/blue_gem.tscn"),
	preload("res://gems/red_gem.tscn"),
	preload("res://gems/purple_gem.tscn"),
	preload("res://gems/yellow_gem.tscn"),
	preload("res://gems/white_gem.tscn"),
	preload("res://gems/green_gem.tscn"),
]

var first_move: Vector2
var second_move: Vector2
var active_move: bool
#endregion

func _ready() -> void:
	state = States.PLAY
	gems = generate_array()
	spawn_pieces()

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if state == States.PLAY:
		click_input()

#region Connections
func _on_destroy_timer_timeout() -> void:
	destroy_matches()

func _on_collapse_timer_timeout() -> void:
	collapse_columns()
	($RefillTimer as Timer).start()
	
func _on_refill_timer_timeout() -> void:
	refill_columns()
	check_for_additional_matches()
#endregion

#region Startup
func spawn_pieces() -> void:
	for column in width:
		for row in height:
			var gem_list: Array[PackedScene] = all_gems.duplicate()
			var random_gem: int = get_random_gem(gem_list)
			var new_gem: Gem = gem_list[random_gem].instantiate()
			while match_at(Vector2(column, row), new_gem):
				gem_list.remove_at(random_gem)
				random_gem = get_random_gem(gem_list)
				new_gem = gem_list[random_gem].instantiate()
			add_child(new_gem)
			new_gem.position = grid_to_pixel(column, row)
			gems[column][row] = new_gem

func generate_array() -> Array[Array]:
	var array: Array[Array]
	for column in width:
		array.append([])
		for row in height:
			array[column].append(null)
	return array
#endregion

#region Coordinates
func grid_to_pixel(column: int, row: int) -> Vector2:
	var new_x: int = x_start + (offset * column)
	var new_y: int = y_start + (-offset * row)
	return Vector2(new_x, new_y)

func pixel_to_grid(Vector: Vector2) -> Vector2:
	var new_x: int = round((Vector.x - x_start) / offset)
	var new_y: int = round((Vector.y - y_start) / -offset)
	return Vector2(new_x, new_y)

func is_in_bounds(location:Vector2) -> bool:
	if location.x >= 0 and location.y >= 0 and location.x < width and location.y < height:
		return true
	return false

func click_input() -> void:
	if active_move == false and Input.is_action_just_pressed("ui_left_click"):
		start_move()
	elif active_move == true and Input.is_action_just_pressed("ui_left_click"):
		finish_move()
	#if active_move == true and Input.is_action_just_released("ui_left_click"):
		#FinishMove()
#endregion

#region Swapping
func start_move() -> void:
	var grid_position: Vector2
	first_move = get_global_mouse_position()
	grid_position = pixel_to_grid(first_move)
	if is_in_bounds(grid_position):
		active_move = true
	else:
		active_move = false

func finish_move() -> void:
	var grid_position: Vector2
	second_move = get_global_mouse_position()
	grid_position = pixel_to_grid(second_move)
	if active_move and is_in_bounds(grid_position) and grid_position != pixel_to_grid(first_move):
		attempt_swap(pixel_to_grid(first_move), grid_position)
	active_move = false

func attempt_swap(grid_position_1: Vector2, grid_position_2: Vector2) -> void:
	var delta: Vector2 = grid_position_2 - grid_position_1
	if abs(delta.x) > abs(delta.y):
		if delta.x == 1:
			swap(grid_position_1, direction[Directions.EAST])
		elif delta.x == -1:
			swap(grid_position_1, direction[Directions.WEST])
	elif abs(delta.y) > abs(delta.x):
		if delta.y == 1:
			swap(grid_position_1, direction[Directions.NORTH])
		elif delta.y == -1:
			swap(grid_position_1, direction[Directions.SOUTH])

func swap(location: Vector2, path: Vector2) -> void:
	var gem_1_position: Vector2 = Vector2(location.x, location.y)
	var gem_2_position: Vector2 = Vector2(location.x + path.x, location.y + path.y)
	if gems[gem_1_position.x][gem_1_position.y] == null || gems[gem_2_position.x][gem_2_position.y] == null:
		return
	state = States.WAIT
	var gem_1: Gem = gems[gem_1_position.x][gem_1_position.y]
	var gem_2: Gem = gems[gem_2_position.x][gem_2_position.y]
	gems[gem_1_position.x][gem_1_position.y] = gem_2
	gems[gem_2_position.x][gem_2_position.y] = gem_1
	@warning_ignore("narrowing_conversion")
	gem_1.move(grid_to_pixel(gem_2_position.x, gem_2_position.y), Gem.Movement.SWAP)
	@warning_ignore("narrowing_conversion")
	gem_2.move(grid_to_pixel(gem_1_position.x, gem_1_position.y), Gem.Movement.SWAP)
	find_matches()
#endregion

#region Matches
func find_matches() -> void:
	for column in width:
		for row in height:
			var location: Vector2 = Vector2(column, row)
			if gems[location.x][location.y] != null:
				var check_gem: Gem = gems[location.x][location.y]
				if check_gem.matched == false:
					var match_list: Array[Vector2] = [location]
					match_list.append_array(get_matches_in_direction(location, direction[Directions.EAST], check_gem))
					match_list.append_array(get_matches_in_direction(location, direction[Directions.WEST], check_gem))
					count_matches(match_list)
					match_list = [location]
					match_list.append_array(get_matches_in_direction(location, direction[Directions.NORTH], check_gem))
					match_list.append_array(get_matches_in_direction(location, direction[Directions.SOUTH], check_gem))
					count_matches(match_list)

func match_at(location: Vector2, check_gem: Gem) -> bool:
	var match_list: Array[Vector2] = [location]
	match_list.append_array(get_matches_in_direction(location, direction[Directions.EAST], check_gem))
	match_list.append_array(get_matches_in_direction(location, direction[Directions.WEST], check_gem))
	if match_list.size() >= 3:
		return true
	match_list = [location]
	match_list.append_array(get_matches_in_direction(location, direction[Directions.NORTH], check_gem))
	match_list.append_array(get_matches_in_direction(location, direction[Directions.SOUTH], check_gem))
	if match_list.size() >= 3:
		return true
	return false

func get_matches_in_direction(location: Vector2, path: Vector2, input_gem: Gem) -> Array[Vector2]:
	var list: Array[Vector2] = []
	var check_position: Vector2 = Vector2(location.x, location.y)
	var check_gem: Gem = input_gem.duplicate()
	var gem_color: Gem.Type = check_gem.gem_color
	while check_gem.gem_color == gem_color and is_in_bounds(check_position) :
		check_position += path
		if is_in_bounds(check_position) and gems[check_position.x][check_position.y] != null:
			check_gem = gems[check_position.x][check_position.y]
			if check_gem.gem_color == gem_color:
				list.append(check_position)
		else:
			return list
	return list

func count_matches(list: Array[Vector2]) -> void:
	if list.size() >= 3:
		for v in list:
			var matched_gem: Gem = gems[v.x][v.y]
			matched_gem.matched = true
		($DestroyTimer as Timer).start()
#endregion

#region Supporting gameplay
func get_random_gem(list: Array) -> int:
	return randi() % list.size()

func collapse_columns() -> void:
	for column in width:
		for row in height:
			if gems[column][row] == null:
				for row_above in range(row + 1, height):
					if gems[column][row_above] != null:
						var FallingGem: Gem = gems[column][row_above]
						FallingGem.move(grid_to_pixel(column, row), Gem.Movement.FALL)
						gems[column][row] = gems[column][row_above]
						gems[column][row_above] = null
						break

func destroy_matches() -> void:
	for column in width:
		for row in height:
			if gems[column][row] != null:
				var check_gem: Gem = gems[column][row]
				if check_gem.matched == true:
					check_gem.queue_free()
					gems[column][row] = null
	($CollapseTimer as Timer).start()

func refill_columns() -> void:
	for column in width:
		for row in height:
			if gems[column][row] == null:
				var random_gem: int = get_random_gem(all_gems)
				var new_gem: Gem = all_gems[random_gem].instantiate()
				add_child(new_gem)
				new_gem.position = grid_to_pixel(column, row + 1)
				new_gem.move(grid_to_pixel(column, row), Gem.Movement.FALL)
				gems[column][row] = new_gem

func check_for_additional_matches() -> void:
	for column in width:
		for row in height:
			if gems[column][row] != null:
				var check_gem: Gem = gems[column][row]
				if match_at(Vector2(column, row), check_gem):
					state = States.WAIT
					find_matches()
					return
	state = States.PLAY
#endregion
