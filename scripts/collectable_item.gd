class_name CollectableItem
extends Area2D

@export var collision_shape_2d: CollisionShape2D

static var coin_count: int = 0
static var last_coin_time_ms: int = 0


func _ready() -> void:
	body_entered.connect(_collected)


func _collected(_body: Node2D) -> void:
	var delta_ms := Time.get_ticks_msec() - last_coin_time_ms
	var sfx_delay: float = 0
	var min_interval: int = 60
	if delta_ms < min_interval:
		sfx_delay = (min_interval - delta_ms) * 0.001
		last_coin_time_ms += min_interval
	else:
		last_coin_time_ms = Time.get_ticks_msec()

	create_tween().tween_callback(func():
		GameWorld.play_sfx("res://sounds/sfx_coin_double4.wav", coin_count % 10 * 0.1 + 1.0)
		if coin_count % 10 == 0:
			GameWorld.play_sfx("res://sounds/sfx_coin_cluster5.wav")
	).set_delay(sfx_delay)

	coin_count += 1

	GameWorld.coin_collected.emit()
	collision_shape_2d.queue_free()
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position", position + Vector2.UP * 32.0, 1.0) \
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_delay(0.5)
	tween.set_speed_scale(2.0)
	tween.finished.connect(queue_free)
