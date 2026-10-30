extends CharacterBody2D
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
    # Platzhalter-Grafik, bewusst ohne externe PNG-Dateien.
    draw_circle(Vector2(0, 4), 18.0, Color("#17293c"))
    draw_circle(Vector2.ZERO, 14.0, Color("#ffd56b"))
    draw_circle(Vector2(0, -5), 6.0, Color("#243e59"))
    draw_circle(Vector2(5, -5), 2.0, Color("#ffffff"))
