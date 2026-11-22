extends CharacterBody2D
@export var spit_scene: PackedScene = preload("res://spit.tscn")

var speed: float = 150.0
var health: float = 200.0
var attack_range: float = 500.0 # Дистанция, на которой он останавливается и плюет
var can_take_damage: bool = true
var knockback_immune: bool = true
var half_hp_triggered: bool = false
var is_dead: bool = false

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var attack_timer = $AttackTimer
@onready var muzzle = $Muzzle2
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var i_frame_timer: Timer = $IFrameTimer

func _ready() -> void:
	add_to_group("enemies")
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(_delta: float) -> void:
	look_at(player.global_position)
	
	if not player: return

	if nav_agent:
		nav_agent.target_position = player.global_position
		var next_path_position = nav_agent.get_next_path_position()
		var direction = (next_path_position - global_position).normalized()
		var distance = global_position.distance_to(player.global_position)
		
		if distance > attack_range:
			velocity = direction * speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
		
		if attack_timer.is_stopped():
			attack_timer.start()

func _on_attack_timer_timeout() -> void:
	if player and global_position.distance_to(player.global_position) <= attack_range + 50.0:
		var bullet_count: int = 6 # Количество снарядов в веере
		var spread_angle: float = 50.0 # Общий угол разброса в градусах
		var base_dir = (player.global_position - muzzle.global_position).normalized()
		var start_angle = -deg_to_rad(spread_angle / 2.0)
		var angle_step = deg_to_rad(spread_angle / (bullet_count - 1))

		for i in range(bullet_count):
			var spit = spit_scene.instantiate()
			get_tree().current_scene.add_child(spit)
			
			spit.global_position = muzzle.global_position
			# Поворачиваем базовое направление на нужный угол для каждого снаряда
			var current_angle = start_angle + angle_step * i
			spit.direction = base_dir.rotated(current_angle)
			
			spit.global_position = muzzle.global_position + spit.direction * 40.0
			
			spit.speed = 300.0
			# Включаем бумеранг и передаем ссылку на босса
			spit.is_boomerang = true
			spit.boss_ref = self

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 100.0 and not half_hp_triggered:
		half_hp_triggered = true
		trigger_half_hp_explosion()
		if health <= 0:
			die()
			
func trigger_half_hp_explosion() -> void:
	attack_timer.wait_time *= 0.50
	var ring_bullets: int = 16
	for i in range(ring_bullets):
		var spit = spit_scene.instantiate()
		var angle = (TAU / ring_bullets) * i
		spit.direction = Vector2.RIGHT.rotated(angle)
		spit.global_position = global_position + spit.direction * 30.0
		spit.speed = 250.0
		spit.is_boomerang = false # Обычные пули, чтобы не заспамить арену возвратом
		
		get_tree().current_scene.call_deferred("add_child", spit)
		
func die() -> void:
	if is_dead:
		return
	is_dead = true
	if player:
		player.kills_count += 45
	queue_free()

func _on_i_frame_timer_timeout() -> void:
	can_take_damage = true
