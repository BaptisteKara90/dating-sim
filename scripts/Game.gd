extends Control

@onready var speaker_label: Label = $UI/DialogueBox/MarginContainer/VBoxContainer/SpeakerLabel
@onready var text_label: Label = $UI/DialogueBox/MarginContainer/VBoxContainer/TextLabel
@onready var continue_button: Button = $UI/DialogueBox/MarginContainer/VBoxContainer/ContinueButton
@onready var choices_container: VBoxContainer = $UI/DialogueBox/MarginContainer/VBoxContainer/ChoicesContainer

func _ready() -> void:
	DialogueManager.line_changed.connect(_on_dialogue_line_changed)
	DialogueManager.choices_changed.connect(_on_choices_changed)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)

	DialogueManager.start("intro")

func _on_dialogue_line_changed(line) -> void:
	speaker_label.text = line.speaker
	text_label.text = line.text
	continue_button.disabled = false

func _on_choices_changed(choices: Array) -> void:
	for child in choices_container.get_children():
		child.queue_free()

	continue_button.visible = choices.is_empty()

	for i in range(choices.size()):
		var button := Button.new()
		button.text = choices[i].text
		button.pressed.connect(func(): DialogueManager.choose(i))
		choices_container.add_child(button)

func _on_dialogue_finished() -> void:
	speaker_label.text = ""
	text_label.text = "Fin de la scène."
	continue_button.disabled = true

func _on_continue_button_pressed() -> void:
	DialogueManager.next()
