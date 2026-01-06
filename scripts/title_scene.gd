extends Control

@export var player: PlatformerPlayer
@export var menu: GameMenu
@export var logo: Control


func _ready() -> void:
	player.scripted_input = true
	player.x_input = 1.0
	player.player_state_changed.connect(func(old_state: PlatformerPlayer.PlayerState, _new_state: PlatformerPlayer.PlayerState):
		if old_state == PlatformerPlayer.PlayerState.FALLING:
			menu.show_menu(menu.top_menu)
			create_tween().tween_property(logo, "modulate:a", 1.0, 0.5)

			var bgm_path := "res://sounds/bgm_Grocery Store_ Calm Shop Game Music by HeatleyBros.mp3"

			if FileAccess.file_exists("user://bgm.mp3"):
				bgm_path = "user://bgm.mp3"

			GameWorld.play_bgm(bgm_path)
	)
	logo.modulate.a = 0

	create_tween().set_loops().tween_callback(func():
		if randf() > 0.5:
			player.emo_bubble.play_emo(3)
	).set_delay(5.0)
