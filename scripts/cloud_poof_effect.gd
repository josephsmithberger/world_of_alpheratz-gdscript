class_name CloudPoofEffect
extends AnimatedSprite2D


func _ready() -> void:
	GameWorld.play_sfx("res://sounds/sfx_sounds_impact11.wav")
	animation_finished.connect(func():
		print("[INFO] " + name + " animation finished")
		queue_free()
	)
