extends Area2D
@export var speed: float = 250.0
@export var max_distance: float = 500.0
@export var slow_amount: float = 0.4
@export var slow_duration: float = 2.0
var direction: Vector2 = Vector2.ZERO
var traveled_distance: float = 0.0
var has_hit: bool = false
func _physics_process(delta: float) -> void:
	if has_hit:
		return
	var step = speed * delta
	position += direction * step
	traveled_distance += step# Если ни в кого не попал и пролетел короткую дистанцию — просто исчезает
	if traveled_distance >= max_distance:
		queue_free()
func _on_body_entered(body: Node2D) -> void:
	if has_hit:
		return # Если попал в игрока (проверяем и по имени, и по группе на всякий случай)
	if body.name == "Player" or body.is_in_group("player"):
		has_hit = true # Проверяем иммунитет к грязи 
		if "immune_to_mud" in body and body.immune_to_mud:
			queue_free()
			return
		if body.has_method("apply_mud_slow"):
			body.apply_mud_slow(slow_amount) # Делаем снаряд невидимым и отключаем коллизию, пока тикает таймер
			hide()
			$CollisionShape2D.set_deferred("disabled", true) # Ждем 2 секунды и снимаем замедление
			await get_tree().create_timer(slow_duration).timeout
			if is_instance_valid(body) and body.has_method("remove_mud_slow"):
				body.remove_mud_slow()
		queue_free()			# Если врезался в стену — просто исчезает
	elif body is StaticBody2D:
		queue_free()
