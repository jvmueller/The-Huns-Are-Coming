extends Control

@onready var music_slider: HSlider = $MarginContainer/VBoxContainer/MusicPanel/VBoxContainer/MarginContainer/MusicSlider
@onready var sfx_slider: HSlider = $MarginContainer/VBoxContainer/SFXPanel/VBoxContainer/MarginContainer/SFXSlider
@onready var click: AudioStreamPlayer = $Click
@onready var eastern_thought: AudioStreamPlayer = $EasternThought


func _ready() -> void:
	eastern_thought.play()
	music_slider.value = Global.music_volume
	sfx_slider.value = Global.sfx_volume
	

func _on_back_button_pressed() -> void:
	click.play()
	await get_tree().create_timer(.2).timeout
	get_tree().change_scene_to_file("res://Menus/scenes/main_menu.tscn")


func _on_music_slider_value_changed(value: float) -> void:
	Global.music_volume = value


func _on_sfx_slider_value_changed(value: float) -> void:
	Global.sfx_volume = value
