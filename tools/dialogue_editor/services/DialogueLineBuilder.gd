extends RefCounted


func build_linear_line(
	line_id: String,
	speaker_id: String,
	emotion_id: String,
	dialogue_text: String,
	next_id: String
) -> Dictionary:
	var line: Dictionary = {
		"id": line_id,
		"speaker": speaker_id,
		"text": dialogue_text
	}

	if not emotion_id.is_empty():
		line["emotion"] = emotion_id

	if not next_id.is_empty():
		line["next"] = next_id

	return line


func build_choice_line(
	line_id: String,
	speaker_id: String,
	emotion_id: String,
	dialogue_text: String,
	choices: Array[Dictionary]
) -> Dictionary:
	var line: Dictionary = {
		"id": line_id,
		"speaker": speaker_id,
		"text": dialogue_text
	}

	if not emotion_id.is_empty():
		line["emotion"] = emotion_id

	line["choices"] = choices

	return line