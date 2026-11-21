extends Area2D

var damage: float = 1.0
var current_pierce: int = 1
var hit_targets: Array = []
var knockback: float = 0.0
var bounce_count: int = 0
var chain_count: int = 0
var is_boomerang: bool = false
var player_ref: Node2D = null
var boomerang_timer: float = 0.0
var is_returning: bool = false
@onready var ray: RayCast2D = $RayCast2D

@export var speed: float = 600.0
func _physics_process(delta: float) -> void:
	if not is_boomerang:
		position += transform.x * speed * delta
		return
	boomerang_timer += delta
	if not is_returning:
		speed = move_toward(speed, 0.0, 200.0 * delta)
		position += transform.x * speed * delta
		
		if boomerang_timer >= 1.4:
			is_returning = true
			hit_targets.clear() 
	else:
		if is_instance_valid(player_ref):
			var dir_to_player = (player_ref.global_position - global_position).normalized()
			rotation = dir_to_player.angle()
			speed = move_toward(speed, 750.0, 1600.0 * delta)
			position += transform.x * speed * delta
			if global_position.distance_to(player_ref.global_position) < 25.0:
				queue_free()
		else:
			queue_free()

	
func on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not is_boomerang:
		queue_free()

func _on_body_entered(body) -> void:
	if body.is_in_group("Pit"):
		return
	
	if body.is_in_group("player"):
		return
		
	if body is StaticBody2D:
		if bounce_count > 0 and not is_returning:
			ray.force_raycast_update()
			if ray.is_colliding():
				var normal = ray.get_collision_normal()
				var new_dir = transform.x.bounce(normal)
				rotation = new_dir.angle()
				global_position += normal * 6.0
				bounce_count -= 1
				hit_targets.clear()
				return
		queue_free()
		return
	
	if body in hit_targets:
		return
	hit_targets.append(body)
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
		if chain_count > 0:
			trigger_chain_lightning(body)
		
		if knockback > 0 and body is CharacterBody2D:
			if not body.get("knockback_immune"):
				var push_dir = Vector2.RIGHT.rotated(rotation)
				body.move_and_collide(push_dir * knockback)
		
	current_pierce -= 1
	if current_pierce <= 0:
		queue_free()

func trigger_chain_lightning(first_target: Node2D) -> void:
	var jump_radius := 250.0
	var chain_damage := damage * 0.7 # 70% от текущего урона пули
	var shocked := [first_target] # Список уже пораженных молнией
	var current_source := first_target

	for i in range(chain_count):
		var next_target = find_closest_enemy(current_source.global_position, jump_radius, shocked)
		if next_target == null:
			break

		if next_target.has_method("take_damage"):
			next_target.take_damage(chain_damage)

		spawn_lightning_visual(current_source.global_position, next_target.global_position)
		shocked.append(next_target)
		current_source = next_target

func find_closest_enemy(origin: Vector2, radius: float, ignore_list: Array) -> Node2D:
	var closest: Node2D = null
	var min_dist := radius

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy in ignore_list or enemy.is_in_group("player"):
			continue

		var dist = origin.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy

	return closest

func spawn_lightning_visual(from_pos: Vector2, to_pos: Vector2) -> void:
	var line = Line2D.new()
	line.width = 5.0
	line.default_color = Color(0.2, 1.5, 2.0)

	line.add_point(from_pos)
	var mid = from_pos.lerp(to_pos, 0.5) + Vector2(randf_range(-16, 16), randf_range(-16, 16))
	line.add_point(mid)
	line.add_point(to_pos)

	get_tree().current_scene.add_child(line)

	var tween = line.create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.35)
	tween.tween_callback(line.queue_free)
