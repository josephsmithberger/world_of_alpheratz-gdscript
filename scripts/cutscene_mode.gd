class_name CutsceneMode
extends CanvasLayer

signal cutscene_skipped

@export var top_bar: Control
@export var bottom_bar: Control

var current_tweens: Array[Tween] = []


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(GameWorld.INPUT_ACTION_INTERACT):
		cutscene_skipped.emit()


func _ready() -> void:
	hide()
	set_process_input(false)


func enable_cutscene() -> void:
	show()
	set_process_input(true)

	clear_tweens()

	bottom_bar.offset_bottom = bottom_bar.size.y
	top_bar.offset_top = -top_bar.size.y
	var t1 := create_tween()
	t1.tween_property(bottom_bar, "offset_bottom", 0.0, 1.0)
	var t2 := create_tween()
	t2.tween_property(top_bar, "offset_top", 0.0, 1.0)
	current_tweens.append(t1)
	current_tweens.append(t2)


func disable_cutscene() -> void:
	set_process_input(false)

	clear_tweens()

	var t1 := create_tween()
	t1.tween_property(bottom_bar, "offset_bottom", bottom_bar.size.y, 1.0)
	var t2 := create_tween()
	t2.tween_property(top_bar, "offset_top", -top_bar.size.y, 1.0)


func clear_tweens() -> void:
	for tween in current_tweens:
		tween.kill()
	current_tweens.clear()
