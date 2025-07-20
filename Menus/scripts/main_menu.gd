extends Control

@export var game_scene: PackedScene
@export var credits_scene: PackedScene
@onready var click: AudioStreamPlayer = $Click
@onready var eastern_thought: AudioStreamPlayer = $EasternThought


func _ready() -> void:
	eastern_thought.play()


func _on_play_button_pressed() -> void:
	click.play()
	await get_tree().create_timer(.2).timeout
	get_tree().change_scene_to_packed(game_scene)


func _on_settings_button_pressed() -> void:
	click.play()
	await get_tree().create_timer(.2).timeout
	get_tree().change_scene_to_file("res://Menus/scenes/options_menu.tscn")


func _on_credits_button_pressed() -> void:
	click.play()
	await get_tree().create_timer(.2).timeout
	get_tree().change_scene_to_packed(credits_scene)


func _on_quit_button_pressed() -> void:
	click.play()
	await get_tree().create_timer(.2).timeout
	get_tree().quit()
