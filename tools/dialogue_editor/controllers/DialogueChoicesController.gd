class_name DialogueChoicesController
extends RefCounted


signal create_target_requested(row: HBoxContainer)
signal error_occurred(message: String)


const ChoiceRowScript = preload(
	"res://tools/dialogue_editor/components/ChoiceRow.gd"
)

const CHOICE_ROW_SCENE: PackedScene = preload(
	"res://tools/dialogue_editor/components/ChoiceRow.tscn"
)


var choices_container: VBoxContainer
var line_service
var choice_service


func _init(
	new_choices_container: VBoxContainer,
	new_line_service,
	new_choice_service
) -> void:
	choices_container = new_choices_container
	line_service = new_line_service
	choice_service = new_choice_service


func add_row(
	dialogue_lines: Array[Dictionary],
	choice_text: String = "",
	target_line_id: String = ""
) -> void:
	var row: ChoiceRowScript = (
		CHOICE_ROW_SCENE.instantiate() as ChoiceRowScript
	)

	if row == null:
		error_occurred.emit(
			"Impossible de créer le choix."
		)
		return

	row.remove_requested.connect(
		_on_remove_requested
	)
	row.create_target_requested.connect(
		_on_create_target_requested
	)

	choices_container.add_child(row)

	row.configure(
		line_service.get_existing_line_ids(
			dialogue_lines
		),
		choice_text,
		target_line_id
	)


func populate(
	choices: Array[Dictionary],
	dialogue_lines: Array[Dictionary]
) -> void:
	clear()

	for choice: Dictionary in choices:
		add_row(
			dialogue_lines,
			str(choice.get("text", "")),
			str(choice.get("next", ""))
		)


func clear() -> void:
	for child: Node in choices_container.get_children():
		child.queue_free()


func collect() -> Array[Dictionary]:
	var choices: Array[Dictionary] = []

	for child: Node in choices_container.get_children():
		if child is not ChoiceRowScript:
			continue

		var row: ChoiceRowScript = (
			child as ChoiceRowScript
		)

		var choice_text: String = (
			row.get_choice_text()
		)
		var target_line_id: String = (
			row.get_target_line_id()
		)

		if (
			choice_text.is_empty()
			or target_line_id.is_empty()
		):
			continue

		choices.append(
			choice_service.create_choice(
				choice_text,
				target_line_id
			)
		)

	return choices


func refresh_targets(
	dialogue_lines: Array[Dictionary]
) -> void:
	var line_ids: Array[String] = (
		line_service.get_existing_line_ids(
			dialogue_lines
		)
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


func select_target(
	row: ChoiceRowScript,
	line_id: String
) -> void:
	row.select_target(line_id)


func _on_remove_requested(
	row: HBoxContainer
) -> void:
	row.queue_free()


func _on_create_target_requested(
	row: HBoxContainer
) -> void:
	create_target_requested.emit(row)