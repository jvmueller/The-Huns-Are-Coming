extends Node
signal place_debug (position: Vector2)
signal next_level
signal lock_player

func lose() -> void:
	get_tree().change_scene_to_file("res://Menus/scenes/game_over_screen.tscn")

func win() -> void:
	get_tree().change_scene_to_file("res://Menus/scenes/win_screen.tscn")

func win_level() -> void:
	emit_signal("next_level")

func freeze_player() -> void:
	emit_signal("lock_player")

func show_debug(position: Vector2) -> void:
	emit_signal("place_debug",position)
