extends Control

@onready var dialogue_name_input: LineEdit = %DialogueNameInput
@onready var line_id_input: LineEdit = %LineIdInput
@onready var character_select: OptionButton = %CharacterSelect
@onready var emotion_select: OptionButton = %EmotionSelect
@onready var dialogue_text_input: TextEdit = %DialogueTextInput
@onready var next_id_input: LineEdit = %NextIdInput
@onready var has_choices_check_box: CheckBox = %HasChoicesCheckBox
@onready var choices_container: VBoxContainer = %ChoicesContainer
@onready var add_choice_button: Button = %AddChoiceButton
@onready var add_line_button: Button = %AddLineButton
@onready var status_label: Label = %StatusLabel
@onready var save_button: Button = %SaveButton

var dialogue_lines: Array[Dictionary] = []

func _ready() -> void:
	_initialize_characters()
	_initialize_emotions()

	has_choices_check_box.toggled.connect(_on_has_choices_toggled)
	add_choice_button.pressed.connect(_on_add_choice_pressed)
	add_line_button.pressed.connect(_on_add_line_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)

	_update_choices_visibility()


func _initialize_characters() -> void:
	character_select.clear()
	character_select.add_item("Narrateur", 0)
	character_select.add_item("Lady Eleanor", 1)
	character_select.add_item("Lord Ashford", 2)


func _initialize_emotions() -> void:
	emotion_select.clear()
	emotion_select.add_item("Neutre", 0)
	emotion_select.add_item("Heureux", 1)
	emotion_select.add_item("Triste", 2)
	emotion_select.add_item("En colère", 3)
	emotion_select.add_item("Surpris", 4)


func _on_has_choices_toggled(_enabled: bool) -> void:
	_update_choices_visibility()


func _update_choices_visibility() -> void:
	var has_choices: bool = has_choices_check_box.button_pressed

	choices_container.visible = has_choices
	add_choice_button.visible = has_choices
	next_id_input.editable = not has_choices


func _on_add_choice_pressed() -> void:
	var row: HBoxContainer = HBoxContainer.new()

	var choice_text_input: LineEdit = LineEdit.new()
	choice_text_input.placeholder_text = "Texte du choix"
	choice_text_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var choice_next_input: LineEdit = LineEdit.new()
	choice_next_input.placeholder_text = "ID suivant"
	choice_next_input.custom_minimum_size.x = 160.0

	var remove_button: Button = Button.new()
	remove_button.text = "Supprimer"
	remove_button.pressed.connect(
		func() -> void:
			row.queue_free()
	)

	row.add_child(choice_text_input)
	row.add_child(choice_next_input)
	row.add_child(remove_button)

	choices_container.add_child(row)

func _on_add_line_button_pressed() -> void:
	var line_id: String = line_id_input.text.strip_edges()
	var dialogue_text: String = dialogue_text_input.text.strip_edges()

	if line_id.is_empty():
		_set_status("L'identifiant de la ligne est obligatoire.")
		return

	if dialogue_text.is_empty():
		_set_status("Le texte du dialogue est obligatoire.")
		return

	if _line_id_exists(line_id):
		_set_status("Une ligne possède déjà l'identifiant : " + line_id)
		return

	var line: Dictionary = {
		"id": line_id,
		"speaker": _get_selected_character_id(),
		"emotion": _get_selected_emotion_id(),
		"text": dialogue_text
	}

	if has_choices_check_box.button_pressed:
		var choices: Array[Dictionary] = _collect_choices()

		if choices.is_empty():
			_set_status("Ajoute au moins un choix valide.")
			return

		line["choices"] = choices
	else:
		var next_id: String = next_id_input.text.strip_edges()

		if not next_id.is_empty():
			line["next"] = next_id

	dialogue_lines.append(line)

	_set_status("Ligne ajoutée : " + line_id)
	_reset_line_form()

func _line_id_exists(line_id: String) -> bool:
	for line: Dictionary in dialogue_lines:
		if str(line.get("id", "")) == line_id:
			return true

	return false


func _collect_choices() -> Array[Dictionary]:
	var choices: Array[Dictionary] = []

	for child: Node in choices_container.get_children():
		if child is not HBoxContainer:
			continue

		var row: HBoxContainer = child as HBoxContainer

		if row.get_child_count() < 2:
			continue

		var text_input: LineEdit = row.get_child(0) as LineEdit
		var next_input: LineEdit = row.get_child(1) as LineEdit

		var choice_text: String = text_input.text.strip_edges()
		var next_id: String = next_input.text.strip_edges()

		if choice_text.is_empty() or next_id.is_empty():
			continue

		choices.append({
			"text": choice_text,
			"next": next_id
		})

	return choices


func _on_save_button_pressed() -> void:
	var dialogue_name: String = dialogue_name_input.text.strip_edges()

	if dialogue_name.is_empty():
		_set_status("Le nom du dialogue est obligatoire.")
		return

	if dialogue_lines.is_empty():
		_set_status("Le dialogue ne contient aucune ligne.")
		return

	var directory_path: String = "res://data/dialogues"
	var file_path: String = "%s/%s.json" % [directory_path, dialogue_name]

	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)

	if file == null:
		_set_status("Impossible de créer le fichier : " + file_path)
		push_error("Unable to create dialogue file: " + file_path)
		return

	var json_content: String = JSON.stringify(dialogue_lines, "\t")
	file.store_string(json_content)

	_set_status("Dialogue sauvegardé : " + file_path)


func _reset_line_form() -> void:
	line_id_input.clear()
	dialogue_text_input.clear()
	next_id_input.clear()
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
