extends CharacterBody2D

@export var speed = 175.0 #скорость врага
@export var max_health = 3 #хп врага
@onready var attack_zone: Area2D = $Area2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var is_dead: bool = false
var current_health: float
var player = null

func _ready():
	current_health = max_health
	player = get_tree().get_first_node_in_group("Player")
	
func _physics_process(_delta) -> void:
	var overlapping_bodies = attack_zone.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("player"):
			
			body.take_damage(1)
			
	if player:
		#заставляем смотреть на игрока
		look_at(player.global_position)
		
		nav_agent.target_position = player.global_position
		
		var next_path_position = nav_agent.get_next_path_position()
		
		var direction = (next_path_position - global_position).normalized()
		
		#переменная скорости characterBody2D
		velocity = direction * speed
		
	move_and_slide()

#получение урона
func take_damage(amount: float):
	
	current_health -= amount
	
	#проверка на смерть
	if current_health <= 0:
		die()

func die():
	if is_dead:
		return
	is_dead = true
	player = get_tree().get_first_node_in_group("Player")
	if player:
		if randf() <= player.vampire_chance:
			player.heal(1)
		
		player.kills_count += 1
		player.total_score += 1
		
		if player.total_score >= 70 and not player.get("boss_spawned"):
			player.boss_spawned = true
			call_deferred("spawn_boss")
			
		if player.total_score >= 150 and not player.speed_boss_spawned:
			player.speed_boss_spawned = true
			call_deferred("spawn_speed_boss")
		if player.total_score >= 260 and not player.spitter_boss_spawned:
			player.spitter_boss_spawned = true
			call_deferred("spawn_spitter_boss")
			
		queue_free()
		
				
func spawn_boss():
	var boss_scene = load("res://fat_enemy.tscn")
	if boss_scene:
		var boss = boss_scene.instantiate()
		
		var spawn_point = get_tree().get_first_node_in_group("boss_spawn_group")
		if spawn_point:
			boss.global_position = spawn_point.global_position
			
		get_tree().current_scene.add_child(boss)
		
func spawn_speed_boss():
	var boss_scene = load("res://speed_enemy.tscn")
	if boss_scene:
		var boss = boss_scene.instantiate()
		
		var spawn_point = get_tree().get_first_node_in_group("boss_spawn_group")
		if spawn_point:
			boss.global_position = spawn_point.global_position
			
		get_tree().current_scene.add_child(boss)
func spawn_spitter_boss():
	var boss_scene = load("res://spitter_boss.tscn")
	if boss_scene:
		var boss = boss_scene.instantiate()
		
		var spawn_point = get_tree().get_first_node_in_group("boss_spawn_group")
		if spawn_point:
			boss.global_position = spawn_point.global_position
			
		get_tree().current_scene.add_child(boss)
