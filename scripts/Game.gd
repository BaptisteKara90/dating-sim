extends Control

@onready var speaker_label: Label = $UI/DialogueBox/MarginContainer/VBoxContainer/SpeakerLabel
@onready var text_label: Label = $UI/DialogueBox/MarginContainer/VBoxContainer/TextLabel
@onready var continue_button: Button = $UI/DialogueBox/MarginContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	DialogueManager.line_changed.connect(_on_dialogue_line_changed)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)

	DialogueManager.start("intro")

func _on_dialogue_line_changed(line: Dictionary) -> void:
	speaker_label.text = line.get("speaker", "")
	text_label.text = line.get("text", "")
	continue_button.disabled = false

func _on_dialogue_finished() -> void:
	speaker_label.text = ""
	text_label.text = "Fin de la scène."
	continue_button.disabled = true

func _on_continue_button_pressed() -> void:
	DialogueManager.next()