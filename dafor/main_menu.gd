extends Control

@export_file("*.tscn") var level_scene: String = "res://main_menu.tscn"
func _ready() -> void:
	get_tree().paused = false
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(level_scene)
	
func _on_quit_pressed() -> void:
	get_tree().quit()
