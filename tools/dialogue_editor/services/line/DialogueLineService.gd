class_name DialogueLineService
extends RefCounted

const DialogueIdGeneratorScript: RefCounted = preload(
	"res://tools/dialogue_editor/services/line/DialogueIdGenerator.gd"
)

const DialogueValidatorScript: RefCounted = preload(
	"res://tools/dialogue_editor/services/validation/DialogueValidator.gd"
)

var id_generator: DialogueIdGeneratorScript
var validator: DialogueValidatorScript

func _init(
	new_id_generator: DialogueIdGeneratorScript,
	new_validator: DialogueValidatorScript
) -> void:
	id_generator = new_id_generator
	validator = new_validator


func generate_new_line_id(
	dialogue_name: String,
	dialogue_lines: Array[Dictionary]
) -> String:
	var line_number: int = dialogue_lines.size() + 1
	var generated_id: String = id_generator.generate_line_id(
		dialogue_name,
		line_number
	)

	while validator.line_id_exists(
		dialogue_lines,
		generated_id
	):
		line_number += 1
		generated_id = id_generator.generate_line_id(
			dialogue_name,
			line_number
		)

	return generated_id


func get_linear_next_id(
	dialogue_name: String,
	dialogue_lines: Array[Dictionary],
	selected_line_index: int
) -> String:
	if selected_line_index >= 0:
		var existing_line: Dictionary = dialogue_lines[
			selected_line_index
		]

		return str(existing_line.get("next", ""))

	var line_number: int = dialogue_lines.size() + 2

	return id_generator.generate_line_id(
		dialogue_name,
		line_number
	)


func extract_choices(
	line: Dictionary
) -> Array[Dictionary]:
	var choices: Array[Dictionary] = []

	if not line.has("choices"):
		return choices

	var raw_choices: Array = line.get("choices", [])

	for raw_choice: Variant in raw_choices:
		if raw_choice is Dictionary:
			choices.append(raw_choice as Dictionary)

	return choices


func get_existing_line_ids(
	dialogue_lines: Array[Dictionary]
) -> Array[String]:
	var line_ids: Array[String] = []

	for line: Dictionary in dialogue_lines:
		var line_id: String = str(line.get("id", ""))

		if not line_id.is_empty():
			line_ids.append(line_id)

	return line_ids