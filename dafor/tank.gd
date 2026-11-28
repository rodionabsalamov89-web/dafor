extends CharacterBody2D

@export var speed = 130.0 #скорость врага
@export var max_health = 50 #хп врага
@onready var attack_zone: Area2D = $Area2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var i_frame_timer: Timer = $IFrameTimer
var is_dead: bool = false
var current_health: float
var player = null
var knockback_immune: bool = true
var can_take_damage: bool = true

func _ready():
	current_health = max_health
	player = get_tree().get_first_node_in_group("Player")
	
func _physics_process(_delta) -> void:
	var overlapping_bodies = attack_zone.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("Player"):
			
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
	
	i_frame_timer.start()
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
		
		player.kills_count += 10
		player.total_score += 10
		player.update_kills_ui()
			
		queue_free()

func _on_i_frame_timer_timeout() -> void:
	can_take_damage = true
