class_name DialogueChoiceService
extends RefCounted


func create_choice(
	choice_text: String,
	target_line_id: String
) -> Dictionary:
	return {
		"text": choice_text,
		"next": target_line_id
	}


func create_target_line(
	line_id: String
) -> Dictionary:
	return {
		"id": line_id,
		"speaker": "narrator",
		"text": ""
	}