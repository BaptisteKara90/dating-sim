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
const DialogueFileReaderScript = preload(
	"res://tools/dialogue_editor/services/DialogueFileReader.gd"
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

@onready var open_button: Button = %OpenButton
@onready var new_button: Button = %NewButton
@onready var current_file_label: Label = %CurrentFileLabel
@onready var open_file_dialog: FileDialog = %OpenFileDialog
@onready var lines_list: ItemList = %LinesList

var dialogue_lines: Array[Dictionary] = []
var current_file_path: String = ""
var selected_line_index: int = -1

var id_generator: DialogueIdGeneratorScript = DialogueIdGeneratorScript.new()
var line_builder: DialogueLineBuilderScript = DialogueLineBuilderScript.new()
var validator: DialogueValidatorScript = DialogueValidatorScript.new()
var file_writer: DialogueFileWriterScript = DialogueFileWriterScript.new()
var file_reader: DialogueFileReaderScript = DialogueFileReaderScript.new()


func _ready() -> void:
	_initialize_characters()
	_initialize_emotions()
	_configure_file_dialog()
	_connect_signals()
	_start_new_dialogue()


# ---------------------------------------------------------------------------
# Initialisation
# ---------------------------------------------------------------------------

func _connect_signals() -> void:
	has_choices_check_box.toggled.connect(_on_has_choices_toggled)
	add_choice_button.pressed.connect(_on_add_choice_pressed)
	add_line_button.pressed.connect(_on_add_line_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)

	open_button.pressed.connect(_on_open_button_pressed)
	new_button.pressed.connect(_on_new_button_pressed)
	open_file_dialog.file_selected.connect(_on_dialogue_file_selected)
	lines_list.item_selected.connect(_on_line_selected)


func _configure_file_dialog() -> void:
	open_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	open_file_dialog.access = FileDialog.ACCESS_RESOURCES
	open_file_dialog.current_dir = "res://data/dialogues"
	open_file_dialog.filters = PackedStringArray([
		"*.json ; Fichiers de dialogue JSON"
	])


func _initialize_characters() -> void:
	character_select.clear()

	_add_option(character_select, "Narrateur", "narrator")
	_add_option(character_select, "Lady Eleanor", "lady_eleanor")
	_add_option(character_select, "Lord Ashford", "lord_ashford")


func _initialize_emotions() -> void:
	emotion_select.clear()

	_add_option(emotion_select, "Neutre", "neutral")
	_add_option(emotion_select, "Heureux", "happy")
	_add_option(emotion_select, "Triste", "sad")
	_add_option(emotion_select, "En colère", "angry")
	_add_option(emotion_select, "Surpris", "surprised")


func _add_option(
	option_button: OptionButton,
	label: String,
	value: String
) -> void:
	option_button.add_item(label)

	var item_index: int = option_button.item_count - 1
	option_button.set_item_metadata(item_index, value)


# ---------------------------------------------------------------------------
# Nouveau dialogue / ouverture
# ---------------------------------------------------------------------------

func _on_new_button_pressed() -> void:
	_start_new_dialogue()


func _start_new_dialogue() -> void:
	dialogue_lines.clear()
	current_file_path = ""
	selected_line_index = -1

	dialogue_name_input.clear()
	dialogue_name_input.editable = true
	current_file_label.text = "Aucun fichier ouvert"

	lines_list.clear()
	_clear_editor_form()
	_set_status("Nouveau dialogue.")


func _on_open_button_pressed() -> void:
	open_file_dialog.popup_centered_ratio(0.75)


func _on_dialogue_file_selected(file_path: String) -> void:
	var loaded_lines: Array[Dictionary] = file_reader.load(file_path)

	if loaded_lines.is_empty():
		_set_status("Impossible de charger le dialogue, ou le fichier est vide.")
		return

	dialogue_lines = loaded_lines
	current_file_path = file_path
	selected_line_index = -1

	dialogue_name_input.text = file_path.get_file().get_basename()
	dialogue_name_input.editable = false
	current_file_label.text = file_path

	_refresh_lines_list()
	_clear_editor_form()
	_set_status("Dialogue chargé : %s" % file_path)


# ---------------------------------------------------------------------------
# Liste des lignes
# ---------------------------------------------------------------------------

func _refresh_lines_list() -> void:
	lines_list.clear()

	for line: Dictionary in dialogue_lines:
		var line_id: String = str(line.get("id", ""))
		var speaker_id: String = str(line.get("speaker", ""))
		var preview: String = str(line.get("text", ""))

		if preview.length() > 40:
			preview = preview.left(40) + "…"

		lines_list.add_item(
			"%s — %s — %s" % [
				line_id,
				speaker_id,
				preview
			]
		)


func _on_line_selected(index: int) -> void:
	if index < 0 or index >= dialogue_lines.size():
		return

	selected_line_index = index

	var line: Dictionary = dialogue_lines[index]

	dialogue_text_input.text = str(line.get("text", ""))
	_select_character(str(line.get("speaker", "")))
	_select_emotion(str(line.get("emotion", "neutral")))

	var choices: Array[Dictionary] = _extract_choices(line)

	has_choices_check_box.button_pressed = not choices.is_empty()
	_clear_choice_rows()

	for choice: Dictionary in choices:
		_add_choice_row(
			str(choice.get("text", "")),
			str(choice.get("next", ""))
		)

	_update_choices_visibility()
	add_line_button.text = "Modifier la ligne"


func _extract_choices(line: Dictionary) -> Array[Dictionary]:
	var choices: Array[Dictionary] = []

	if not line.has("choices"):
		return choices

	var raw_choices: Array = line.get("choices", [])

	for raw_choice: Variant in raw_choices:
		if raw_choice is Dictionary:
			choices.append(raw_choice as Dictionary)

	return choices


# ---------------------------------------------------------------------------
# Formulaire
# ---------------------------------------------------------------------------

func _on_has_choices_toggled(_enabled: bool) -> void:
	_update_choices_visibility()


func _update_choices_visibility() -> void:
	var has_choices: bool = has_choices_check_box.button_pressed

	choices_container.visible = has_choices
	add_choice_button.visible = has_choices


func _on_add_line_button_pressed() -> void:
	var dialogue_name: String = dialogue_name_input.text.strip_edges()
	var dialogue_text: String = dialogue_text_input.text.strip_edges()

	var dialogue_name_error: String = validator.validate_dialogue_name(
		dialogue_name
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

	var line_id: String = _resolve_current_line_id(dialogue_name)

	if line_id.is_empty():
		_set_status("Impossible de générer l'identifiant.")
		return

	var line: Dictionary = _build_line(
		line_id,
		speaker_id,
		emotion_id,
		dialogue_text
	)

	if line.is_empty():
		return

	var is_editing: bool = selected_line_index >= 0

	if is_editing:
		dialogue_lines[selected_line_index] = line
		_set_status("Ligne modifiée : " + line_id)
	else:
		dialogue_lines.append(line)
		dialogue_name_input.editable = false
		_set_status("Ligne ajoutée : " + line_id)

	selected_line_index = -1
	_refresh_lines_list()
	_clear_editor_form()


func _resolve_current_line_id(dialogue_name: String) -> String:
	if selected_line_index >= 0:
		return str(
			dialogue_lines[selected_line_index].get("id", "")
		)

	var line_number: int = dialogue_lines.size() + 1
	var generated_id: String = id_generator.generate_line_id(
		dialogue_name,
		line_number
	)

	while validator.line_id_exists(dialogue_lines, generated_id):
		line_number += 1
		generated_id = id_generator.generate_line_id(
			dialogue_name,
			line_number
		)

	return generated_id


func _build_line(
	line_id: String,
	speaker_id: String,
	emotion_id: String,
	dialogue_text: String
) -> Dictionary:
	if has_choices_check_box.button_pressed:
		var choices: Array[Dictionary] = _collect_choices()
		var choices_error: String = validator.validate_choices(choices)

		if not choices_error.is_empty():
			_set_status(choices_error)
			return {}

		return line_builder.build_choice_line(
			line_id,
			speaker_id,
			emotion_id,
			dialogue_text,
			choices
		)

	var next_id: String = _get_linear_next_id()

	return line_builder.build_linear_line(
		line_id,
		speaker_id,
		emotion_id,
		dialogue_text,
		next_id
	)


func _get_linear_next_id() -> String:
	if selected_line_index >= 0:
		var existing_line: Dictionary = dialogue_lines[selected_line_index]
		return str(existing_line.get("next", ""))

	var dialogue_name: String = dialogue_name_input.text.strip_edges()
	var line_number: int = dialogue_lines.size() + 2

	return id_generator.generate_line_id(
		dialogue_name,
		line_number
	)


func _clear_editor_form() -> void:
	dialogue_text_input.clear()
	has_choices_check_box.button_pressed = false
	selected_line_index = -1
	add_line_button.text = "Ajouter la ligne"

	_clear_choice_rows()
	_update_choices_visibility()


func _clear_choice_rows() -> void:
	for child: Node in choices_container.get_children():
		child.queue_free()


# ---------------------------------------------------------------------------
# Choix
# ---------------------------------------------------------------------------

func _on_add_choice_pressed() -> void:
	_add_choice_row()


func _add_choice_row(
	choice_text: String = "",
	target_line_id: String = ""
) -> void:
	var row: ChoiceRowScript = (
		CHOICE_ROW_SCENE.instantiate() as ChoiceRowScript
	)

	if row == null:
		_set_status("Impossible de créer le choix.")
		return

	row.remove_requested.connect(_on_choice_remove_requested)
	choices_container.add_child(row)
	
	row.create_target_requested.connect(_on_choice_create_target_requested)

	row.configure(
		_get_existing_line_ids(),
		choice_text,
		target_line_id
	)

func _on_choice_create_target_requested(
	row: ChoiceRowScript
) -> void:
	var dialogue_name: String = (
		dialogue_name_input.text.strip_edges()
	)

	if dialogue_name.is_empty():
		_set_status(
			"Donne d'abord un nom au dialogue."
		)
		return

	var new_line_id: String = _generate_new_line_id(
		dialogue_name
	)

	if new_line_id.is_empty():
		_set_status(
			"Impossible de générer la nouvelle ligne."
		)
		return

	var new_line: Dictionary = {
		"id": new_line_id,
		"speaker": "narrator",
		"text": ""
	}

	dialogue_lines.append(new_line)

	_refresh_lines_list()
	_refresh_all_choice_targets()

	row.select_target(new_line_id)

	var new_line_index: int = dialogue_lines.size() - 1
	lines_list.select(new_line_index)

	_on_line_selected(new_line_index)

	_set_status(
		"Nouvelle ligne créée : " + new_line_id
	)

func _generate_new_line_id(
	dialogue_name: String
) -> String:
	var line_number: int = dialogue_lines.size() + 1

	var generated_id: String = (
		id_generator.generate_line_id(
			dialogue_name,
			line_number
		)
	)

	while validator.line_id_exists(
		dialogue_lines,
		generated_id
	):
		line_number += 1

		generated_id = (
			id_generator.generate_line_id(
				dialogue_name,
				line_number
			)
		)

	return generated_id

func _refresh_all_choice_targets() -> void:
	var line_ids: Array[String] = (
		_get_existing_line_ids()
	)

	for child: Node in choices_container.get_children():
		if child is not ChoiceRowScript:
			continue

		var row: ChoiceRowScript = (
			child as ChoiceRowScript
		)

		var current_target: String = (
			row.get_target_line_id()
		)

		row.set_available_targets(
			line_ids,
			current_target
		)

func _on_choice_remove_requested(row: HBoxContainer) -> void:
	row.queue_free()


func _collect_choices() -> Array[Dictionary]:
	var choices: Array[Dictionary] = []

	for child: Node in choices_container.get_children():
		if child is not ChoiceRowScript:
			continue

		var row: ChoiceRowScript = child as ChoiceRowScript
		var choice_text: String = row.get_choice_text()
		var target_line_id: String = row.get_target_line_id()

		if choice_text.is_empty() or target_line_id.is_empty():
			continue

		choices.append({
			"text": choice_text,
			"next": target_line_id
		})

	return choices


func _get_existing_line_ids() -> Array[String]:
	var line_ids: Array[String] = []

	for line: Dictionary in dialogue_lines:
		var line_id: String = str(line.get("id", ""))

		if not line_id.is_empty():
			line_ids.append(line_id)

	return line_ids


# ---------------------------------------------------------------------------
# Sauvegarde
# ---------------------------------------------------------------------------

func _on_save_button_pressed() -> void:
	var dialogue_name: String = dialogue_name_input.text.strip_edges()

	var dialogue_name_error: String = validator.validate_dialogue_name(
		dialogue_name
	)

	if not dialogue_name_error.is_empty():
		_set_status(dialogue_name_error)
		return

	if dialogue_lines.is_empty():
		_set_status("Le dialogue ne contient aucune ligne.")
		return

	var save_error: String = file_writer.save(
		dialogue_name,
		dialogue_lines
	)

	if not save_error.is_empty():
		_set_status(save_error)
		push_error(save_error)
		return

	current_file_path = file_writer.get_file_path(dialogue_name)
	current_file_label.text = current_file_path
	dialogue_name_input.editable = false

	_set_status("Dialogue sauvegardé : " + current_file_path)


# ---------------------------------------------------------------------------
# Sélections
# ---------------------------------------------------------------------------

func _select_character(character_id: String) -> void:
	for index: int in range(character_select.item_count):
		if str(character_select.get_item_metadata(index)) == character_id:
			character_select.select(index)
			return


func _select_emotion(emotion_id: String) -> void:
	for index: int in range(emotion_select.item_count):
		if str(emotion_select.get_item_metadata(index)) == emotion_id:
			emotion_select.select(index)
			return


func _get_selected_character_id() -> String:
	return str(character_select.get_selected_metadata())


func _get_selected_emotion_id() -> String:
	return str(emotion_select.get_selected_metadata())


# ---------------------------------------------------------------------------
# Retour utilisateur
# ---------------------------------------------------------------------------

func _set_status(message: String) -> void:
	status_label.text = message
	print(message)
