extends Node2D
@export var next_level_delay: float = 1
@onready var fire: Sprite2D = $fire
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	GameManager.player_safe = false
	fire.visible = false


func _on_area_entered(area: Area2D) -> void:
	GameManager.player_safe = true
	GameManager.freeze_player()
	fire.visible = true
	animation_player.play("fire")
	await get_tree().create_timer(next_level_delay).timeout
	GameManager.win_level()
