extends Node

@export var room_scenes = [
	preload("res://Game/scenes/level scenes/room_1.tscn"),
	#preload ("res://Game/scenes/level scenes/room_2.tscn"),
	#preload ("res://Game/scenes/level scenes/room_3.tscn")
]
@export var horz_dist: float
@export var vert_variance: float

@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var timer_label: Label = $"../CanvasLayer/VBoxContainer/TimerLabel"
@onready var timer: Timer = $"../Timer"

var current_room_index: int = -1
var current_room_position: Vector2 = Vector2(0,0)
var current_room_instance: Node2D
var old_room_instance: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	move_to_next_room()
	GameManager.connect("next_level",move_to_next_room)

func move_to_next_room() -> void:
	pick_room()
	if current_room_instance:
		old_room_instance = current_room_instance
	current_room_instance = room_scenes.get(current_room_index).instantiate()
	add_child(current_room_instance)
	current_room_position += Vector2(horz_dist,randi_range(-vert_variance,vert_variance))
	current_room_instance.position = current_room_position
	move_camera()
	timer.start()
	if old_room_instance:
		await get_tree().create_timer(1.5)
		old_room_instance.queue_free()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("next_room"):
		move_to_next_room()
	update_label()
	


func pick_room() -> void:
	var new_room_index: int = randi_range(0, room_scenes.size()-1)
	# set to -1 when game starts, lets it first pick a random room
	if current_room_index == -1:
		current_room_index = new_room_index
		return
	
	#if new_room_index == current_room_index:
		#pick_room()
		#return
	
	current_room_index = new_room_index


func move_camera() -> void:
	camera_2d.position = current_room_position


func update_label() -> void:
	timer_label.text = "time left: %s" % snapped(timer.time_left,0.01)
