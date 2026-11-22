extends CharacterBody2D

@export var mud_spit_scene: PackedScene # Перетащи сюда сцену mud_spit.tscn
@export var max_hp: int = 5
@export var speed: float = 90.0
@export var attack_range: float = 500.0 # Короткая дистанция атаки
@export var shoot_cooldown: float = 2.0 # Перезарядка между выстрелами
@export var kill_reward: int = 1
var hp: int
var player: Node2D = null
var can_shoot: bool = true
var is_dead: bool = false

func _ready() -> void:
	hp = max_hp
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if player:
		look_at(player.global_position)
		
	if is_dead or not is_instance_valid(player):
		return

	var distance = global_position.distance_to(player.global_position)
	if distance > attack_range:
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * speed
		move_and_slide()
	else:
# Останавливаемся и стреляем
		velocity = Vector2.ZERO
		if can_shoot:
			shoot()

func shoot() -> void:
	if not mud_spit_scene:
		return
	
	can_shoot = false
	
	var spit = mud_spit_scene.instantiate()
	spit.global_position = global_position
	spit.direction = global_position.direction_to(player.global_position)
	spit.max_distance = attack_range
	get_tree().current_scene.call_deferred("add_child", spit)
	# Ждем перезарядку
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

func take_damage(amount: int) -> void:
	if is_dead:
		return

	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true

	if is_instance_valid(player):
		player.kills_count += 5
	queue_free()
