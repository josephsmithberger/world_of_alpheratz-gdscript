class_name RemapButton
extends Button

@export var input_action: String


func _ready() -> void:
	update_state()
	set_process_unhandled_key_input(false)
	toggled.connect(_on_button_toggled)
	add_to_group("remap_buttons")


func update_state() -> void:
	var key: Key = GameWorld.config_file.get_value(GameWorld.CONFIG_SECTION_KEYBINDINGS, input_action)
	text = "Key " + OS.get_keycode_string(key)


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	button_pressed = false
	text = "Key " + OS.get_keycode_string(key_event.keycode)
	GameWorld.remap_key(input_action, key_event.keycode)


func _on_button_toggled(is_button_pressed: bool) -> void:
	set_process_unhandled_key_input(is_button_pressed)
	if is_button_pressed:
		text = "Press a key"
	else:
		release_focus()
