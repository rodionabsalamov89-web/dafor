extends CharacterBody2D

@export var speed = 330.0 #скорость врага
@export var max_health = 130 #хп врага
@onready var attack_zone: Area2D = $Area2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export var dodge_speed: float = 650.0
@export var dodge_duration: float = 0.2
@export var dodge_cooldown: float = 0.8
@export var minion_scene: PackedScene
@export var minion_count: int = 3
@onready var i_frame_timer: Timer = $IFrameTimer
var can_take_damage: bool = true
var is_dodging: bool = false
var can_dodge: bool = true
var dodge_direction: Vector2 = Vector2.ZERO
var knockback_immune: bool = true
var is_dead: bool = false
var current_health: float
var player = null

func _ready():
	current_health = max_health
	player = get_tree().get_first_node_in_group("Player")
	
func _physics_process(_delta) -> void:
	var overlapping_bodies = attack_zone.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("Player"):
			
			body.take_damage(2)
			
	if player:
		#заставляем смотреть на игрока
		look_at(player.global_position)
		
		if is_dodging:
			velocity = dodge_direction * dodge_speed
			
		else:
			nav_agent.target_position = player.global_position
			
			var next_path_position = nav_agent.get_next_path_position()
			
			var direction = (next_path_position - global_position).normalized()
			
			#переменная скорости characterBody2D
			velocity = direction * speed
		
	move_and_slide()

#получение урона
func take_damage(amount: float):
	if not can_take_damage:
		return
		
	max_health -= amount
	can_take_damage = false
	i_frame_timer.start()
	
	if max_health <= 0:
		die()
	
func die():
	if is_dead:
		return
	is_dead = true
	
	player = get_tree().get_first_node_in_group("Player")
	if player:
		if randf() <= player.vampire_chance:
			player.heal(1)
		
		player.kills_count += 30
		
		if minion_scene:
			for i in range(minion_count):
				var minion = minion_scene.instantiate()
				var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
				minion.global_position = global_position + offset
				get_parent().call_deferred("add_child", minion)
			
		queue_free()

func _on_dodge_sensor_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet") and can_dodge and not is_dodging:
		start_dodge()
		
func start_dodge() -> void:
	if player == null:
		return
	is_dodging = true
	can_dodge = false
	var to_player = (player.global_position - global_position).normalized()
	var side = -1 if randf() < 0.5 else 1
	dodge_direction = to_player.orthogonal() * side
		
	await get_tree().create_timer(dodge_duration).timeout
	is_dodging = false
		
	await get_tree().create_timer(dodge_cooldown).timeout
	can_dodge = true
	
func _on_i_frame_timer_timeout() -> void:
	can_take_damage = true
