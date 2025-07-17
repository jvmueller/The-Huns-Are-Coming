extends CharacterBody2D

enum state {
	idling,
	walking,
	falling,
	attacking,
	rolling,
	sliding,
	stun
}

@onready var attack_timer: Timer = $AttackTimer
@onready var roll_timer: Timer = $RollTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var wall_jump_timer: Timer = $WallJumpTimer
@onready var stun_timer: Timer = $StunTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


var current_state: state
var direction
var last_direction = 1
var fast_falling: bool
var coyote_active: bool

@export var move_speed: float = 650
@export var roll_speed: float = 1200
@export var jump_power: float = 800
@export var wall_jump_horz_power: float = 500
@export var wall_jump_vert_power: float = 850
@export var slide_speed: float = 250
@export var drag_acceleration: float = 15
@export var walk_acceleration: float = 50
@export var slide_acceleration: float = 100
@export var fast_falling_speed: float = 1.5
@export var knockback_speed_x: float = 200
@export var knockback_speed_y: float = -200
@export var max_y_velocity: float = 1000
@export var concussion_curve: Curve
@export var player_collider: RectangleShape2D
@export var roll_collider: RectangleShape2D




func _ready() -> void:
	current_state = state.falling
	collision_shape_2d.shape = player_collider


# Handles everything related to changing states
# You could also move each state's setup into a separate function if you had a lot to do.
func change_state(new_state: state) -> void:
	current_state = new_state
	print_state()
	match current_state:
		state.idling:
			fast_falling = false
			animation_player.play("idle")
		state.walking:
			animation_player.play("walk")
		state.falling:
			print(animation_player.current_animation)
			if animation_player.current_animation != "jump":
				animation_player.play("fall")
		state.attacking:
			attack_timer.start()
		state.rolling:
			collision_shape_2d.shape = roll_collider
			
			if last_direction == 1:
				animation_player.play("roll right")
			else:
				animation_player.play("roll left")
			
			velocity.x = last_direction * roll_speed
			roll_timer.start()
		state.sliding:
			fast_falling = false
			if last_direction == 1:
				animation_player.play("slide right")
			else:
				animation_player.play("slide left")
		state.stun:
			animation_player.play("jump")


#specific state change into falling induced by the jump action
func jump() -> void:
	animation_player.play("jump")
	velocity.y += -1 * jump_power
	velocity.y = clampf(velocity.y,-1 * jump_power, 0)
	fast_falling = true
	change_state(state.falling)


func wall_jump() -> void:
	animation_player.play("jump")
	wall_jump_timer.start()
	fast_falling = true
	velocity.y += -1 * wall_jump_vert_power
	velocity.y = clampf(velocity.y,-1 * (wall_jump_vert_power - slide_speed), 0)
	velocity.x = -1 * direction * wall_jump_horz_power
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
		state.stun:
			print("stun")


func handle_move() -> void:
	direction = Input.get_axis("left", "right")
	
	if direction:
		last_direction = direction
		if current_state == state.idling:
			change_state(state.walking)
	
	if is_fast_wall_jumping():
		if direction != sign(velocity.x):
			velocity.x = move_toward(velocity.x, 0, drag_acceleration * .75)
		
	else:
		if direction: #input
			velocity.x = move_toward(velocity.x, direction * move_speed, walk_acceleration)
		elif current_state == state.walking:#no input and on ground
			velocity.x = move_toward(velocity.x, 0, move_speed)
		else: #no input in air
			velocity.x = move_toward(velocity.x, 0, drag_acceleration)


func flip_sprite() -> void:
	if direction == 1:
		sprite_2d.flip_h = false
	elif direction == -1:
		sprite_2d.flip_h = true

func is_fast_wall_jumping() -> bool:
	return abs(velocity.x) >= move_speed and current_state == state.falling


func update_gravity(delta: float):
	if current_state == state.sliding:
		if velocity.y >= 0:
			velocity.y = move_toward(velocity.y,slide_speed,slide_acceleration)
		if velocity.y < 0:
			velocity += get_gravity() * delta * 4
		
	elif(fast_falling and velocity.y > 0):
		velocity += get_gravity() * delta * fast_falling_speed
	
	else: 
		velocity += get_gravity() * delta
	
	clampf(velocity.y, -max_y_velocity, max_y_velocity)


func _physics_process(delta: float) -> void:
	update_gravity(delta)
	
	flip_sprite()
	
	#state update behavior
	match current_state:
		state.idling:
			if not is_on_floor():
				change_state(state.falling)
			elif abs(velocity.x) > 0:
				change_state(state.walking)
			
			handle_move()
			
			if Input.is_action_just_pressed("jump"):
				jump()
		
			if Input.is_action_just_pressed("roll"):
				change_state(state.rolling)
			
			if Input.is_action_just_pressed("attack"):
				change_state(state.attacking)
		
		state.stun:
			if is_on_floor():
				velocity.x = 0
	
			if stun_timer.time_left == 0:
				change_state(state.idling)
		
		state.walking:
			if not is_on_floor():
				coyote_active = true
				coyote_timer.start()
				change_state(state.falling)
				
			
			if Input.is_action_just_pressed("jump"):
				jump()
			
			handle_move()
			
			if velocity.x == 0:
				change_state(state.idling)
			
			if Input.is_action_just_pressed("roll"):
				change_state(state.rolling)
			
			if Input.is_action_just_pressed("attack"):
				change_state(state.attacking)
			
		state.falling:
			if Input.is_action_just_pressed("jump"):
				if coyote_active:
					jump()
				else:
					jump_buffer_timer.start()
			
			
			
			if is_on_wall():
				change_state(state.sliding)
			
			if wall_jump_timer.time_left > 0:
				velocity.x = move_toward(velocity.x, move_speed * sign(velocity.x), (wall_jump_horz_power - move_speed) * delta / wall_jump_timer.wait_time)
			else:
				handle_move()
				
				if Input.is_action_just_pressed("roll"):
					change_state(state.rolling)
			
				
			if is_on_floor():
				if jump_buffer_timer.time_left > 0:
					jump()
				else:
					change_state(state.idling)
			
		state.attacking:
			if attack_timer.is_stopped():
				change_state(state.idling)
			
		state.rolling:
			if is_on_wall() and velocity.x == 0:
				velocity = Vector2(knockback_speed_x * last_direction * -1, knockback_speed_y)
				stun_timer.wait_time = concussion_curve.sample(roll_timer.time_left)
				stun_timer.start()
				collision_shape_2d.shape = player_collider
				change_state(state.stun)
	
			if roll_timer.is_stopped():
				collision_shape_2d.shape = player_collider
				change_state(state.walking)
			else:
				velocity.x = move_toward(velocity.x, move_speed * last_direction, (roll_speed - move_speed) * delta / roll_timer.wait_time)
		
		state.sliding:
			handle_move()
			
			if is_on_wall_only() and Input.is_action_just_pressed("jump"):
				wall_jump()
			
			if not is_on_wall():
				change_state(state.falling)
			
			if is_on_floor():
				change_state(state.idling)
		
	
	move_and_slide()


func _on_coyote_timer_timeout() -> void:
	coyote_active = false


func _on_jump_buffer_timer_timeout() -> void:
	pass # Replace with function body.
