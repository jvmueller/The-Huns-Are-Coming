extends CharacterBody2D


@export var SPEED: float = 350
@export var JUMP_VELOCITY: float = -200
@export var jumps: int = 3

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (jumps > 0 or is_on_floor()):
		velocity.y = -1 * JUMP_VELOCITY
		jumps -= 1
	
	if is_on_floor():
		jumps = 3

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
