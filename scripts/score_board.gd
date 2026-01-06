class_name ScoreBoard
extends HBoxContainer

@export var number1: TextureRect
@export var number2: TextureRect
@export var number3: TextureRect

var atlas_regions := {
	0: Rect2(16, 0, 8, 8),
	1: Rect2(24, 0, 8, 8),
	2: Rect2(32, 0, 8, 8),
	3: Rect2(40, 0, 8, 8),
	4: Rect2(48, 0, 8, 8),
	5: Rect2(16, 8, 8, 8),
	6: Rect2(24, 8, 8, 8),
	7: Rect2(32, 8, 8, 8),
	8: Rect2(40, 8, 8, 8),
	9: Rect2(48, 8, 8, 8),
}


func _ready() -> void:
	number1.pivot_offset = number1.size / 2.0
	number2.pivot_offset = number2.size / 2.0
	number3.pivot_offset = number3.size / 2.0


func set_number(number: int) -> void:
	number = clampi(number, 0, 999)

	var hundreds := number / 100
	var tens := (number - hundreds * 100) / 10
	var ones := number - hundreds * 100 - tens * 10

	var atlas_texture: AtlasTexture = number1.texture as AtlasTexture
	if atlas_texture.region != atlas_regions[hundreds]:
		_bouncy_animation(number1)
		atlas_texture.region = atlas_regions[hundreds]

	atlas_texture = number2.texture as AtlasTexture
	if atlas_texture.region != atlas_regions[tens]:
		_bouncy_animation(number2)
		atlas_texture.region = atlas_regions[tens]

	atlas_texture = number3.texture as AtlasTexture
	if atlas_texture.region != atlas_regions[ones]:
		_bouncy_animation(number3)
		atlas_texture.region = atlas_regions[ones]


func _bouncy_animation(control: Control) -> void:
	var tween := create_tween()
	tween.tween_property(control, "scale", Vector2.ONE * 1.25, 0.1)
	tween.tween_property(control, "scale", Vector2.ONE * 1.0, 0.1)
