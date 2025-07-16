extends Node


func lose() -> void:
	get_tree().change_scene_to_file("res://Menus/scenes/game_over_screen.tscn")

func win() -> void:
	get_tree().change_scene_to_file("res://Menus/scenes/win_screen.tscn")
