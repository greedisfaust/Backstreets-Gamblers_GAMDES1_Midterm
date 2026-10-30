extends CharacterBody3D
# First-person player (GDD 8.2/8.3). Uses named Input Map actions only.

const SPEED := 5.0
const GRAVITY := 20.0
const MOUSE_SENS := 0.003
const KEY_LOOK := 2.5
var can_move := true

@onready var head: Node3D = $Head
@onready var hit_area: Area3D = $HitArea

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENS)
		head.rotate_x(-event.relative.y * MOUSE_SENS)
		head.rotation.x = clampf(head.rotation.x, -1.4, 1.4)
	if event.is_action_pressed("hit") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		hit()

func _physics_process(delta: float) -> void:
	rotate_y(-Input.get_axis("look_left", "look_right") * KEY_LOOK * delta)
	head.rotate_x(Input.get_axis("look_down", "look_up") * KEY_LOOK * delta)
	head.rotation.x = clampf(head.rotation.x, -1.4, 1.4)
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back") 
	if not can_move: input = Vector2.ZERO 
	var dir := (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()
	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	move_and_slide()

func hit() -> void:
	for body in hit_area.get_overlapping_bodies():
		if body.has_method("stun"):
			body.stun()
			GameState.apply_hit()   # every hit costs the shared wallet
			Audio.play("hit")
