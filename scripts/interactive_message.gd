class_name InteractiveMessage
extends Area2D

signal message_activated

@export var offset: Vector2
@export var duration: float = 0.5
@export var target: Node2D

var init_position: Vector2
var is_active: bool = false


func _ready() -> void:
	init_position = target.position
	target.modulate.a = 0.0

	body_entered.connect(func(_body: Node2D):
		is_active = true
		pop_up()
	)

	body_exited.connect(func(_body: Node2D):
		is_active = false
		fade()
	)


func _physics_process(_delta: float) -> void:
	if is_active and Input.is_action_just_pressed("interact"):
		message_activated.emit()


func pop_up() -> void:
	var t := create_tween()
	t.set_parallel()
	t.tween_property(target, "position", init_position + offset, duration) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
	t.tween_property(target, "modulate:a", 1.0, duration) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)


func fade() -> void:
	var t := create_tween()
	t.set_parallel()
	t.tween_property(target, "position", init_position, duration) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
	t.tween_property(target, "modulate:a", 0.0, duration) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
