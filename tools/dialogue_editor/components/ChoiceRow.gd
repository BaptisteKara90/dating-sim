extends HBoxContainer

signal remove_requested(row: HBoxContainer)

@onready var choice_text_input: LineEdit = %ChoiceTextInput
@onready var remove_button: Button = %RemoveButton


func _ready() -> void:
	remove_button.pressed.connect(_on_remove_button_pressed)


func get_choice_text() -> String:
	return choice_text_input.text.strip_edges()


func _on_remove_button_pressed() -> void:
	remove_requested.emit(self)