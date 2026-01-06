class_name GameMenu
extends CanvasLayer

@export var top_menu: Control
@export var settings_menu: Control
@export var key_config_menu: Control
@export var start_button: Button
@export var settings_button: Button
@export var about_button: Button
@export var quit_button: Button
@export var settings_back_button: Button
@export var key_config_button: Button
@export var key_config_back_button: Button
@export var reset_keys_button: Button
@export var se_volume_slider: Slider
@export var bgm_volume_slider: Slider
@export var menu_opacity_slider: Slider
@export var window_scale_buttons: ButtonGroup
@export var reset_misc_button: Button
@export var background: ColorRect

@export var pause_menu_mode: bool = false

var menu_stack: Array[Control] = []
var current_menu: Control


func _ready() -> void:
	se_volume_slider.min_value = 0.0
	se_volume_slider.max_value = 1.0
	se_volume_slider.step = 0.1
	bgm_volume_slider.min_value = 0.0
	bgm_volume_slider.max_value = 1.0
	bgm_volume_slider.step = 0.1
	menu_opacity_slider.min_value = 0.0
	menu_opacity_slider.max_value = 1.0
	menu_opacity_slider.step = 0.1

	update_misc_config_ui()

	quit_button.pressed.connect(func():
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()
	)
	start_button.pressed.connect(func():
		GameWorld.change_scene("res://scenes/level_1_intro.tscn")
	)
	key_config_button.pressed.connect(func():
		show_menu(key_config_menu)
	)
	settings_button.pressed.connect(func():
		show_menu(settings_menu)
	)
	settings_back_button.pressed.connect(func():
		go_back()
	)
	key_config_back_button.pressed.connect(func():
		go_back()
	)
	start_button.focus_neighbor_top = quit_button.get_path()
	quit_button.focus_neighbor_bottom = start_button.get_path()
	about_button.pressed.connect(func():
		OS.shell_open("https://github.com/Ark2000/world_of_alpheratz")
	)

	reset_keys_button.pressed.connect(func():
		GameWorld.reset_keys()
		get_tree().call_group("remap_buttons", "update_state")
	)
	reset_misc_button.pressed.connect(func():
		GameWorld.reset_misc()
		update_misc_config_ui()
	)
	se_volume_slider.value_changed.connect(func(value: float):
		GameWorld.config_file.set_value(GameWorld.CONFIG_SECTION_MISC, GameWorld.MISC_SE, value)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	)
	bgm_volume_slider.value_changed.connect(func(value: float):
		GameWorld.config_file.set_value(GameWorld.CONFIG_SECTION_MISC, GameWorld.MISC_BGM, value)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear_to_db(value))
	)
	menu_opacity_slider.value_changed.connect(func(value: float):
		print("opa: ", value)
		GameWorld.config_file.set_value(GameWorld.CONFIG_SECTION_MISC, GameWorld.MISC_MENU_OPACITY, value)
		change_menu_panel_opacity(value)
	)
	window_scale_buttons.pressed.connect(func(button: BaseButton):
		print(button.name)
		var value := int(button.name)
		GameWorld.config_file.set_value(GameWorld.CONFIG_SECTION_MISC, GameWorld.MISC_WINDOW_SCALE, value)
		GameWorld.apply_resolution()
	)
	hide_all()

	if pause_menu_mode:
		process_mode = Node.PROCESS_MODE_ALWAYS
		hide()
		show_menu(top_menu)
	background.visible = pause_menu_mode


func hide_all() -> void:
	top_menu.hide()
	settings_menu.hide()
	key_config_menu.hide()


func show_menu(menu: Control, go_back_flag: bool = false) -> void:
	if menu == current_menu:
		return
	current_menu = menu

	hide_all()
	menu.show()
	menu.scale = Vector2(menu.scale.x, 0.5)
	var tween := create_tween().set_parallel() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)
	tween.tween_property(menu, "scale:y", 1.0, 0.2)
	create_tween().tween_callback(func():
		if menu == top_menu:
			start_button.grab_focus()
	).set_delay(0.1)

	if not go_back_flag:
		menu_stack.push_back(menu)


func change_menu_panel_opacity(value: float) -> void:
	var style_box: StyleBoxFlat = top_menu.get("theme_override_styles/panel")
	style_box.shadow_color.a = value


func go_back() -> bool:
	var is_last := false
	if menu_stack.size() > 1:
		menu_stack.pop_back()
		show_menu(menu_stack.back(), true)
		is_last = true
	return is_last


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if not go_back() and pause_menu_mode:
			get_tree().paused = not get_tree().paused
			visible = get_tree().paused
			if get_tree().paused:
				GameWorld.play_sfx("res://sounds/sfx_sounds_pause4_in.wav")
			else:
				GameWorld.play_sfx("res://sounds/sfx_sounds_pause4_out.wav")


func update_misc_config_ui() -> void:
	se_volume_slider.value = GameWorld.config_file.get_value(GameWorld.CONFIG_SECTION_MISC, GameWorld.MISC_SE)
	bgm_volume_slider.value = GameWorld.config_file.get_value(GameWorld.CONFIG_SECTION_MISC, GameWorld.MISC_BGM)
	menu_opacity_slider.value = GameWorld.config_file.get_value(GameWorld.CONFIG_SECTION_MISC, GameWorld.MISC_MENU_OPACITY)
	change_menu_panel_opacity(menu_opacity_slider.value)
	var window_scale: int = GameWorld.config_file.get_value(GameWorld.CONFIG_SECTION_MISC, GameWorld.MISC_WINDOW_SCALE)
	window_scale_buttons.get_buttons()[window_scale - 1].button_pressed = true
