extends Control


func _ready() -> void:
	create_tween().tween_callback(func():
		GameWorld.change_scene("res://scenes/title_scene.tscn")
	).set_delay(1.0)
