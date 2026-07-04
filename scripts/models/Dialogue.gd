class_name Dialogue
extends RefCounted

const DialogueLineScript = preload("res://scripts/models/DialogueLine.gd")

var lines: Dictionary = {}
var first_line_id: String = ""

func _init(data: Array = []) -> void:
	for line_data in data:
		var line := DialogueLineScript.new(line_data)

		if line.id == "":
			push_error("Dialogue line missing id")
			continue

		if first_line_id == "":
			first_line_id = line.id

		lines[line.id] = line

func get_line(id: String):
	return lines.get(id, null)

func has_line(id: String) -> bool:
	return lines.has(id)

func is_empty() -> bool:
	return lines.is_empty()