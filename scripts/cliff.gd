class_name Cliff
extends Area2D

@export var respawn_location: Node2D


func _ready() -> void:
	body_entered.connect(func(body: Node2D):
		var player := body as PlatformerPlayer
		player.global_position = respawn_location.global_position
		player.hurt(0.0, 100.0)
	)
