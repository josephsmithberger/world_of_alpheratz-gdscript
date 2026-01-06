class_name LynxCamera
extends Camera2D

@export var target: Node2D

var original_zoom: Vector2


func _ready() -> void:
	original_zoom = zoom


func _physics_process(_delta: float) -> void:
	var pos := target.global_position

	if target is PlatformerPlayer:
		var player := target as PlatformerPlayer
		pos += Vector2(-32, 0) if player.animated_sprite.flip_h else Vector2(32, 0)

		if not player.is_on_floor() and player.velocity.y < player.MAX_FALL_SPEED:
			pos = Vector2(pos.x, position.y)

	var target_zoom: Vector2 = target.get_meta("Zoom", original_zoom)

	position = position.lerp(pos, 0.172)
	zoom = zoom.lerp(target_zoom, 0.041)
