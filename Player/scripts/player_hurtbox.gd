extends Area2D

@onready var player: CharacterBody2D = $".."
@onready var fireworks_audio: AudioStreamPlayer = $"../FireworksAudio"
@onready var hurtbox_collider: CollisionShape2D = $HurtboxCollider

@export var player_collider: CapsuleShape2D
@export var roll_collider: CapsuleShape2D

func _ready() -> void:
	set_roll_collider(false)


func set_roll_collider(status: bool) -> void:
	if status:
		hurtbox_collider.set_deferred("shape",roll_collider)
	else:
		hurtbox_collider.set_deferred("shape",player_collider)


func _on_body_entered(body: Node2D) -> void:
	handle_collision(body, player.position)


func handle_collision(level_tilemap: TileMapLayer, player_position: Vector2) -> void:
	print("player pos: ", player_position)
	
	var tile_coords: Vector2i = level_tilemap.local_to_map(player_position)
	print("tile coords: ", tile_coords)
	
	#checks all tile coordinates that are neighboring the player's position for fireworks
	for x in [-1,0,1]:
		for y in [-1,0,1]:
			var check_tile_coords = tile_coords + Vector2i(x,y)
			var tile_data = level_tilemap.get_cell_tile_data(check_tile_coords)
			
			if tile_data: 
				if tile_data.get_custom_data("name") == "firework":
					fireworks_audio.play()
					player.stun(1.25)
					level_tilemap.erase_cell(check_tile_coords)
				
				elif tile_data.get_custom_data("name") == "goal":
					GameManager.win_level()
