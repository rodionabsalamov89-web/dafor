class_name AbilityLibrary
extends Node

static func apply_ability(ability_id: String, player: CharacterBody2D) -> void:
	match ability_id:
		"clean_boots":
			player.immune_to_mud = true #иммунен к лужам
			
		"coffee_boost":
			player.bonus_speed_mult = 1.5
			
		"fast_trigger":
			player.attack_cooldown_mult = 0.6
			
		"triple_shot":
			pass
			
		"heavy_bullet":
			player.damage_multiplier = 1.5
			
		"piercing_shot":
			player.pierce_count += 1
			
		"vampirism":
			player.vampire_chance += 0.05
		"big_shot":
			player.bullet_size_multiplier = 1.35
			
		"buy_slot":
			player.max_ability_slots += 1
		"crit punch":
			player.crit_chance = 0.25
		"knockback":
			player.knockback_force += 15.0
		"berserk":
			pass
		"ricochet":
			pass
		"chain_lightning":
			pass
		"passive_regen":
			pass
		"boomerang":
			pass
