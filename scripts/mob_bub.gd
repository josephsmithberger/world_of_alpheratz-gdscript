class_name MobBub
extends Mob

@export var animated_sprite_2d: AnimatedSprite2D
@export var collision_shape_2d: CollisionShape2D
@export var player_killer: Killer

@export var max_speed: float = 32.0
@export var x_input: float = -1.0
@export var gravity_scale: float = 0.5

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var check_wall: bool = true


func _physics_process(delta: float) -> void:
	var new_velocity := velocity
	new_velocity.y += _gravity * delta * gravity_scale
	new_velocity.x = x_input * max_speed
	velocity = new_velocity

	if check_wall and is_on_wall():
		x_input *= -1.0
		check_wall = false
		create_tween().tween_callback(func():
			check_wall = true
		).set_delay(0.1)

	move_and_slide()
	update_sprite()


func update_sprite() -> void:
	animated_sprite_2d.flip_h = x_input > 0.0

	if not is_instance_valid(collision_shape_2d):
		animated_sprite_2d.play("hurting")
		return
	animated_sprite_2d.play("running")


func perish() -> void:
	animated_sprite_2d.play("hurting")
	player_killer.queue_free()
	collision_shape_2d.queue_free()
	create_tween().tween_callback(func():
		queue_free()
		GameWorld.spawn_cloud_poof_effect(global_position + Vector2(0.0, -8.0))
	).set_delay(0.5)
	velocity = Vector2(velocity.x, -128.0)
