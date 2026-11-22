extends CanvasLayer
var player_ref: CharacterBody2D
var ability_pool: Array[String] = ["triple_shot", "coffee_boost", "fast_trigger", "clean_boots", "heavy_bullet", "piercing_shot", "vampirism", "big_shot", "crit punch", "knockback", "berserk", "ricochet", "chain_lightning", "passive_regen", "boomerang"]
var current_choices: Array[String] = []
var ability_requirements = {
	"clean_boots": 10,
	"coffee_boost": 25,
	"triple_shot": 45,
	"fast_trigger": 35,
	"heavy_bullet": 5,
	"piercing_shot": 30,
	"vampirism": 30,
	"big_shot": 20,
	"crit punch": 30,
	"knockback": 40,
	"berserk": 60,
	"ricochet": 40,
	"chain_lightning": 55,
	"passive_regen": 35,
	"boomerang": 50
	}
	

func _ready() -> void:
	visible = false	
	var btn_1 = find_child("Button1") as Button
	var btn_2 = find_child("Button2") as Button
	var btn_3 = find_child("Button3") as Button
	
	var close_btn = find_child("CloseButton") as Button
		
	if btn_1: btn_1.pressed.connect(_on_card_selected.bind(0))
	if btn_2: btn_2.pressed.connect(_on_card_selected.bind(1))
	if btn_3: btn_3.pressed.connect(_on_card_selected.bind(2))
	
	if close_btn: close_btn.pressed.connect(_on_close_button_pressed)
		
func open_upgrade_menu(player: CharacterBody2D) -> void:
	var kills_label = find_child("KillsLabel") as Label
	
	if kills_label:
		kills_label.text = "" + str(player.kills_count)
	
	player_ref = player 
	
	if current_choices.is_empty():
		var temp_pool = []
	
		if player.active_abilities.size() >= player.max_ability_slots:
			temp_pool = ["buy_slot"]
			
		else:
			for ab_id in ability_pool:
				var required_kills = ability_requirements.get(ab_id, 0)
				if player.kills_count >= required_kills:
					if not temp_pool.has(ab_id):
						temp_pool.append(ab_id)
			
		temp_pool.shuffle()

		var buttons_to_show  = min(3, temp_pool.size())

		for i in range(buttons_to_show):
			current_choices.append(temp_pool[i])
	var btn_1 = find_child("Button1") as Button
	var btn_2 = find_child("Button2") as Button
	var btn_3 = find_child("Button3") as Button
	
	if btn_1: btn_1.visible = false
	if btn_2: btn_2.visible = false
	if btn_3: btn_3.visible = false
				
	var price_label = btn_1.find_child("PriceLabel") as Label
	if current_choices.size() > 0 and btn_1:
		var ab_id = current_choices[0]
		btn_1.text = get_ability_name(ab_id)
		btn_1.visible = true

		if price_label:
			ab_id = current_choices[0]
			var cost = 0
		
			if ab_id == "buy_slot":
				cost = player.slot_upgrade_cost
			else:
				cost = ability_requirements.get(ab_id)
				
			price_label.text = str(cost) + " Монет"

	if current_choices.size() >1 and btn_2:
		var ab_id = current_choices[1]
		btn_2.text = get_ability_name(ab_id)
		btn_2.visible = true
		
		price_label = btn_2.find_child("PriceLabel") as Label
		
		if price_label:
			ab_id = current_choices[1]
			var cost = 0
		
			if ab_id == "buy_slot":
				cost = player.slot_upgrade_cost
			else:
				cost = ability_requirements.get(ab_id)
				
			price_label.text = str(cost) + " Монет"
		
	if current_choices.size() >2 and btn_3:
		var ab_id = current_choices[2]
		btn_3.text = get_ability_name(ab_id)
		btn_3.visible = true
		
		price_label = btn_3.find_child("PriceLabel") as Label
		
		if price_label:
			ab_id = current_choices[2]
			var cost = 0
		
			if ab_id == "buy_slot":
				cost = player.slot_upgrade_cost
			else:
				cost = ability_requirements.get(ab_id)
				
			price_label.text = str(cost) + " Монет"
	
	show()
	get_tree().paused = true
			
func get_ability_name(id: String) -> String:
	match id:
		"triple_shot": return "Веер\n(Стрельба тремя снарядами)"
		"coffee_boost": return "Кофеин\n(Скорость бега +50%)"
		"fast_trigger": return "Легкий Курок\n(Скорость атаки +40%)"
		"clean_boots": return "Чистые Сапоги\n(Иммунитет к лужам)"
		"heavy_bullet": return "Тяжелые вещества\n(Снаряды наносят на 50% больше)"
		"piercing_shot": return "Пробивной снаряд\n(Ваши снаряды пробивают врагов насквозь)"
		"vampirism": return "Вампиризм\n(С шансом 5% при убийстве вы восстановите 1 хп)"
		"big_shot": return "[[БОЛЬШАЯ ШИШКА]]\n(Ваши снаряды больше на 35%)"
		"buy_slot": return "СЛОТЫ\n(дополнительный слот под способности)"
		"crit punch": return "CRITICAL SHIT\n(ДВОЙНОЙ УРОН С ШАНСОМ 25%? OH SHIT!)"
		"knockback": return "Отталкивание\n(Ваши снаряды отталкивают)"
		"berserk": return "БЕРСЕРК\n(Чем меньше хп тем больше урон)"
		"ricochet": return "Рикошет\n(Ваши пули отскакивают)"
		"chain_lightning": return "Цепная реакция\n(Название говорит само за себя)"
		"passive_regen": return "Пассивное лечение\n(+1 хп раз в 35 секунд)"
		"boomerang": return "Бумеранг\n(Ваши снаряды возвращаются к вам)"
		_: return id
		
func _on_card_selected(index: int) -> void:
	if index >= current_choices.size(): return
	
	var chosen_ability = current_choices[index]
	
	var cost = 0
	if chosen_ability == "buy_slot":
		cost = player_ref.slot_upgrade_cost
	else:
		cost = ability_requirements.get(chosen_ability, 0)
	
	if player_ref:
		if player_ref.kills_count >= cost:
			player_ref.kills_count -= cost
			
			if chosen_ability == "buy_slot":
				player_ref.max_ability_slots += 1
				player_ref.slot_upgrade_cost += 10
			
			
		if chosen_ability != "buy_slot":
			ability_pool.erase(chosen_ability)
		
			AbilityLibrary.apply_ability(chosen_ability, player_ref)
	
			if player_ref.has_method("unlock_ability"):
				player_ref.unlock_ability(chosen_ability)
	
	current_choices.clear()
	
	_on_close_button_pressed()
			
func _on_close_button_pressed() -> void:
	get_tree().paused = false
	hide()
