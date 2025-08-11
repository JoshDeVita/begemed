extends Node2D

@export var Height: int
@export var Width: int
@export var XStart: int
@export var YStart: int
@export var Offset: int

#region Class variables
enum Directions {West, East, North, South}
var Direction: Dictionary[Directions, Vector2] = {
	Directions.West: Vector2(-1, 0),
	Directions.East: Vector2(1, 0),
	Directions.North: Vector2(0, 1),
	Directions.South: Vector2(0, -1),
}

var Gems: Array[Array]
var AllGems: Array[PackedScene] = [
	preload("res://Gems/blue_gem.tscn"),
	preload("res://Gems/red_gem.tscn"),
	preload("res://Gems/purple_gem.tscn"),
	preload("res://Gems/yellow_gem.tscn"),
	preload("res://Gems/white_gem.tscn"),
	preload("res://Gems/green_gem.tscn")
]

var FirstMove: Vector2
var SecondMove: Vector2
var ActiveMove: bool
#endregion

func _ready() -> void:
	Gems = GenerateArray()
	SpawnPieces()

func _process(delta: float) -> void:
	ClickInput()

#region Startup
func SpawnPieces() -> void:
	for Column in Width:
		for Row in Height:
			var GemList: Array[PackedScene] = AllGems.duplicate()
			var RandomGem: int = GetRandomGem(GemList)
			var NewGem: Gem = GemList[RandomGem].instantiate()
			while MatchAt(Vector2(Column, Row), NewGem):
				GemList.remove_at(RandomGem)
				RandomGem = GetRandomGem(GemList)
				NewGem = GemList[RandomGem].instantiate()
			add_child(NewGem)
			NewGem.position = GridToPixel(Column, Row)
			Gems[Column][Row] = NewGem

func GenerateArray() -> Array[Array]:
	var array: Array[Array]
	for Column in Width:
		array.append([])
		for Row in Height:
			array[Column].append(null)
	return array
#endregion

func GetRandomGem(List: Array) -> int:
	return randi() % List.size()

#region Coordinates
func GridToPixel(Column: int, Row: int) -> Vector2:
	var NewX: int = XStart + (Offset * Column)
	var NewY: int = YStart + (-Offset * Row)
	return Vector2(NewX, NewY)

func PixelToGrid(Vector: Vector2) -> Vector2:
	var NewX: int = round((Vector.x - XStart) / Offset)
	var NewY: int = round((Vector.y - YStart) / -Offset)
	return Vector2(NewX, NewY)

func IsInBounds(Position:Vector2) -> bool:
	if Position.x >= 0 and Position.y >= 0 and Position.x < Width and Position.y < Height:
		return true
	return false

func ClickInput() -> void:
	if ActiveMove == false and Input.is_action_just_pressed("ui_left_click"):
		StartMove()
	elif ActiveMove == true and Input.is_action_just_pressed("ui_left_click"):
		FinishMove()
	#if ActiveMove == true and Input.is_action_just_released("ui_left_click"):
		#FinishMove()
#endregion

#region Swapping
func StartMove() -> void:
	var GridPosition: Vector2
	FirstMove = get_global_mouse_position()
	GridPosition = PixelToGrid(FirstMove)
	if IsInBounds(GridPosition):
		ActiveMove = true
	else:
		ActiveMove = false

func FinishMove() -> void:
	var GridPosition: Vector2
	SecondMove = get_global_mouse_position()
	GridPosition = PixelToGrid(SecondMove)
	if ActiveMove and IsInBounds(GridPosition) and GridPosition != PixelToGrid(FirstMove):
		AttemptSwap(PixelToGrid(FirstMove), GridPosition)
	ActiveMove = false

func AttemptSwap(GridPosition1: Vector2, GridPosition2: Vector2) -> void:
	var Delta: Vector2 = GridPosition2 - GridPosition1
	if abs(Delta.x) > abs(Delta.y):
		if Delta.x == 1:
			Swap(GridPosition1, Direction[Directions.East])
		elif Delta.x == -1:
			Swap(GridPosition1, Direction[Directions.West])
	elif abs(Delta.y) > abs(Delta.x):
		if Delta.y == 1:
			Swap(GridPosition1, Direction[Directions.North])
		elif Delta.y == -1:
			Swap(GridPosition1, Direction[Directions.South])

func Swap(Position: Vector2, Direction: Vector2) -> void:
	var Gem1Position: Vector2 = Vector2(Position.x, Position.y)
	var Gem2Position: Vector2 = Vector2(Position.x + Direction.x, Position.y + Direction.y)
	if Gems[Gem1Position.x][Gem1Position.y] == null || Gems[Gem2Position.x][Gem2Position.y] == null:
		return
	var Gem1: Gem = Gems[Gem1Position.x][Gem1Position.y]
	var Gem2: Gem = Gems[Gem2Position.x][Gem2Position.y]
	Gems[Gem1Position.x][Gem1Position.y] = Gem2
	Gems[Gem2Position.x][Gem2Position.y] = Gem1
	Gem1.Move(GridToPixel(Gem2Position.x, Gem2Position.y), Gem.Movement.Swap)
	Gem2.Move(GridToPixel(Gem1Position.x, Gem1Position.y), Gem.Movement.Swap)
	FindMatches()
#endregion

#region Matches
func FindMatches() -> void:
	for Column in Width:
		for Row in Height:
			var Position: Vector2 = Vector2(Column, Row)
			if Gems[Position.x][Position.y] != null:
				var CheckGem: Gem = Gems[Position.x][Position.y]
				if CheckGem.Matched == false:
					var MatchList: Array[Vector2] = [Position]
					MatchList.append_array(GetMatchesInDirection(Position, Direction[Directions.East], CheckGem))
					MatchList.append_array(GetMatchesInDirection(Position, Direction[Directions.West], CheckGem))
					CountMatches(MatchList)
					MatchList = [Position]
					MatchList.append_array(GetMatchesInDirection(Position, Direction[Directions.North], CheckGem))
					MatchList.append_array(GetMatchesInDirection(Position, Direction[Directions.South], CheckGem))
					CountMatches(MatchList)

func MatchAt(Position: Vector2, CheckGem: Gem) -> bool:
	var MatchList: Array[Vector2] = [Position]
	MatchList.append_array(GetMatchesInDirection(Position, Direction[Directions.East], CheckGem))
	MatchList.append_array(GetMatchesInDirection(Position, Direction[Directions.West], CheckGem))
	if MatchList.size() >= 3:
		return true
	MatchList = [Position]
	MatchList.append_array(GetMatchesInDirection(Position, Direction[Directions.North], CheckGem))
	MatchList.append_array(GetMatchesInDirection(Position, Direction[Directions.South], CheckGem))
	if MatchList.size() >= 3:
		return true
	return false

func GetMatchesInDirection(Position: Vector2, Direction: Vector2, InputGem: Gem) -> Array[Vector2]:
	var List: Array[Vector2] = []
	var CheckPosition: Vector2 = Vector2(Position.x, Position.y)
	var CheckGem: Gem = InputGem.duplicate()
	var GemColor: Gem.Type = CheckGem.GemColor
	while CheckGem.GemColor == GemColor and IsInBounds(CheckPosition) :
		CheckPosition += Direction
		if IsInBounds(CheckPosition) and Gems[CheckPosition.x][CheckPosition.y] != null:
			CheckGem = Gems[CheckPosition.x][CheckPosition.y]
			if CheckGem.GemColor == GemColor:
				List.append(CheckPosition)
		else:
			return List
	return List

func CountMatches(List: Array[Vector2]) -> void:
	if List.size() >= 3:
		for v in List:
			var MatchedGem: Gem = Gems[v.x][v.y]
			MatchedGem.Matched = true
		var DestroyTimer: Timer = $DestroyTimer
		DestroyTimer.start()

func DestroyMatches() -> void:
	for Column in Width:
		for Row in Height:
			if Gems[Column][Row] != null:
				var CheckGem: Gem = Gems[Column][Row]
				if CheckGem.Matched == true:
					CheckGem.queue_free()
					Gems[Column][Row] = null
	var CollapseTimer: Timer = $CollapseTimer
	CollapseTimer.start()
#endregion

func CollapseColumns() -> void:
	for Column in Width:
		for Row in Height:
			if Gems[Column][Row] == null:
				for RowAbove in range(Row + 1, Height):
					if Gems[Column][RowAbove] != null:
						var FallingGem: Gem = Gems[Column][RowAbove]
						FallingGem.Move(GridToPixel(Column, Row), Gem.Movement.Fall)
						Gems[Column][Row] = Gems[Column][RowAbove]
						Gems[Column][RowAbove] = null
						break

func _on_destroy_timer_timeout() -> void:
	DestroyMatches()

func _on_collapse_timer_timeout() -> void:
	CollapseColumns()
