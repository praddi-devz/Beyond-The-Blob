extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -330.0

var stun_time := 0.0
var safe_time := 0.0

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	safe_time -= delta
	if not is_on_floor():
		velocity += get_gravity() * delta

	if stun_time > 0:
		stun_time -= delta
	else:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	_check_enemy_contact()

func _check_enemy_contact() -> void:
	if safe_time > 0:
		return
	for i in get_slide_collision_count():
		var hit = get_slide_collision(i)
		var other = hit.get_collider()
		if other == null or not other.name.to_lower().contains("enemy"):
			continue
		if hit.get_normal().y < -0.7:
			continue   # landing on its head doesn't count as a hit
		print("PLAYER touched ", other.name, " -> bouncing")
		if other.has_method("attack"):
			other.attack()
		var dir = sign(global_position.x - other.global_position.x)
		if dir == 0:
			dir = 1
		velocity = Vector2(dir * -800, -300.0)
		stun_time = 0.3
		safe_time = 1.0
		return
