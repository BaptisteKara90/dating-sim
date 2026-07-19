extends HBoxContainer

signal remove_requested(row: HBoxContainer)
signal create_target_requested(row: HBoxContainer)

@onready var choice_text_input: LineEdit = %ChoiceTextInput
@onready var target_line_select: OptionButton = %TargetLineSelect
@onready var create_target_button: Button = %CreateTargetButton
@onready var remove_button: Button = %RemoveButton


func _ready() -> void:
	remove_button.pressed.connect(_on_remove_button_pressed)
	create_target_button.pressed.connect(
		_on_create_target_button_pressed
	)


func configure(
	line_ids: Array[String],
	choice_text: String = "",
	target_line_id: String = ""
) -> void:
	choice_text_input.text = choice_text

	set_available_targets(
		line_ids,
		target_line_id
	)


func set_available_targets(
	line_ids: Array[String],
	selected_target_id: String = ""
) -> void:
	target_line_select.clear()

	for line_id: String in line_ids:
		target_line_select.add_item(line_id)

		var index: int = target_line_select.item_count - 1
		target_line_select.set_item_metadata(
			index,
			line_id
		)

		if line_id == selected_target_id:
			target_line_select.select(index)


func select_target(target_line_id: String) -> void:
	for index: int in range(target_line_select.item_count):
		var item_id: String = str(
			target_line_select.get_item_metadata(index)
		)

		if item_id == target_line_id:
			target_line_select.select(index)
			return


func get_choice_text() -> String:
	return choice_text_input.text.strip_edges()


func get_target_line_id() -> String:
	if target_line_select.selected < 0:
		return ""

	return str(
		target_line_select.get_selected_metadata()
	)


func _on_create_target_button_pressed() -> void:
	create_target_requested.emit(self)


func _on_remove_button_pressed() -> void:
	remove_requested.emit(self)