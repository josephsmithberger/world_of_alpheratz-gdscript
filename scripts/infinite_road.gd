extends Node2D

@export var chunk_size: int = 1008
@export var chunk_proto: Node2D

var loaded_chunks: Dictionary = {}


func _ready() -> void:
	create_tween().set_loops().tween_callback(func():
		var cam := get_viewport().get_camera_2d()
		if cam == null:
			return
		var cam_half_w := get_viewport().get_visible_rect().size.x / cam.zoom.x / 2.0
		var left := cam.get_screen_center_position().x - cam_half_w
		var right := cam.get_screen_center_position().x + cam_half_w
		update_chunks(int(left), int(right))
	).set_delay(0.2)


func load_chunk(chunk_id: int) -> Node:
	print("Load ", chunk_id)
	var new_chunk := chunk_proto.duplicate() as Node2D
	chunk_proto.get_parent().add_child(new_chunk)
	new_chunk.position = Vector2(chunk_id * chunk_size, 0)
	new_chunk.show()
	return new_chunk


func unload_chunk(chunk_id: int) -> void:
	print("Unload ", chunk_id)
	var unwanted_chunk := loaded_chunks[chunk_id] as Node2D
	unwanted_chunk.queue_free()


func update_chunks(left: int, right: int) -> void:
	var left_id := left / chunk_size
	var right_id := right / chunk_size

	# Load new chunks
	for i in range(left_id, right_id + 1):
		if not loaded_chunks.has(i):
			load_chunk(i)
			loaded_chunks[i] = load_chunk(i)

	# Unload unwanted chunks
	var ids := loaded_chunks.keys().duplicate()
	for i in range(ids.size()):
		if ids[i] < left_id or ids[i] > right_id:
			unload_chunk(ids[i])
			loaded_chunks.erase(ids[i])
