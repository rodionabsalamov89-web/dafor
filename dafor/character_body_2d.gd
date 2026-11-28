extends CharacterBody2D

const SPEED = 300.0
var slow_modifier: float = 1.0
var bonus_speed_mult: float = 1.0
var attack_cooldown_mult: float = 1.0
var immune_to_mud: bool = false
var bonus_max_hp: float = 0.0
var damage_multiplier: float = 1.0
var active_abilities: Array[String] = []
var puddle_drop_cooldown: float = 0.0
var shoot_cooldown: float = 0.0
var pierce_count: int = 1
var boss_spawned: bool = false
var vampire_chance: float = 0.0
var bullet_size_multiplier: float = 1.0
var max_ability_slots: int = 3
var slot_upgrade_cost: int = 5
var crit_chance: float = 0.0
var is_dead: bool = false
var knockback_force: float = 0.0
var regen_timer: float = 0.0
var total_score: int = 0
var speed_boss_spawned: bool = false
var spitter_boss_spawned: bool = false
var kills_count: int = 0:
	set(value):
		kills_count = value
		update_kills_ui()


func _physics_process(_delta) -> void:
		
	var direction := Input.get_vector("ui_left", "ui_right" , "ui_up", "ui_down")
	if direction:
		velocity = direction * SPEED * slow_modifier * bonus_speed_mult
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()
	
@export var bullet_scene: PackedScene
@export var upgrade_menu_scene: PackedScene
var menu_instance: CanvasLayer
@onready var muzzle = $Muzzle
@onready var shoot_timer = $ShootTimer
@onready var health_bar: ProgressBar = $CanvasLayer/HealthBar
@onready var kills_label: Label = $CanvasLayer/KillsLabel
func _process(_delta):
	if Input.is_action_just_pressed("open_shop"):
		if menu_instance:
			if not menu_instance.visible:
				menu_instance.open_upgrade_menu(self)
	if menu_instance and menu_instance.visible:
		return
		
	handle_regen(_delta)
	
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("shoot") and shoot_timer.is_stopped():
		shoot()

func shoot():
		if bullet_scene:
			if "triple_shot" in active_abilities:
				var angles = [-0.26, 0.0, 0.26]
				for angle in angles:
					spawn_bullet(angle)
				
			else:
				spawn_bullet(0.0)
				
			var cd = 0.4 * attack_cooldown_mult
			if "berserk" in active_abilities:
				var missing_hp = 2.0 - (float(health) / max_health)
				cd *= 1.0 - (missing_hp * 0.25)
				
				
			shoot_timer.start(cd)
			
func spawn_bullet(angle_offset: float):
	var bullet = bullet_scene.instantiate()
	
	bullet.current_pierce = pierce_count
	bullet.knockback = knockback_force
	
	if "ricochet" in active_abilities:
		bullet.bounce_count = 3
	if "chain_lightning" in active_abilities:
		bullet.chain_count = 3
	if "boomerang" in active_abilities:
		bullet.is_boomerang = true
		bullet.player_ref = self
		
	var final_damage = 1.0 * damage_multiplier
	if "berserk" in active_abilities:
		var missing_hp = 1.0 - (float(health) / max_health)
		final_damage *= 1.0 + missing_hp
	
	if randf() <= crit_chance:
		final_damage *= 2.0
	bullet.damage = final_damage
	
	bullet.global_position = $Muzzle.global_position
	bullet.global_rotation = global_rotation + angle_offset
	
	bullet.scale *= bullet_size_multiplier
	
	get_tree().current_scene.add_child(bullet)

var health: int = 5
var max_health: int = 5
var is_invulnerable: bool = false

@onready var invul_timer: Timer = $InvulTimer

func _ready() -> void:
	if upgrade_menu_scene:
		menu_instance = upgrade_menu_scene.instantiate()
		
		get_tree().current_scene.add_child.call_deferred(menu_instance)
	
	invul_timer.wait_time = 1.5
	invul_timer.one_shot = true
	invul_timer.timeout.connect(_on_invul_timeout)
	
	add_to_group("player")
	
	update_health_bar()
	update_kills_ui()

func update_kills_ui():
	if kills_label:
		kills_label.text = str(kills_count)
	
func take_damage(amount: int):
	
	if is_invulnerable:
		return
		
	health -= amount
	update_health_bar()
	
	if health <= 0:
		die()
	else:
		is_invulnerable = true
		
		var tween = create_tween().set_loops(4)
		tween.tween_property($Sprite2D, "modulate:a", 0.2, 0.1)
		tween.tween_property($Sprite2D, "modulate:a", 1.0, 0.1)
		
		invul_timer.start()
		
		
func _on_invul_timeout():
	is_invulnerable = false

func die():
	if is_dead:
		return
	is_dead = true
	
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")
	
func apply_mud_slow(reduction: float) -> void:
	slow_modifier = 1.0 - reduction
	
func remove_mud_slow() -> void:
	slow_modifier = 1.0

func unlock_ability(ability_id: String) -> void:
	if ability_id in active_abilities:
		return
	
	active_abilities.append(ability_id)
	
	AbilityLibrary.apply_ability(ability_id, self)

func update_health_bar():
	if health_bar:
		health_bar.value = health

func heal(amount: int) -> void:
	health = min(health + amount, 5)
	update_health_bar()
	
func handle_regen(delta: float) -> void:
# Проверяем, куплена ли способность и не полное ли здоровье
	if "passive_regen" in active_abilities and health < max_health:
		regen_timer += delta
		if regen_timer >= 30.0:
			regen_timer = 0.0
			heal(1)
	else:
# Сбрасываем таймер, если HP полное или способности нет
		regen_timer = 0.0
