extends Control

const DialogueIdGeneratorScript = preload(
	"res://tools/dialogue_editor/services/DialogueIdGenerator.gd"
)
const DialogueLineBuilderScript = preload(
	"res://tools/dialogue_editor/services/DialogueLineBuilder.gd"
)
const DialogueValidatorScript = preload(
	"res://tools/dialogue_editor/services/DialogueValidator.gd"
)
const DialogueFileWriterScript = preload(
	"res://tools/dialogue_editor/services/DialogueFileWriter.gd"
)
const ChoiceRowScript = preload(
	"res://tools/dialogue_editor/components/ChoiceRow.gd"
)
const CHOICE_ROW_SCENE: PackedScene = preload(
	"res://tools/dialogue_editor/components/ChoiceRow.tscn"
)

@onready var dialogue_name_input: LineEdit = %DialogueNameInput
@onready var character_select: OptionButton = %CharacterSelect
@onready var emotion_select: OptionButton = %EmotionSelect
@onready var dialogue_text_input: TextEdit = %DialogueTextInput
@onready var has_choices_check_box: CheckBox = %HasChoicesCheckBox
@onready var choices_container: VBoxContainer = %ChoicesContainer
@onready var add_choice_button: Button = %AddChoiceButton
@onready var add_line_button: Button = %AddLineButton
@onready var save_button: Button = %SaveButton
@onready var status_label: Label = %StatusLabel

var dialogue_lines: Array[Dictionary] = []

var id_generator: DialogueIdGeneratorScript = DialogueIdGeneratorScript.new()
var line_builder: DialogueLineBuilderScript = DialogueLineBuilderScript.new()
var validator: DialogueValidatorScript = DialogueValidatorScript.new()
var file_writer: DialogueFileWriterScript = DialogueFileWriterScript.new()


func _ready() -> void:
	_initialize_characters()
	_initialize_emotions()
	_connect_signals()
	_update_choices_visibility()


func _connect_signals() -> void:
	has_choices_check_box.toggled.connect(
		_on_has_choices_toggled
	)
	add_choice_button.pressed.connect(
		_on_add_choice_pressed
	)
	add_line_button.pressed.connect(
		_on_add_line_button_pressed
	)
	save_button.pressed.connect(
		_on_save_button_pressed
	)


func _initialize_characters() -> void:
	character_select.clear()
	character_select.add_item("Narrateur")
	character_select.add_item("Lady Eleanor")
	character_select.add_item("Lord Ashford")


func _initialize_emotions() -> void:
	emotion_select.clear()
	emotion_select.add_item("Neutre")
	emotion_select.add_item("Heureux")
	emotion_select.add_item("Triste")
	emotion_select.add_item("En colère")
	emotion_select.add_item("Surpris")


func _on_has_choices_toggled(_enabled: bool) -> void:
	_update_choices_visibility()


func _update_choices_visibility() -> void:
	var has_choices: bool = (
		has_choices_check_box.button_pressed
	)

	choices_container.visible = has_choices
	add_choice_button.visible = has_choices


func _on_add_choice_pressed() -> void:
	var row: ChoiceRowScript = (
		CHOICE_ROW_SCENE.instantiate() as ChoiceRowScript
	)

	if row == null:
		_set_status(
			"Impossible de créer la ligne de choix."
		)
		return

	row.remove_requested.connect(
		_on_choice_remove_requested
	)

	choices_container.add_child(row)


func _on_choice_remove_requested(
	row: HBoxContainer
) -> void:
	row.queue_free()


func _on_add_line_button_pressed() -> void:
	var dialogue_name: String = (
		dialogue_name_input.text.strip_edges()
	)
	var dialogue_text: String = (
		dialogue_text_input.text.strip_edges()
	)

	var dialogue_name_error: String = (
		validator.validate_dialogue_name(dialogue_name)
	)

	if not dialogue_name_error.is_empty():
		_set_status(dialogue_name_error)
		return

	var speaker_id: String = _get_selected_character_id()
	var emotion_id: String = _get_selected_emotion_id()

	var line_error: String = validator.validate_line(
		dialogue_text,
		speaker_id
	)

	if not line_error.is_empty():
		_set_status(line_error)
		return

	var line_number: int = dialogue_lines.size() + 1
	var line_id: String = id_generator.generate_line_id(
		dialogue_name,
		line_number
	)

	if line_id.is_empty():
		_set_status(
			"Impossible de générer l'identifiant."
		)
		return

	if validator.line_id_exists(dialogue_lines, line_id):
		_set_status(
			"L'identifiant existe déjà : " + line_id
		)
		return

	var line: Dictionary

	if has_choices_check_box.button_pressed:
		var choices: Array[Dictionary] = _collect_choices(
			line_id
		)

		var choices_error: String = (
			validator.validate_choices(choices)
		)

		if not choices_error.is_empty():
			_set_status(choices_error)
			return

		line = line_builder.build_choice_line(
			line_id,
			speaker_id,
			emotion_id,
			dialogue_text,
			choices
		)
	else:
		var next_id: String = (
			id_generator.generate_line_id(
				dialogue_name,
				line_number + 1
			)
		)

		line = line_builder.build_linear_line(
			line_id,
			speaker_id,
			emotion_id,
			dialogue_text,
			next_id
		)

	dialogue_lines.append(line)

	# Les IDs dépendent du nom : on le verrouille.
	dialogue_name_input.editable = false

	_set_status("Ligne ajoutée : " + line_id)
	_reset_line_form()


func _collect_choices(
	parent_line_id: String
) -> Array[Dictionary]:
	var choices: Array[Dictionary] = []
	var choice_number: int = 1

	for child: Node in choices_container.get_children():
		if child is not ChoiceRowScript:
			continue

		var row: ChoiceRowScript = child as ChoiceRowScript
		var choice_text: String = row.get_choice_text()

		if choice_text.is_empty():
			continue

		var next_id: String = (
			id_generator.generate_choice_target_id(
				parent_line_id,
				choice_number
			)
		)

		var choice: Dictionary = {
			"text": choice_text,
			"next": next_id
		}

		choices.append(choice)
		choice_number += 1

	return choices


func _on_save_button_pressed() -> void:
	var dialogue_name: String = (
		dialogue_name_input.text.strip_edges()
	)

	var dialogue_name_error: String = (
		validator.validate_dialogue_name(dialogue_name)
	)

	if not dialogue_name_error.is_empty():
		_set_status(dialogue_name_error)
		return

	if dialogue_lines.is_empty():
		_set_status(
			"Le dialogue ne contient aucune ligne."
		)
		return

	var save_error: String = file_writer.save(
		dialogue_name,
		dialogue_lines
	)

	if not save_error.is_empty():
		_set_status(save_error)
		push_error(save_error)
		return

	var file_path: String = file_writer.get_file_path(
		dialogue_name
	)

	_set_status("Dialogue sauvegardé : " + file_path)


func _reset_line_form() -> void:
	dialogue_text_input.clear()
	has_choices_check_box.button_pressed = false

	for child: Node in choices_container.get_children():
		child.queue_free()

	_update_choices_visibility()


func _set_status(message: String) -> void:
	status_label.text = message
	print(message)


func _get_selected_character_id() -> String:
	match character_select.selected:
		0:
			return "narrator"
		1:
			return "lady_eleanor"
		2:
			return "lord_ashford"
		_:
			return ""


func _get_selected_emotion_id() -> String:
	match emotion_select.selected:
		0:
			return "neutral"
		1:
			return "happy"
		2:
			return "sad"
		3:
			return "angry"
		4:
			return "surprised"
		_:
			return "neutral"