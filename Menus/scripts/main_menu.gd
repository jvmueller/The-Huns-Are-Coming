extends Control

@export var game_scene: PackedScene
@export var settings_scene: PackedScene
@export var credits_scene: PackedScene


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_packed(settings_scene)


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_packed(credits_scene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
