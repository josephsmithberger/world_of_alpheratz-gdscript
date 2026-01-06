class_name SpecialArea
extends Area2D

@export var cam: LynxCamera
@export var camera_focus: Node2D


func _ready() -> void:
	body_entered.connect(func(_body: Node2D):
		cam.target = camera_focus
	)
	body_exited.connect(func(body: Node2D):
		cam.target = body
	)
