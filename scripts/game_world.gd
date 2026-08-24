extends Node

signal coin_collected
signal player_hurt
signal secrete_area_found

const CONFIG_FILE_PATH := "user://config.cfg"
const CONFIG_SECTION_KEYBINDINGS := "keybindings"
const INPUT_ACTION_UP := "up"
const INPUT_ACTION_DOWN := "down"
const INPUT_ACTION_LEFT := "left"
const INPUT_ACTION_RIGHT := "right"
const INPUT_ACTION_INTERACT := "interact"
const CONFIG_SECTION_MISC := "misc"
const MISC_SE := "se_volume"
const MISC_BGM := "bgm_volume"
const MISC_MENU_OPACITY := "menu_opacity"
const MISC_WINDOW_SCALE := "window_scale"

var default_keybindings := {
	INPUT_ACTION_UP: KEY_W,
	INPUT_ACTION_DOWN: KEY_S,
	INPUT_ACTION_LEFT: KEY_A,
	INPUT_ACTION_RIGHT: KEY_D,
	INPUT_ACTION_INTERACT: KEY_E,
}

var color_rect: ColorRect
var bgm_player1: AudioStreamPlayer
var bgm_player2: AudioStreamPlayer
var config_file := ConfigFile.new()


func _ready() -> void:
	load_config()

	var key_event := InputEventKey.new()
	key_event.keycode = KEY_W
	key_event.pressed = true
	InputMap.add_action("test_action")
	InputMap.action_add_event("test_action", key_event)

	color_rect = ColorRect.new()
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.color = Color(1.0, 1.0, 1.0, 0.0)
	add_child(color_rect)

	bgm_player1 = AudioStreamPlayer.new()
	bgm_player1.bus = "BGM"
	bgm_player2 = AudioStreamPlayer.new()
	bgm_player2.bus = "BGM"
	add_child(bgm_player1)
	add_child(bgm_player2)

	print("[INFO] Game start!")


func play_bgm(bgm_path: String, fade_time: float = 0.6) -> void:
	var new_bgm: AudioStream = null

	if not bgm_path.is_empty():
		if bgm_path.begins_with("res://"):
			new_bgm = load(bgm_path)
		if bgm_path.begins_with("user://"):
			var file := FileAccess.open(bgm_path, FileAccess.READ)
			var stream_mp3 := AudioStreamMP3.new()
			stream_mp3.data = file.get_buffer(file.get_length())
			new_bgm = stream_mp3

	# Swap players
	var temp := bgm_player1
	bgm_player1 = bgm_player2
	bgm_player2 = temp

	bgm_player1.stream = new_bgm
	bgm_player1.play()

	var tween := create_tween().set_parallel()
	tween.tween_method(_set_volume_db.bind(bgm_player1), 0.0, 1.0, fade_time)
	tween.tween_method(_set_volume_db.bind(bgm_player2), 1.0, 0.0, fade_time)


func _set_volume_db(linear_db: float, player: AudioStreamPlayer) -> void:
	player.volume_db = linear_to_db(linear_db)


func play_sfx(sfx_path: String, pitch: float = 1.0, volume_scale: float = 1.0) -> void:
	var sfx_player := AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.stream = load(sfx_path)
	sfx_player.pitch_scale = pitch
	sfx_player.volume_db = linear_to_db(volume_scale)
	sfx_player.bus = "SFX"
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)


func spawn_cloud_poof_effect(global_position: Vector2, centered: bool = true) -> void:
	var cloud_poof_effect := preload("res://scenes/cloud_poof_effect.tscn")
	var effect: Node2D = cloud_poof_effect.instantiate()
	effect.position = global_position
	if not centered:
		effect.position += Vector2.ONE * 8.0
	get_tree().root.add_child(effect)
	print("[INFO] Spawned cloud poof effect at " + str(global_position))


func change_scene(next_scene_path: String, duration: float = 0.4) -> void:
	color_rect.color = Color(1.0, 1.0, 1.0, 0.0)
	var tween := create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, duration)
	tween.tween_callback(func(): get_tree().change_scene_to_file(next_scene_path))
	tween.tween_interval(duration)
	tween.tween_property(color_rect, "color:a", 0.0, duration)


func load_config() -> void:
	var err := config_file.load(CONFIG_FILE_PATH)

	if err != OK:
		# Apply default configs
		for action in default_keybindings:
			config_file.set_value(CONFIG_SECTION_KEYBINDINGS, action, default_keybindings[action])
		reset_misc()

	# Apply keybindings
	var key_event: InputEventKey

	key_event = InputEventKey.new()
	key_event.keycode = config_file.get_value(CONFIG_SECTION_KEYBINDINGS, INPUT_ACTION_UP)
	key_event.pressed = true
	InputMap.add_action(INPUT_ACTION_UP)
	InputMap.action_add_event(INPUT_ACTION_UP, key_event)
	InputMap.action_add_event("ui_up", key_event)

	key_event = InputEventKey.new()
	key_event.keycode = config_file.get_value(CONFIG_SECTION_KEYBINDINGS, INPUT_ACTION_DOWN)
	key_event.pressed = true
	InputMap.add_action(INPUT_ACTION_DOWN)
	InputMap.action_add_event(INPUT_ACTION_DOWN, key_event)
	InputMap.action_add_event("ui_down", key_event)

	key_event = InputEventKey.new()
	key_event.keycode = config_file.get_value(CONFIG_SECTION_KEYBINDINGS, INPUT_ACTION_LEFT)
	key_event.pressed = true
	InputMap.add_action(INPUT_ACTION_LEFT)
	InputMap.action_add_event(INPUT_ACTION_LEFT, key_event)
	InputMap.action_add_event("ui_left", key_event)

	key_event = InputEventKey.new()
	key_event.keycode = config_file.get_value(CONFIG_SECTION_KEYBINDINGS, INPUT_ACTION_RIGHT)
	key_event.pressed = true
	InputMap.add_action(INPUT_ACTION_RIGHT)
	InputMap.action_add_event(INPUT_ACTION_RIGHT, key_event)
	InputMap.action_add_event("ui_right", key_event)

	key_event = InputEventKey.new()
	key_event.keycode = config_file.get_value(CONFIG_SECTION_KEYBINDINGS, INPUT_ACTION_INTERACT)
	key_event.pressed = true
	InputMap.add_action(INPUT_ACTION_INTERACT)
	InputMap.action_add_event(INPUT_ACTION_INTERACT, key_event)

	_apply_controller_bindings()

	apply_resolution()

	# Apply sound settings
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear_to_db(config_file.get_value(CONFIG_SECTION_MISC, MISC_BGM)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(config_file.get_value(CONFIG_SECTION_MISC, MISC_SE)))


func _apply_controller_bindings() -> void:
	# UI actions already receive Godot's default gamepad mappings. Gameplay uses
	# separate actions, so explicitly give those actions equivalent controller input.
	_add_controller_button(INPUT_ACTION_LEFT, JOY_BUTTON_DPAD_LEFT)
	_add_controller_button(INPUT_ACTION_RIGHT, JOY_BUTTON_DPAD_RIGHT)
	_add_controller_button(INPUT_ACTION_DOWN, JOY_BUTTON_DPAD_DOWN)
	_add_controller_axis(INPUT_ACTION_LEFT, JOY_AXIS_LEFT_X, -1.0)
	_add_controller_axis(INPUT_ACTION_RIGHT, JOY_AXIS_LEFT_X, 1.0)
	_add_controller_axis(INPUT_ACTION_UP, JOY_AXIS_LEFT_Y, -1.0)
	_add_controller_axis(INPUT_ACTION_DOWN, JOY_AXIS_LEFT_Y, 1.0)

	# A / Cross is the platformer jump button; X / Square is used to interact.
	_add_controller_button(INPUT_ACTION_UP, JOY_BUTTON_A)
	_add_controller_button(INPUT_ACTION_INTERACT, JOY_BUTTON_X)


func _add_controller_button(input_action: StringName, button: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	event.pressed = true
	InputMap.action_add_event(input_action, event)


func _add_controller_axis(input_action: StringName, axis: JoyAxis, axis_value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	InputMap.action_add_event(input_action, event)


func apply_resolution() -> void:
	var window_scale: int = config_file.get_value(CONFIG_SECTION_MISC, MISC_WINDOW_SCALE)
	DisplayServer.window_set_size(Vector2i(432, 312) * window_scale)


func reset_misc() -> void:
	config_file.set_value(CONFIG_SECTION_MISC, MISC_SE, 0.6)
	config_file.set_value(CONFIG_SECTION_MISC, MISC_BGM, 0.6)
	config_file.set_value(CONFIG_SECTION_MISC, MISC_MENU_OPACITY, 0.5)
	config_file.set_value(CONFIG_SECTION_MISC, MISC_WINDOW_SCALE, 1)


func reset_keys() -> void:
	for action in default_keybindings:
		remap_key(action, default_keybindings[action])


func remap_key(input_action: String, new_key: Key) -> void:
	if not InputMap.has_action(input_action):
		push_error("Input action " + input_action + " does not exist!")
		return

	var event_key := InputEventKey.new()
	event_key.keycode = new_key
	event_key.pressed = true
	InputMap.action_erase_event(input_action, InputMap.action_get_events(input_action)[0])
	InputMap.action_add_event(input_action, event_key)

	# Remap UI actions
	if input_action == INPUT_ACTION_UP:
		print(InputMap.action_get_events("ui_up"))
		var events := InputMap.action_get_events("ui_up")
		InputMap.action_erase_event("ui_up", events[events.size() - 1])
		InputMap.action_add_event("ui_up", event_key)
	elif input_action == INPUT_ACTION_DOWN:
		var events := InputMap.action_get_events("ui_down")
		InputMap.action_erase_event("ui_down", events[events.size() - 1])
		InputMap.action_add_event("ui_down", event_key)
	elif input_action == INPUT_ACTION_LEFT:
		var events := InputMap.action_get_events("ui_left")
		InputMap.action_erase_event("ui_left", events[events.size() - 1])
		InputMap.action_add_event("ui_left", event_key)
	elif input_action == INPUT_ACTION_RIGHT:
		var events := InputMap.action_get_events("ui_right")
		InputMap.action_erase_event("ui_right", events[events.size() - 1])
		InputMap.action_add_event("ui_right", event_key)

	config_file.set_value(CONFIG_SECTION_KEYBINDINGS, input_action, new_key)


func save_config() -> void:
	config_file.save(CONFIG_FILE_PATH)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_config()
