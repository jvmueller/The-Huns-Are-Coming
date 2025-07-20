extends Node

@export var room_scenes = [
	preload("res://Game/scenes/level scenes/tutorial.tscn"),
	preload ("res://Game/scenes/level scenes/room_1.tscn"),
	preload ("res://Game/scenes/level scenes/room_2.tscn"),
	preload ("res://Game/scenes/level scenes/room_3.tscn"),
	preload ("res://Game/scenes/level scenes/room_4.tscn"),
	preload ("res://Game/scenes/level scenes/room_5.tscn"),
	preload ("res://Game/scenes/level scenes/room_6.tscn"),
	preload ("res://Game/scenes/level scenes/room_7.tscn"),
	preload ("res://Game/scenes/level scenes/room_8.tscn"),
	preload ("res://Game/scenes/level scenes/room_9.tscn"),
	preload ("res://Game/scenes/level scenes/room_10.tscn"),
	preload ("res://Game/scenes/level scenes/room_11.tscn"),
	preload ("res://Game/scenes/level scenes/room_12.tscn")
]
@export var horz_dist: float
@export var vert_variance: float
@export var tutorial_time: float
@export var game_time: float
@export var game_time_depletion: float
@export var rooms_to_win: int
@export var wall_scene: PackedScene
@export var increment: float

@onready var timer_label: Label = $"../UI Layer/TimerLabel"
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var timer: Timer = $"../Timer"
@onready var hun_timer: Timer = $"../HunTimer"
@onready var debug: Sprite2D = $"../debug"
@onready var tutorial_music: AudioStreamPlayer = $"../TutorialMusic"
@onready var game_music: AudioStreamPlayer = $"../GameMusic"


var current_room_index: int = 0
var current_room_position: Vector2 = Vector2(0,0)
var current_room_instance: Node2D
var old_room_instance: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.rooms_complete = 0
	GameManager.time_saved = 0
	play_tutorial()
	GameManager.connect("next_level",move_to_next_room)
	GameManager.connect("place_debug",place_debug)


func play_tutorial():
	tutorial_music.play()
	camera_2d.zoom = Vector2(0.03,0.03)
	current_room_instance = room_scenes.get(current_room_index).instantiate()
	add_child(current_room_instance)
	current_room_position += Vector2(horz_dist,0)#randi_range(-vert_variance,vert_variance))
	current_room_instance.position = current_room_position
	spawn_walls(current_room_position - Vector2(horz_dist,0), current_room_position + Vector2(horz_dist,0))#randi_range(-vert_variance,vert_variance)))
	move_camera()
	timer.wait_time = tutorial_time
	timer.start()

func spawn_walls(old_pos: Vector2, new_pos: Vector2):
	for x in range(old_pos.x, new_pos.x + 1, increment): 
			 # Calculate the interpolation factor (0.0 to 1.0)
		var t = (x - old_pos.x) / (new_pos.x - old_pos.x)
		
		# Get the y position using linear interpolation
		var y = lerp(old_pos.y, new_pos.y, t)
		
		var wall_instance = wall_scene.instantiate()
		add_child(wall_instance)
		wall_instance.position = Vector2(x,y)
	
func move_to_next_room() -> void:
	if GameManager.rooms_complete == rooms_to_win:
		GameManager.win()

	else:
		#leaving tutorial
		if current_room_index == 0:
			tutorial_music.stop()
			game_music.play()
			camera_2d.zoom = Vector2(0.035,0.035)
		
		pick_room()
		if current_room_instance:
			old_room_instance = current_room_instance
		current_room_instance = room_scenes.get(current_room_index).instantiate()
		add_child(current_room_instance)
		current_room_position += Vector2(horz_dist,0)#randi_range(-vert_variance,vert_variance))
		spawn_walls(current_room_instance.position, current_room_position + Vector2(30000,0))
		current_room_instance.position = current_room_position
		move_camera()
		timer.wait_time = game_time
		timer.start()
		if old_room_instance:
			GameManager.rooms_complete += 1
			await get_tree().create_timer(1).timeout
			game_time -= game_time_depletion
			old_room_instance.queue_free()

func place_debug(position: Vector2) -> void:
	debug.position = position

func _process(delta: float) -> void:
	#if the player gets to the goal and its not the tutorial (weird way to check with music wtv)
	if GameManager.player_safe and not tutorial_music.playing:
		GameManager.time_saved += timer.time_left
		GameManager.player_safe = false
		timer.stop()
	
	if Input.is_action_just_pressed("next_room"):
		move_to_next_room()
	update_label()
	


func pick_room() -> void:
	var new_room_index: int = randi_range(1, room_scenes.size()-1)
	
	if new_room_index == current_room_index:
		pick_room()
		return
	
	current_room_index = new_room_index


func move_camera() -> void:
	camera_2d.position = current_room_position


func update_label() -> void:
	timer_label.text = "time left: %s" % snapped(timer.time_left,0.01)


func _on_timer_timeout() -> void:
	if not GameManager.player_safe:
		hun_timer.start()

func _on_hun_timer_timeout() -> void:
	if not GameManager.player_safe:
		GameManager.lose()
