extends CharacterBody2D

@onready var attack_timer: Timer = $AttackTimer
@onready var roll_timer: Timer = $RollTimer

var move_speed: float = 350
var jump_power: float = 600

var state_machine: LimboHSM


func _ready() -> void:
	initiate_state_machine()


func _physics_process(delta: float) -> void:
	Global.state = state_machine.get_active_state()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		state_machine.dispatch(&"to_jump")
	
	elif event.is_action_pressed("attack"):
		state_machine.dispatch(&"to_attack")
	
	elif event.is_action_pressed("roll"):
		state_machine.dispatch(&"to_roll")
	

func initiate_state_machine():
	#creates state machine and adds to player scene
	state_machine = LimboHSM.new()
	add_child(state_machine)
	
	#creates state variables for each state
	var idle_state = LimboState.new().named("idle").call_on_enter(idle_start).call_on_update(idle_update)
	var walk_state = LimboState.new().named("walk").call_on_enter(walk_start).call_on_update(walk_update)
	var jump_state = LimboState.new().named("jump").call_on_enter(jump_start).call_on_update(jump_update)
	var roll_state = LimboState.new().named("roll").call_on_enter(roll_start).call_on_update(roll_update)
	var attack_state = LimboState.new().named("attack").call_on_enter(attack_start).call_on_update(attack_update)
	
	#adds states into machine
	state_machine.add_child(idle_state)
	state_machine.add_child(walk_state)
	state_machine.add_child(jump_state)
	state_machine.add_child(roll_state)
	state_machine.add_child(attack_state)
	
	#sets the starting state to idle
	state_machine.initial_state = idle_state
	
	#to walk transition
	state_machine.add_transition(idle_state,walk_state, &"to_walk")
	#to jump transitions
	state_machine.add_transition(idle_state,jump_state, &"to_jump")
	state_machine.add_transition(walk_state,jump_state, &"to_jump")
	#to idle transition
	state_machine.add_transition(state_machine.ANYSTATE, idle_state, &"to_idle")
	#to attack transitions
	state_machine.add_transition(idle_state, attack_state, &"to_attack")
	state_machine.add_transition(walk_state, attack_state, &"to_attack")
	#to roll transitions
	state_machine.add_transition(idle_state, roll_state, &"to_roll")
	state_machine.add_transition(walk_state, roll_state, &"to_roll")
	state_machine.add_transition(jump_state, roll_state, &"to_roll")
	
	#initializes the state machine
	state_machine.initialize(self)
	state_machine.set_active(true)


func idle_start():
	pass


func idle_update(delta: float):
	if velocity.x != 0:
		state_machine.dispatch(&"to_walk")


func walk_start():
	pass


func walk_update(delta: float):
	if velocity.x == 0:
		state_machine.dispatch(&"to_idle")


func jump_start():
	velocity.y = -1 * jump_power


func jump_update(delta: float):
	if is_on_floor():
		state_machine.dispatch(&"to_idle")
	

func roll_start():
	roll_timer.start()


func roll_update(delta: float):
	if roll_timer.is_stopped():
		state_machine.dispatch(&"to_idle")


func attack_start():
	attack_timer.start()


func attack_update(delta: float):
	if attack_timer.is_stopped():
		state_machine.dispatch(&"to_idle")
