extends AnimatedSprite2D


func _ready() -> void:
	var frames_count := sprite_frames.get_frame_count(animation)
	frame = randi_range(0, frames_count - 1)
