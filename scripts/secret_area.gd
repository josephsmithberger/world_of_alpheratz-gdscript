class_name SecretArea
extends SpecialArea

var is_found: bool = false


func _ready() -> void:
	super._ready()
	modulate.a = 1.0
	body_entered.connect(func(_body: Node2D):
		fade_out()
		if not is_found:
			is_found = true
			GameWorld.secrete_area_found.emit()
	)
	body_exited.connect(func(_body: Node2D):
		fade_in()
	)


func fade_out() -> void:
	create_tween().tween_property(self, "modulate:a", 0.2, 0.5)


func fade_in() -> void:
	create_tween().tween_property(self, "modulate:a", 1.0, 0.5)
