class_name DialogueFormService
extends RefCounted


var dialogue_name_input: LineEdit
var line_id_input: LineEdit
var character_select: OptionButton
var emotion_select: OptionButton
var dialogue_text_input: TextEdit
var next_id_input: LineEdit
var has_choices_check_box: CheckBox


func _init(
	new_dialogue_name_input: LineEdit,
	new_character_select: OptionButton,
	new_emotion_select: OptionButton,
	new_dialogue_text_input: TextEdit,
	new_has_choices_check_box: CheckBox
) -> void:
	dialogue_name_input = new_dialogue_name_input
	character_select = new_character_select
	emotion_select = new_emotion_select
	dialogue_text_input = new_dialogue_text_input
	has_choices_check_box = new_has_choices_check_box


func get_dialogue_name() -> String:
	return dialogue_name_input.text.strip_edges()


func get_dialogue_text() -> String:
	return dialogue_text_input.text.strip_edges()



func has_choices() -> bool:
	return has_choices_check_box.button_pressed


func get_selected_character_id() -> String:
	return _get_selected_metadata(character_select)


func get_selected_emotion_id() -> String:
	return _get_selected_metadata(emotion_select)


func get_form_data() -> Dictionary:
	return {
		"dialogue_name": get_dialogue_name(),
		"speaker": get_selected_character_id(),
		"emotion": get_selected_emotion_id(),
		"text": get_dialogue_text(),
		"has_choices": has_choices()
	}


func populate_from_line(line: Dictionary) -> void:
	dialogue_text_input.text = str(line.get("text", ""))

	select_character(str(line.get("speaker", "")))
	select_emotion(str(line.get("emotion", "")))



func clear_line_form() -> void:
	dialogue_text_input.clear()
	has_choices_check_box.button_pressed = false

	_select_first_item(character_select)
	_select_first_item(emotion_select)


func clear_all() -> void:
	dialogue_name_input.clear()
	clear_line_form()


func select_character(character_id: String) -> void:
	_select_option_by_metadata(
		character_select,
		character_id
	)


func select_emotion(emotion_id: String) -> void:
	_select_option_by_metadata(
		emotion_select,
		emotion_id
	)


func _get_selected_metadata(
	option_button: OptionButton
) -> String:
	var selected_index: int = option_button.selected

	if selected_index < 0:
		return ""

	var metadata: Variant = option_button.get_item_metadata(
		selected_index
	)

	return str(metadata)


func _select_option_by_metadata(
	option_button: OptionButton,
	expected_value: String
) -> void:
	for index: int in range(option_button.item_count):
		var metadata: Variant = option_button.get_item_metadata(
			index
		)

		if str(metadata) == expected_value:
			option_button.select(index)
			return

	_select_first_item(option_button)


func _select_first_item(option_button: OptionButton) -> void:
	if option_button.item_count > 0:
		option_button.select(0)
