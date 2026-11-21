extends Node2D

@export var enemy_scene: PackedScene
@export var spitter_scene: PackedScene
@export var sprinter_scene: PackedScene
@export var tank_scene: PackedScene
@export var ghost_scene: PackedScene
@export var carrier_scene: PackedScene
@export var dodger_scene: PackedScene
var player = null

func _ready():
	player = get_tree().current_scene.find_child("Player", true, false)

func _on_spawn_timer_timeout():
	if enemy_scene and spitter_scene:
		var points = []
		for child in get_children():
			if child is Marker2D:
				points.append(child)
			
		if points.size() > 0:
			var random_point = points[randi() % points.size()]
			var roll = randf()
			var selected_scene = enemy_scene
			
			if roll < 0.15 and spitter_scene:
				selected_scene = spitter_scene
			elif roll < 0.30 and sprinter_scene:
				selected_scene = sprinter_scene
			elif roll < 0.35 and tank_scene:
				selected_scene = tank_scene
			elif roll < 0.45 and ghost_scene:
				selected_scene = ghost_scene
			elif roll < 0.53 and carrier_scene:
				selected_scene = carrier_scene
			elif roll < 0.62 and dodger_scene:
				selected_scene = dodger_scene
			else:
				selected_scene = enemy_scene
			if selected_scene:
				var enemy = selected_scene.instantiate()
				enemy.global_position = random_point.global_position
			
				if player:
					enemy.player = player
				
				get_tree().current_scene.add_child(enemy)
				
