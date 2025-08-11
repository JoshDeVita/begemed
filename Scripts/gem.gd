class_name Gem
extends Node2D

enum Type {NULL, BLUE, RED, PURPLE, YELLOW, WHITE, GREEN}
enum Movement {SWAP, FALL}
const SWAP_TIME: float = 0.4
const FALL_TIME: float = 0.45

@export var gem_color: Type
var matched: bool = false


func _ready() -> void:
	modulate = Color(1, 1, 1, 0)
	fade_in()

func move(target: Vector2, MoveType: Movement) -> void:
	var tween: Tween = create_tween()
	# below default values should never be used, just as backup
	var transition: Tween.TransitionType = Tween.TransitionType.TRANS_SINE
	var easing: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
	var duration: float = 0.5
	match MoveType:
		Movement.SWAP:
			transition = Tween.TransitionType.TRANS_BACK
			easing = Tween.EaseType.EASE_IN_OUT
			duration = SWAP_TIME
		Movement.FALL:
			transition = Tween.TransitionType.TRANS_QUAD
			easing = Tween.EaseType.EASE_IN_OUT
			duration = FALL_TIME
	tween.tween_property(self, "position", target, duration).set_trans(transition).set_ease(easing)
	tween.play()

func fade_in() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)
	tween.play()
