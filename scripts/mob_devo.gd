class_name MobDevo
extends Mob

@export var animated_sprite_2d: AnimatedSprite2D
@export var collision_shape_2d: CollisionShape2D
@export var player_killer: Killer

@export var jump_force: float = 200.0
@export var jump_interval: float = 2.0
@export var init_delay: float = 0.0
@export var gravity_scale: float = 0.5

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	create_tween().tween_callback(func():
		create_tween().set_loops().tween_callback(func():
			var new_velocity := velocity
			new_velocity.y += -jump_force
			velocity = new_velocity
		).set_delay(jump_interval)
	).set_delay(init_delay)


func _physics_process(delta: float) -> void:
	var new_velocity := velocity
	new_velocity.y += _gravity * gravity_scale * delta
	velocity = new_velocity

	update_sprite()
	move_and_slide()


func update_sprite() -> void:
	if not is_instance_valid(collision_shape_2d):
		animated_sprite_2d.play("hurting")
		return
	if is_on_floor():
		animated_sprite_2d.play("standing")
	else:
		animated_sprite_2d.play("jumping")


func perish() -> void:
	animated_sprite_2d.play("hurting")
	collision_shape_2d.queue_free()
	player_killer.queue_free()
	create_tween().tween_callback(func():
		queue_free()
		GameWorld.spawn_cloud_poof_effect(global_position + Vector2(0.0, -8.0))
	).set_delay(0.5)
	velocity = Vector2(velocity.x, -128.0)
