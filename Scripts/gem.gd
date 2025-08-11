class_name Gem
extends Node2D

enum Type {NULL, BLUE, RED, PURPLE, YELLOW, WHITE, GREEN}
enum Movement {SWAP, FALL}
@export var gem_color: Type
var matched: bool = false

func move(target: Vector2, MoveType: Movement) -> void:
	var tween: Tween = create_tween()
	var transition: Tween.TransitionType = Tween.TransitionType.TRANS_SINE
	var easing: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
	var duration: float = .5
	match MoveType:
		Movement.SWAP:
			transition = Tween.TransitionType.TRANS_BACK
			easing = Tween.EaseType.EASE_IN_OUT
			duration = .4
		Movement.FALL:
			transition = Tween.TransitionType.TRANS_QUAD
			easing = Tween.EaseType.EASE_IN_OUT
			duration = .45
	tween.tween_property(self, "position", target, duration).set_trans(transition).set_ease(easing)
	tween.play()
