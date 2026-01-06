class_name EmoBubble
extends Sprite2D

@export var _anim: AnimationPlayer


func play_emo(idx: int) -> void:
	frame = idx
	_anim.stop()
	_anim.play("pop")
