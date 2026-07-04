class_name DialogueChoice
extends RefCounted

var text: String = ""
var next_id: String = ""

func _init(data: Dictionary = {}) -> void:
	text = str(data.get("text", ""))
	next_id = str(data.get("next", ""))