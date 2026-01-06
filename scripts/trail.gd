extends Line2D

@export var target: Node2D


func _ready() -> void:
	position = Vector2.ZERO

	# Keep adding points
	create_tween().set_loops().tween_callback(func():
		add_point(target.global_position)
	).set_delay(0.05)

	# Keep removing points
	create_tween().tween_callback(func():
		create_tween().set_loops().tween_callback(func():
			remove_point(0)
		).set_delay(0.05)
	).set_delay(4.0)
