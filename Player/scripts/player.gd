extends CharacterBody2D

enum state {
	idling,
	walking,
	falling,
	attacking,
	rolling,
	sliding
}

@onready var attack_timer: Timer = $AttackTimer
@onready var roll_timer: Timer = $RollTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_state: state
var direction

@export var move_speed: float = 350
@export var jump_power: float = 600
@export var slide_speed: float = 0.25
@export var x_acceleration: float = 30

func _ready() -> void:
	current_state = state.falling


# Handles everything related to changing states
# You could also move each state's setup into a separate function if you had a lot to do.
func change_state(new_state: state) -> void:
	current_state = new_state
	print_state()
	match current_state:
		state.idling:
			pass
		state.walking:
			pass
		state.falling:
			pass
		state.attacking:
			attack_timer.start()
		state.rolling:
			roll_timer.start()
		state.sliding:
			pass

#specific state change into falling induced by the jump action
func jump() -> void:
	velocity.y = -1 * jump_power
	change_state(state.falling)


func wall_jump() -> void:
	velocity.y = -1 * jump_power
	velocity.x = -1 * direction * jump_power * 1.5
	change_state(state.falling)


func print_state() -> void:
	match current_state:
		state.idling:
			print("idle")
		state.walking:
			print("walk")
		state.falling:
			print("fall")
		state.attacking:
			print("attack")
		state.rolling:
			print("roll")
		state.sliding:
			print("slide")


func handle_move() -> void:
	direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * move_speed,x_acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)


func _physics_process(delta: float) -> void:
	#state update behavior
	match current_state:
		state.idling:
			if not is_on_floor():
				change_state(state.falling)
			
			direction = Input.get_axis("left", "right")
			if direction:
				change_state(state.walking)
			
			if Input.is_action_just_pressed("jump"):
				jump()
		
			if Input.is_action_just_pressed("roll"):
				change_state(state.rolling)
			
			if Input.is_action_just_pressed("attack"):
				change_state(state.attacking)
		
		state.walking:
			if not is_on_floor():
				change_state(state.falling)
			
			if Input.is_action_just_pressed("jump"):
				jump()
			
			handle_move()
			
			if velocity.x == 0:
				change_state(state.idling)
			
		state.falling:
			velocity += get_gravity() * delta
			
			if is_on_wall():
				change_state(state.sliding)
			
			#handle_move()
			direction = Input.get_axis("left", "right")
			velocity.x = move_toward(velocity.x, direction * move_speed,x_acceleration)
			
			if is_on_floor():
				change_state(state.idling)
			
		state.attacking:
			if attack_timer.is_stopped():
				change_state(state.idling)
			
		state.rolling:
			if roll_timer.is_stopped():
				change_state(state.idling)
		
		state.sliding:
			if velocity.y > 0:
				velocity += get_gravity() * delta * slide_speed
			if velocity.y < 0:
				velocity += get_gravity() * delta / slide_speed
			
			handle_move()
			
			if Input.is_action_just_pressed("jump"):
				wall_jump()
			
			if not is_on_wall():
				change_state(state.falling)
	
	move_and_slide()
