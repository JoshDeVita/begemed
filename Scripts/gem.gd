class_name Gem
extends Node2D

enum Type {Null, Blue, Red, Purple, Yellow, White, Green}
@export var GemColor: Type
var Matched: bool = false

func Move(target: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	tween.play()

func Dim() -> void:
	var Sprite: Sprite2D = $Sprite2D
	Sprite.modulate = Color(1, 1, 1, .5)
	
