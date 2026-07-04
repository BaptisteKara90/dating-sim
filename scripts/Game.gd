extends Control

@onready var speaker_label: Label = $UI/DialogueBox/MarginContainer/VBoxContainer/SpeakerLabel
@onready var text_label: Label = $UI/DialogueBox/MarginContainer/VBoxContainer/TextLabel
@onready var continue_button: Button = $UI/DialogueBox/MarginContainer/VBoxContainer/ContinueButton

var dialogues: Array = []
var current_index: int = 0

func _ready():
	load_dialogues("res://data/dialogues/intro.json")
	show_dialogue()

func load_dialogues(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	dialogues = JSON.parse_string(content)

func show_dialogue():
	if current_index >= dialogues.size():
		text_label.text = "Fin de la scène."
		continue_button.disabled = true
		return

	var line = dialogues[current_index]
	speaker_label.text = line["speaker"]
	text_label.text = line["text"]

func _on_continue_button_pressed():
	current_index += 1
	show_dialogue()
