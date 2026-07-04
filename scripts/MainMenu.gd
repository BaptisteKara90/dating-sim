extends Control

func _ready():
	print("Bonjour Godot !")

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")
