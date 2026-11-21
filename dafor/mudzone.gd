extends Area2D

@export var speed_reduction: float = 0.4

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.name == "Player":
		if "immune_to_mud" in body and body.immune_to_mud:
			return
	if body.has_method("apply_mud_slow"):
		body.apply_mud_slow(speed_reduction)
		
func _on_body_exited(body: CharacterBody2D) -> void:
	if body.has_method("remove_mud_slow"):
		body.remove_mud_slow()
