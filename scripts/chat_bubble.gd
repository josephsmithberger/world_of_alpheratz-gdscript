class_name ChatBubble
extends Label

@export var handle: Control

var is_playing: bool = false
var original_position: Vector2
var original_handle_position: Vector2


func _ready() -> void:
	hide()
	original_position = position
	original_handle_position = handle.position
	grow_vertical = Control.GROW_DIRECTION_BEGIN

	if has_node("/root/Console"):
		get_node("/root/Console").call("register_env", name + str(get_instance_id()), self)


func _physics_process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()

	var cam_half_w := get_viewport().get_visible_rect().size.x / cam.zoom.x / 2.0
	var left := cam.get_screen_center_position().x - cam_half_w
	var right := cam.get_screen_center_position().x + cam_half_w

	var chatbox_left_x := get_global_rect().position.x
	var target_x := clampf(chatbox_left_x, left, right - get_global_rect().size.x)

	global_position = Vector2(target_x, global_position.y)
	var hx := (original_handle_position + (original_position - position)).x
	handle.position = Vector2(hx, handle.position.y)


func play_text(text: String) -> void:
	if is_playing:
		push_error("ChatBubble is already playing.")
		return
	is_playing = true
	set_process(true)
	position = original_position + Vector2.DOWN * 16
	self.text = text
	visible_ratio = 0.0
	modulate.a = 0
	show()
	var tween := create_tween()
	tween.tween_property(self, "position", original_position, 0.4) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	tween.set_parallel(false)
	tween.set_parallel(true)
	tween.tween_property(self, "visible_ratio", 1.0, 0.02 * text.length())
	tween.set_parallel(false)
	tween.tween_interval(1.2)
	tween.tween_callback(func():
		hide()
		is_playing = false
		set_process(false)
	)


func _process(_delta: float) -> void:
	size = Vector2.ZERO
