extends Node

signal line_changed(line: Dictionary)
signal choices_changed(choices: Array)
signal dialogue_finished

var dialogue_data: Array = []
var dialogue_by_id: Dictionary = {}
var current_line_id: String = ""
var is_running: bool = false

func start(dialogue_name: String, start_id: String = "") -> void:
	var path := "res://data/dialogues/%s.json" % dialogue_name

	dialogue_data = _load_dialogue_file(path)
	dialogue_by_id = _build_dialogue_index(dialogue_data)

	if dialogue_data.is_empty():
		push_error("Dialogue is empty: " + dialogue_name)
		dialogue_finished.emit()
		return

	is_running = true

	if start_id != "":
		current_line_id = start_id
	else:
		current_line_id = dialogue_data[0].get("id", "")

	_emit_current_line()

func next() -> void:
	if not is_running:
		return

	var line := get_current_line()

	if line.has("choices"):
		return

	var next_id: String = str(line.get("next", ""))

	if next_id == "":
		_finish_dialogue()
		return

	go_to(next_id)

func choose(choice_index: int) -> void:
	if not is_running:
		return

	var line := get_current_line()
	var choices: Array = line.get("choices", [])

	if choice_index < 0 or choice_index >= choices.size():
		return

	var choice: Dictionary = choices[choice_index]
	var next_id: String = str(choice.get("next", ""))

	if next_id == "":
		_finish_dialogue()
		return

	go_to(next_id)

func go_to(line_id: String) -> void:
	if not dialogue_by_id.has(line_id):
		push_error("Dialogue id not found: " + line_id)
		_finish_dialogue()
		return

	current_line_id = line_id
	_emit_current_line()

func get_current_line() -> Dictionary:
	if not is_running:
		return {}

	return dialogue_by_id.get(current_line_id, {})

func _emit_current_line() -> void:
	var line := get_current_line()

	if line.is_empty():
		_finish_dialogue()
		return

	line_changed.emit(line)

	if line.has("choices"):
		choices_changed.emit(line["choices"])
	else:
		choices_changed.emit([])

func _finish_dialogue() -> void:
	is_running = false
	current_line_id = ""
	dialogue_finished.emit()
	choices_changed.emit([])

func _build_dialogue_index(data: Array) -> Dictionary:
	var index := {}

	for line in data:
		if not line.has("id"):
			push_error("Dialogue line missing id")
			continue

		index[line["id"]] = line

	return index

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