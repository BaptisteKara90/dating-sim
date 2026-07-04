extends Node

const DialogueLoaderScript = preload("res://scripts/loaders/DialogueLoader.gd")
const DialogueLine = preload("res://scripts/models/DialogueLine.gd")
const DialogueChoice = preload("res://scripts/models/DialogueChoice.gd")

signal line_changed(line)
signal choices_changed(choices: Array)
signal dialogue_finished

var current_dialogue = null
var current_line_id: String = ""
var is_running: bool = false

func start(dialogue_name: String, start_id: String = "") -> void:
	var loader := DialogueLoaderScript.new()
	current_dialogue = loader.load_dialogue(dialogue_name)

	if current_dialogue == null or current_dialogue.is_empty():
		push_error("Dialogue is empty: " + dialogue_name)
		_finish_dialogue()
		return

	is_running = true

	if start_id != "":
		current_line_id = start_id
	else:
		current_line_id = current_dialogue.first_line_id

	_emit_current_line()

func next() -> void:
	if not is_running:
		return

	var line: DialogueLine = get_current_line()

	if line == null:
		_finish_dialogue()
		return

	if line.has_choices():
		return

	if line.next_id == "":
		_finish_dialogue()
		return

	go_to(line.next_id)

func choose(choice_index: int) -> void:
	if not is_running:
		return

	var line: DialogueLine = get_current_line()

	if line == null or not line.has_choices():
		return

	if choice_index < 0 or choice_index >= line.choices.size():
		return

	var choice: DialogueChoice = line.choices[choice_index]

	if choice.next_id == "":
		_finish_dialogue()
		return

	go_to(choice.next_id)

func go_to(line_id: String) -> void:
	if current_dialogue == null or not current_dialogue.has_line(line_id):
		push_error("Dialogue id not found: " + line_id)
		_finish_dialogue()
		return

	current_line_id = line_id
	_emit_current_line()

func get_current_line() -> DialogueLine:
	if not is_running or current_dialogue == null:
		return null

	return current_dialogue.get_line(current_line_id)

func _emit_current_line() -> void:
	var line: DialogueLine = get_current_line()

	if line == null:
		_finish_dialogue()
		return

	line_changed.emit(line)
	choices_changed.emit(line.choices)

func _finish_dialogue() -> void:
	is_running = false
	current_line_id = ""
	current_dialogue = null
	choices_changed.emit([])
	dialogue_finished.emit()