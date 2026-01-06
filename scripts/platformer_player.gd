class_name PlatformerPlayer
extends CharacterBody2D

enum PlayerState {
	STANDING,
	JUMPING,
	FALLING,
	WALKING,
	DUCKING,
	HURTING,
}

signal player_state_changed(old_state: PlayerState, new_state: PlayerState)

@export var animated_sprite: AnimatedSprite2D
@export var sprite_container: Node2D
@export var collision_shape_2d: CollisionShape2D
@export var emo_bubble: EmoBubble
@export var mob_killer: Killer
@export var left_walking_dust_particles: GPUParticles2D
@export var right_walking_dust_particles: GPUParticles2D
@export var chat_bubble: ChatBubble

@export_range(100.0, 500.0) var ACCELERATION: float = 280.0
@export_range(10.0, 100.0) var MAX_SPEED: float = 72.0
@export_range(1.0, 20.0) var FRICTION: float = 10.0
@export_range(0.0, 5.0) var AIR_RESISTANCE: float = 0.8
@export_range(0.0, 500.0) var JUMP_FORCE: float = 270.0
@export_range(0.1, 2.0, 0.1) var GRAVITY_SCALE: float = 1.0
@export_range(100.0, 200.0) var MAX_FALL_SPEED: float = 200.0
@export_range(0.1, 10.0) var INVINCIBLE_TIME: float = 2.0
@export_range(0.05, 1.0) var BOUNCY_SPRITE: float = 0.3

@export var sfx: bool = false
@export var scripted_input: bool = false

var x_input: float = 0.0
var jump_pressed: bool = false
var duck_pressed: bool = false
var is_invincible: bool = false
var _velocity: Vector2 = Vector2.ZERO

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_state: PlayerState = PlayerState.STANDING
var footstep_loop_tween: Tween


func _ready() -> void:
	mob_killer.mob_hurt.connect(_on_mob_hurt)
	player_state_changed.connect(_on_player_state_changed)
	_create_footstep_loop_tween()

	if has_node("/root/Console"):
		get_node("/root/Console").call("register_env", "player", self)


func _on_mob_hurt() -> void:
	velocity = Vector2(velocity.x, -JUMP_FORCE)
	if randf() < 0.1:
		emo_bubble.play_emo(3)


func _on_player_state_changed(old_state: PlayerState, new_state: PlayerState) -> void:
	if new_state == PlayerState.JUMPING:
		sprite_container.scale = Vector2(0.5, 1.5)
		if sfx:
			GameWorld.play_sfx("res://sounds/sfx_movement_jump9.wav")
	if old_state == PlayerState.FALLING:
		sprite_container.scale = Vector2(1.25, 0.75)
		if sfx:
			GameWorld.play_sfx("res://sounds/sfx_movement_jump9_landing.wav")
	if new_state == PlayerState.WALKING:
		if sfx:
			footstep_loop_tween.play()
	if old_state == PlayerState.WALKING:
		footstep_loop_tween.stop()


func _create_footstep_loop_tween() -> void:
	footstep_loop_tween = create_tween().set_loops()
	footstep_loop_tween.tween_callback(func():
		GameWorld.play_sfx("res://sounds/sfx_movement_footsteps1a.wav")
	).set_delay(0.3)
	footstep_loop_tween.tween_callback(func():
		GameWorld.play_sfx("res://sounds/sfx_movement_footsteps1b.wav")
	).set_delay(0.3)
	footstep_loop_tween.stop()


func get_state_string() -> String:
	return PlayerState.keys()[current_state]


func hurt(impact_x: float = 100.0, impact_y: float = 200.0) -> void:
	if is_invincible:
		return
	var dir := 1.0 if animated_sprite.flip_h else -1.0
	var new_velocity := velocity
	new_velocity.x = dir * impact_x
	new_velocity.y = -impact_y
	velocity = new_velocity

	create_tween().tween_callback(func():
		current_state = PlayerState.HURTING
	).set_delay(0.01)

	# Create invincible animation
	is_invincible = true
	var tween := create_tween().set_loops()

	# Disable attack
	mob_killer.get_node("CollisionShape2D").set_deferred("disabled", true)

	tween.tween_callback(func():
		modulate.a = 0.5
	).set_delay(0.05)

	tween.tween_callback(func():
		modulate.a = 1.0
	).set_delay(0.05)

	create_tween().tween_callback(func():
		is_invincible = false
		modulate.a = 1.0
		tween.kill()
		# Force update collision
		var tween2 := create_tween()
		tween2.tween_callback(func(): collision_shape_2d.set_deferred("disabled", true)).set_delay(0.01)
		tween2.tween_callback(func(): collision_shape_2d.set_deferred("disabled", false)).set_delay(0.01)
		# Enable attack
		tween2.tween_callback(func(): mob_killer.get_node("CollisionShape2D").set_deferred("disabled", false)).set_delay(0.02)
	).set_delay(INVINCIBLE_TIME)

	emo_bubble.play_emo(7)
	GameWorld.play_sfx("res://sounds/sfx_sounds_impact8.wav")
	GameWorld.player_hurt.emit()
	print("[INFO] Ouch!")


func update_state(delta: float) -> void:
	var old_state := current_state

	# Apply gravity
	_velocity.y = minf(_velocity.y + _gravity * GRAVITY_SCALE * delta, MAX_FALL_SPEED)

	# Apply horizontal movement
	if current_state != PlayerState.HURTING and current_state != PlayerState.DUCKING:
		_velocity.x += x_input * ACCELERATION * delta
		_velocity.x = clampf(_velocity.x, -MAX_SPEED, MAX_SPEED)

	# Apply air resistance
	if current_state == PlayerState.JUMPING or current_state == PlayerState.FALLING:
		if x_input == 0.0:
			_velocity.x = lerpf(_velocity.x, 0.0, AIR_RESISTANCE * delta)

	# Apply ground friction
	if current_state == PlayerState.DUCKING or current_state == PlayerState.STANDING:
		_velocity.x = lerpf(_velocity.x, 0.0, FRICTION * delta)

	# State transitions
	match current_state:
		PlayerState.STANDING:
			if is_on_floor() and x_input != 0.0:
				current_state = PlayerState.WALKING
		PlayerState.WALKING:
			if is_on_floor() and x_input == 0.0:
				current_state = PlayerState.STANDING
		PlayerState.JUMPING:
			if _velocity.y > 0.0 or (not jump_pressed and _velocity.y < -JUMP_FORCE / 2.0):
				current_state = PlayerState.FALLING
		PlayerState.FALLING:
			if is_on_floor():
				current_state = PlayerState.STANDING
		PlayerState.HURTING:
			if is_on_floor():
				current_state = PlayerState.STANDING
		PlayerState.DUCKING:
			if not duck_pressed:
				current_state = PlayerState.STANDING

	if current_state == PlayerState.STANDING or current_state == PlayerState.WALKING:
		if is_on_floor():
			if jump_pressed:
				current_state = PlayerState.JUMPING
				_velocity.y = -JUMP_FORCE
			if duck_pressed:
				current_state = PlayerState.DUCKING
		else:
			current_state = PlayerState.FALLING

	if current_state != old_state:
		player_state_changed.emit(old_state, current_state)


func update_sprite() -> void:
	if _velocity.x > 0.0:
		animated_sprite.flip_h = false
	elif _velocity.x < 0.0:
		animated_sprite.flip_h = true

	match current_state:
		PlayerState.STANDING:
			animated_sprite.play("standing")
		PlayerState.WALKING:
			animated_sprite.play("walking")
		PlayerState.JUMPING:
			animated_sprite.play("jumping")
		PlayerState.HURTING:
			animated_sprite.play("hurting")
		PlayerState.DUCKING:
			animated_sprite.play("ducking")
		PlayerState.FALLING:
			if _velocity.y > MAX_FALL_SPEED * 0.9:
				animated_sprite.play("falling")

	sprite_container.scale = sprite_container.scale.lerp(Vector2.ONE, BOUNCY_SPRITE)

	var emitting_dust_particles := current_state == PlayerState.WALKING and absf(velocity.x) > MAX_SPEED * 0.99
	left_walking_dust_particles.emitting = emitting_dust_particles and velocity.x > 0.0
	right_walking_dust_particles.emitting = emitting_dust_particles and velocity.x < 0.0


func update_input() -> void:
	if scripted_input:
		return

	x_input = Input.get_action_strength(GameWorld.INPUT_ACTION_RIGHT) - Input.get_action_strength(GameWorld.INPUT_ACTION_LEFT)
	jump_pressed = Input.is_action_pressed(GameWorld.INPUT_ACTION_UP)
	duck_pressed = Input.is_action_pressed(GameWorld.INPUT_ACTION_DOWN)


func _physics_process(delta: float) -> void:
	update_input()
	_velocity = velocity
	update_state(delta)
	update_sprite()
	velocity = _velocity
	move_and_slide()
