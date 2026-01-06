class_name Killer
extends Area2D

signal mob_hurt


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is PlatformerPlayer:
		var player := body as PlatformerPlayer
		player.hurt()
	if body is Mob:
		var mob := body as Mob
		mob.perish()
		mob_hurt.emit()
		GameWorld.play_sfx("res://sounds/sfx_movement_jump17_landing.wav")
		print("[INFO] Mob Perished!")
