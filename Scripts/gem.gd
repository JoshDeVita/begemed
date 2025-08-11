class_name Gem
extends Node2D

enum Type {Null, Blue, Red, Purple, Yellow, White, Green}
enum Movement {Swap, Fall}
@export var GemColor: Type
var Matched: bool = false

func Move(target: Vector2, MoveType: Movement) -> void:
	var tween: Tween = create_tween()
	var transition: Tween.TransitionType = Tween.TransitionType.TRANS_SINE
	var ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
	var duration: float = .5
	match MoveType:
		Movement.Swap:
			transition = Tween.TransitionType.TRANS_BACK
			ease = Tween.EaseType.EASE_IN_OUT
			duration = .4
		Movement.Fall:
			transition = Tween.TransitionType.TRANS_QUAD
			ease = Tween.EaseType.EASE_IN_OUT
			duration = .45
	tween.tween_property(self, "position", target, duration).set_trans(transition).set_ease(ease)
	tween.play()

func Dim() -> void:
	var Sprite: Sprite2D = $Sprite2D
	Sprite.modulate = Color(1, 1, 1, .5)
	
