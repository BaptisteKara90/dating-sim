class_name DialogueLine
extends RefCounted

const DialogueChoiceScript = preload("res://scripts/models/DialogueChoice.gd")

var id: String = ""
var speaker: String = ""
var text: String = ""
var next_id: String = ""
var choices: Array = []

func _init(data: Dictionary = {}) -> void:
	id = str(data.get("id", ""))
	speaker = str(data.get("speaker", ""))
	text = str(data.get("text", ""))
	next_id = str(data.get("next", ""))

	for choice_data in data.get("choices", []):
		choices.append(DialogueChoiceScript.new(choice_data))

func has_choices() -> bool:
	return choices.size() > 0