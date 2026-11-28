extends Area2D

var speed: float = 250.0
var direction: Vector2 = Vector2.ZERO
var damage: float = 1.0

# Переменные для бумеранга босса
var is_boomerang: bool = false
var boss_ref: Node2D = null
var boomerang_timer: float = 0.0
var is_returning: bool = false

func _physics_process(delta: float) -> void:
	if not is_boomerang:
		global_position += direction * speed * delta
		return

	boomerang_timer += delta

	if not is_returning:
		global_position += direction * 360.0 * delta
		if boomerang_timer >= 3.3:
			is_returning = true
			
	else:
# Возвращаемся к боссу, если он еще жив
		if is_instance_valid(boss_ref):
			direction = (boss_ref.global_position - global_position).normalized()
			speed = move_toward(speed, 450.0, 800.0 * delta)
			global_position += direction * speed * delta
# Босс поймал снаряд обратно
			if global_position.distance_to(boss_ref.global_position) < 25.0:
				queue_free()
		else:
# Если босс умер во время полета пули — удаляем её
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
		return

# Игнорируем врагов
	if body.is_in_group("enemies"):
		return
# Если задели стену или любое другое препятствие — уничтожаем снаряд
	queue_free()
