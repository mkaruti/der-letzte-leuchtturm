extends CharacterBody2D
const LIO_SPRITE = preload("res://assets/lio_sprite.png")
## Ein bewusst kleiner CharacterBody2D für die erste technische Probe.
## Später durch eine Sprite-Animation erweiterbar.

@export var speed: float = 230.0

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO

	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		direction.y += 1.0

	velocity = direction.normalized() * speed
	move_and_slide()
	if direction != Vector2.ZERO:
		queue_redraw()

func _draw() -> void:
	draw_texture(LIO_SPRITE, Vector2(-16, -16))
