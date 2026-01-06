class_name HUD
extends CanvasLayer

@export var heart_proto: Control
@export var heart_container: Container
@export var remain_time: ScoreBoard
@export var collected_coins: ScoreBoard


func _ready() -> void:
	heart_proto.hide()
	for i in range(heart_container.get_child_count()):
		heart_container.get_child(i).queue_free()


func set_hearts(hearts: int, max_hearts_count: int) -> void:
	var heart_count := heart_container.get_child_count()
	if max_hearts_count > heart_count:
		for i in range(max_hearts_count - heart_count):
			var heart := heart_proto.duplicate() as Control
			heart.show()
			heart_container.add_child(heart)
	elif max_hearts_count < heart_count:
		for i in range(1, heart_count - max_hearts_count + 1):
			heart_container.get_child(heart_container.get_child_count() - i).queue_free()
			print("[INFO] QueueFree: %d" % (heart_container.get_child_count() - i))

	for i in range(max_hearts_count):
		var heart := heart_container.get_child(i) as Control
		var full_heart := heart.get_child(0) as Control
		full_heart.visible = i < hearts
