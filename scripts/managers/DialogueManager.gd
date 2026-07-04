extends Node

signal line_changed(line: Dictionary)
signal dialogue_finished

var dialogue_data: Array = []
var current_index: int = 0
var is_running: bool = false

func start(dialogue_name: String) -> void:
	var path := "res://data/dialogues/%s.json" % dialogue_name

	dialogue_data = _load_dialogue_file(path)
	current_index = 0
	is_running = true

	if dialogue_data.is_empty():
		push_error("Dialogue is empty: " + dialogue_name)
		dialogue_finished.emit()
		return

	_emit_current_line()

func next() -> void:
	if not is_running:
		return

	current_index += 1

	if current_index >= dialogue_data.size():
		is_running = false
		dialogue_finished.emit()
		return

	_emit_current_line()

func stop() -> void:
	is_running = false
	dialogue_data = []
	current_index = 0
	dialogue_finished.emit()

func get_current_line() -> Dictionary:
	if not is_running:
		return {}

	if current_index < 0 or current_index >= dialogue_data.size():
		return {}

	return dialogue_data[current_index]

func _emit_current_line() -> void:
	var line := get_current_line()

	if line.is_empty():
		dialogue_finished.emit()
		return

	line_changed.emit(line)

func _load_dialogue_file(path: String) -> Array:
	if not FileAccess.file_exists(path):
		push_error("Dialogue file not found: " + path)
		return []

	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	var parsed = JSON.parse_string(content)

	if parsed == null:
		push_error("Invalid JSON: " + path)
		return []

	if typeof(parsed) != TYPE_ARRAY:
		push_error("Dialogue JSON must be an Array: " + path)
		return []

	return parsed