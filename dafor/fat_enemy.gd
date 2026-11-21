extends CharacterBody2D

@export var max_hp: int = 150
@export var speed: float = 120.0

var current_hp: int = max_hp
var can_take_damage: bool = true
var player: Node2D = null
var is_dashing = false
var knockback_immune: bool = true

@onready var i_frame_timer: Timer = $IFrameTimer
@onready var sprite: Sprite2D = $Sprite2D
@export var tank_enemy_scene: PackedScene
@export var enemy_scene: PackedScene
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	current_hp = max_hp
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(_delta: float) -> void:
	if is_dashing:
		move_and_slide()
		return
	
	if player:
		look_at(player.global_position)
		
		nav_agent.target_position = player.global_position
		
		var next_path_position = nav_agent.get_next_path_position()
		
		var direction = (next_path_position - global_position).normalized()
		
		velocity = direction * speed
		
	move_and_slide()

# Функция урона, которую вызывают твои пули
func take_damage(amount: int) -> void:
	if not can_take_damage:
		return

	current_hp -= amount

	if current_hp <= 0:
		die()
		return

	can_take_damage = false
	i_frame_timer.start()

func die() -> void:
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.kills_count += 30
		
	queue_free()

func _on_i_frame_timer_timeout() -> void:
	can_take_damage = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)

func _on_boss_spawn_timer_timeout() -> void:
	if enemy_scene:
		for i in range(5):
			spawn_single_enemy(enemy_scene)
	if tank_enemy_scene:
		for i in range(2):
			spawn_single_enemy(tank_enemy_scene)
	boss_dash()
	
func spawn_single_enemy(custom_scene: PackedScene) -> void:
	var enemy = custom_scene.instantiate()
	
	var random_angle = randf_range(0, 2 * PI)
	var distance = randf_range(200, 200)
	var offset = Vector2(cos(random_angle), sin(random_angle)) * distance
	enemy.global_position = global_position + offset
	
	if "player" in enemy:
		enemy.player = player
	elif "player_ref" in enemy:
		enemy.player_ref = player
	
	get_parent().add_child(enemy)
	
func boss_dash() -> void:
	if not player: return 

	var old_speed = speed
	speed = 0

	await get_tree().create_timer(0.5).timeout

	var dash_direction = (player.global_position - global_position).normalized()

	velocity = dash_direction * (old_speed * 4.0)
	is_dashing = true

	await get_tree().create_timer(0.4).timeout

	is_dashing = false
	speed = old_speed
	velocity = Vector2.ZERO
