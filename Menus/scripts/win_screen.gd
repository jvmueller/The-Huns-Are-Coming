extends Control
@onready var win_message: Label = $WinMessage

func _ready():
	win_message.text = "You Win! time saved: %s seconds" % [snapped(GameManager.time_saved,0.01)]

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/scenes/main_menu.tscn")
