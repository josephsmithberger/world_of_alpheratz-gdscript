extends Node2D

@export var left_area: SpecialArea
@export var cam: LynxCamera
@export var rest: InteractiveMessage
@export var player: PlatformerPlayer
@export var npc2: PlatformerPlayer
@export var npc2_dialogue: Area2D
@export var npc3: PlatformerPlayer
@export var npc3_dialogue: Area2D
@export var next_level_portal: Area2D
@export var hud: HUD
@export var pause_menu: CanvasLayer
@export var cutscene_mode: CutsceneMode

var max_hearts: int = 3
var current_hearts: int = 3
var secrete_area_found_counter: int = 0
var coins: int = 0
var time_remain: int = 289

var _left_area_first_time: bool = false


func _ready() -> void:
	if GameWorld.has_meta("max_hearts"):
		max_hearts = GameWorld.get_meta("max_hearts")
		current_hearts = max_hearts

	GameWorld.play_bgm("res://sounds/bgm_farm_town.mp3")

	GameWorld.coin_collected.connect(_on_coin_collected)
	GameWorld.secrete_area_found.connect(_on_secrete_area_found)
	GameWorld.player_hurt.connect(_on_player_hurt)

	left_area.body_entered.connect(_on_left_area_body_entered)
	left_area.body_exited.connect(_on_left_area_body_exited)

	rest.message_activated.connect(_on_rest_activated, CONNECT_ONE_SHOT)

	create_tween().tween_callback(func():
		hud.set_hearts(current_hearts, max_hearts)
		hud.collected_coins.set_number(coins)
		hud.remain_time.set_number(time_remain)
	).set_delay(0.1)

	create_tween().set_loops().tween_callback(func():
		time_remain -= 1
		hud.remain_time.set_number(time_remain)
		if time_remain <= 0:
			GameWorld.change_scene("res://scenes/rest_scene.tscn")
	).set_delay(1.0)

	next_level_portal.body_entered.connect(func(_body: Node2D):
		GameWorld.change_scene("res://scenes/level_2_intro.tscn")
	)

	create_tween().tween_callback(func():
		player.chat_bubble.play_text("I have to hurry up!\nTwiggy is waiting for me.")
	).set_delay(2.0)

	_setup_npc2()
	_setup_npc3()


func _on_left_area_body_entered(_body: Node2D) -> void:
	cam.limit_left -= 1000
	if not _left_area_first_time:
		_left_area_first_time = true
		player.chat_bubble.play_text("Did I forget something\nat home?")


func _on_left_area_body_exited(_body: Node2D) -> void:
	cam.limit_left += 1000


func _on_rest_activated() -> void:
	print("[INFO] REST")
	GameWorld.play_bgm("", 0)
	GameWorld.change_scene("res://scenes/rest_scene.tscn")


func _on_player_hurt() -> void:
	current_hearts -= 1
	hud.set_hearts(current_hearts, max_hearts)
	if current_hearts <= 0:
		GameWorld.play_sfx("res://sounds/sfx_sounds_damage3.wav")
		player.collision_shape_2d.set_deferred("disabled", true)
		create_tween().tween_callback(func():
			GameWorld.change_scene("res://scenes/game_over_scene.tscn")
		).set_delay(1.0)


func _setup_npc2() -> void:
	var npc2_moves: int = 0
	var npc2_state: String = "idle"

	npc2_dialogue.body_entered.connect(func(_body: Node2D):
		cam.target = npc2
		npc2.set_meta("Zoom", Vector2.ONE * 3.5)

		cutscene_mode.enable_cutscene()

		npc2_state = "talking"
		var tween := create_tween()

		var on_cutscene_skipped: Callable
		on_cutscene_skipped = func():
			tween.kill()
			cam.target = player
			cutscene_mode.cutscene_skipped.disconnect(on_cutscene_skipped)
			cutscene_mode.disable_cutscene()
		cutscene_mode.cutscene_skipped.connect(on_cutscene_skipped)

		tween.tween_callback(func():
			npc2.chat_bubble.play_text("Good moring, Leia! ^_^")
		).set_delay(0.5)
		tween.tween_callback(func():
			npc2.chat_bubble.play_text("Are you going on your adventure again?")
		).set_delay(2.0)
		tween.tween_callback(func():
			npc2.chat_bubble.play_text("I hope to go with you.")
		).set_delay(2.0)
		tween.tween_callback(func():
			npc2.chat_bubble.play_text("but I'm a little scared of the grumpy\ncreatures ahead... :(")
		).set_delay(2.0)
		tween.tween_callback(func():
			npc2.chat_bubble.play_text("Wish you good luck! ^ ^")
		).set_delay(2.8)
		tween.tween_callback(func():
			player.chat_bubble.play_text("Thank you, Mr. Mochi.\nHave a nice day!")
		).set_delay(2.0)
		tween.tween_callback(func():
			npc2_state = "idle"
			cam.target = player
			cutscene_mode.disable_cutscene()
			cutscene_mode.cutscene_skipped.disconnect(on_cutscene_skipped)
		).set_delay(2.0)
		npc2_dialogue.queue_free()
	)

	create_tween().set_loops().tween_callback(func():
		if npc2_state == "idle":
			var rd := randf()
			if rd < 0.1 and npc2_moves > -3:
				npc2.x_input = -1
				npc2_moves -= 1
			elif rd < 0.2 and npc2_moves < 2:
				npc2.x_input = 1
				npc2_moves += 1
			else:
				npc2.x_input = 0
		elif npc2_state == "talking":
			npc2.x_input = 0
			var flip := (player.position.x - npc2.position.x) <= 0
			npc2.animated_sprite.flip_h = flip
	).set_delay(0.5)


func _setup_npc3() -> void:
	var npc3_state: String = ""

	npc3_dialogue.body_entered.connect(func(_body: Node2D):
		npc3_dialogue.queue_free()
		var tween := create_tween()
		tween.tween_callback(func():
			npc3.chat_bubble.play_text("Hi, Leia! ^_^")
		).set_delay(0.5)
		tween.tween_callback(func():
			npc3.chat_bubble.play_text("I've been waiting here for so long.")
		).set_delay(2.0)
		tween.tween_callback(func():
			npc3.chat_bubble.play_text("Finally you're here! Let's go!")
		).set_delay(2.0)
		if secrete_area_found_counter == 6:
			tween.tween_callback(func():
				npc3.chat_bubble.play_text("Wow, you found all the secret areas!")
			).set_delay(2.0)
			tween.tween_callback(func():
				npc3.emo_bubble.play_emo(2)
			).set_delay(2.0)
			tween.tween_callback(func():
				npc3.chat_bubble.play_text("I'm so proud of you! ^_^")
			).set_delay(2.0)
			tween.tween_callback(func():
				player.chat_bubble.play_text("Well, I'm just lucky.")
			).set_delay(2.0)
		tween.tween_callback(func():
			npc3_state = "walking"
			npc3.x_input = 1
			npc3.emo_bubble.play_emo(3)
		).set_delay(1.0)
	)

	create_tween().set_loops().tween_callback(func():
		if npc3_state != "walking":
			npc3.x_input = 0
			var flip := (player.position.x - npc3.position.x) <= 0
			npc3.animated_sprite.flip_h = flip
	).set_delay(0.5)


func _on_coin_collected() -> void:
	coins += 1
	hud.collected_coins.set_number(coins)


func _on_secrete_area_found() -> void:
	print("Secret area found!")
	GameWorld.play_sfx("res://sounds/sfx_sounds_fanfare1.wav")
	player.emo_bubble.play_emo(2)
	secrete_area_found_counter += 1
