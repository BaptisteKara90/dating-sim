class_name DialogueLoader
extends RefCounted

const DialogueScript = preload("res://scripts/models/Dialogue.gd")

func load_dialogue(dialogue_name: String):
	var path := "res://data/dialogues/%s.json" % dialogue_name

	if not FileAccess.file_exists(path):
		push_error("Dialogue file not found : " + path)
		return DialogueScript.new()

	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("Unable to open dialogue : " + path)
		return DialogueScript.new()

	var json := file.get_as_text()

	var parsed = JSON.parse_string(json)

	if parsed == null:
		push_error("Invalid JSON : " + path)
		return DialogueScript.new()

	if typeof(parsed) != TYPE_ARRAY:
		push_error("Dialogue JSON must contain an array.")
		return DialogueScript.new()

	return DialogueScript.new(parsed)