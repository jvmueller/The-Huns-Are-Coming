extends Control
@onready var click: AudioStreamPlayer = $Click
@onready var eastern_thought: AudioStreamPlayer = $EasternThought

func _ready() -> void:
	eastern_thought.play()

func _on_back_button_pressed() -> void:
	click.play()
	await get_tree().create_timer(.2).timeout
	get_tree().change_scene_to_file("res://Menus/scenes/main_menu.tscn")
