extends CharacterBody2D
@export var spit_scene: PackedScene = preload("res://spit.tscn")

var speed: float = 120.0
var health: float = 7.0
var attack_range: float = 500.0 # Дистанция, на которой он останавливается и плюет

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var attack_timer = $AttackTimer
@onready var muzzle = $Muzzle2
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

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
	if player and global_position.distance_to(player.global_position) <= attack_range:
		var spit = spit_scene.instantiate()
		spit.global_position = muzzle.global_position
		
		spit.direction = (player.global_position - global_position).normalized()

		get_tree().current_scene.add_child(spit)

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	if player:
		player.kills_count += 5
	queue_free()
