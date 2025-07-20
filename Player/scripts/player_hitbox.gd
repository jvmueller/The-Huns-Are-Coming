extends Area2D

@onready var destroy_audio: AudioStreamPlayer = $"../../DestroyAudio"
@onready var player: CharacterBody2D = $"../.."
@onready var sprite_2d: Sprite2D = $".."
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	disable_attack_hitbox()


func enable_attack_hitbox():
	collision_shape.disabled = false


func disable_attack_hitbox():
	collision_shape.disabled = true


func _on_body_entered(body: Node2D) -> void:
	handle_destruction(body,global_position + position * sprite_2d.scale.x)

func handle_destruction(level_tilemap: TileMapLayer, destruction_position: Vector2) -> void:
	#print("destruction position: ",destruction_position)
	# Convert world position to tilemap local coordinates
	var local_pos = level_tilemap.to_local(destruction_position)
	
	var tile_coords: Vector2i = level_tilemap.local_to_map(local_pos)
	# Debug: show where we're actually checking
	var actual_world_pos = level_tilemap.to_global(level_tilemap.map_to_local(tile_coords))
	GameManager.show_debug(actual_world_pos)
	
	#print("tile_coords: ",tile_coords)
	var tile_data = level_tilemap.get_cell_tile_data(tile_coords)
	#print(tile_data == null)
	
	if tile_data:
		if tile_data.get_custom_data("name") == "destructible":
			destroy_audio.play()
			level_tilemap.erase_cell(tile_coords)
