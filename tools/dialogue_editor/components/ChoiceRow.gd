extends HBoxContainer

signal remove_requested(row: HBoxContainer)

@onready var choice_text_input: LineEdit = %ChoiceTextInput
@onready var target_line_select: OptionButton = %TargetLineSelect
@onready var remove_button: Button = %RemoveButton


func _ready() -> void:
	remove_button.pressed.connect(
		_on_remove_button_pressed
	)


func configure(
	line_ids: Array[String],
	choice_text: String = "",
	target_line_id: String = ""
) -> void:
	choice_text_input.text = choice_text
	target_line_select.clear()

	target_line_select.add_item(
		"— Sélectionner une destination —"
	)
	target_line_select.set_item_metadata(0, "")

	for line_id: String in line_ids:
		target_line_select.add_item(line_id)

		var item_index: int = (
			target_line_select.item_count - 1
		)

		target_line_select.set_item_metadata(
			item_index,
			line_id
		)

		if line_id == target_line_id:
			target_line_select.select(item_index)


func get_choice_text() -> String:
	return choice_text_input.text.strip_edges()


func get_target_line_id() -> String:
	return str(
		target_line_select.get_selected_metadata()
	)


func _on_remove_button_pressed() -> void:
	remove_requested.emit(self)