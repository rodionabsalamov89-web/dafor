extends CharacterBody2D

@export var speed = 150.0 #скорость врага
@export var max_health = 20 #хп врага
@onready var attack_zone: Area2D = $Area2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export var minion_scene: PackedScene
@export var minion_count: int = 5

var current_health: float
var player = null

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
	
	#проверка на смерть
	if current_health <= 0:
		die()

func die():
	player = get_tree().get_first_node_in_group("Player")
	if player:
		if randf() <= player.vampire_chance:
			player.heal(1)
		
		player.kills_count += 10
		
		if minion_scene:
			for i in range(minion_count):
				var minion = minion_scene.instantiate()
				var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
				minion.global_position = global_position + offset
				get_parent().call_deferred("add_child", minion)
				
		queue_free()
