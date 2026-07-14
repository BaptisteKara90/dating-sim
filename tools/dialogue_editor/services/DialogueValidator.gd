extends RefCounted


func validate_dialogue_name(dialogue_name: String) -> String:
	if dialogue_name.strip_edges().is_empty():
		return "Le nom du dialogue est obligatoire."

	return ""


func validate_line(
	dialogue_text: String,
	speaker_id: String
) -> String:
	if dialogue_text.strip_edges().is_empty():
		return "Le texte du dialogue est obligatoire."

	if speaker_id.is_empty():
		return "Un personnage doit être sélectionné."

	return ""


func validate_choices(choices: Array[Dictionary]) -> String:
	if choices.is_empty():
		return "Ajoute au moins un choix valide."

	for choice: Dictionary in choices:
		var choice_text: String = str(choice.get("text", ""))
		var next_id: String = str(choice.get("next", ""))

		if choice_text.is_empty():
			return "Le texte d'un choix ne peut pas être vide."

		if next_id.is_empty():
			return "Un choix doit posséder une destination."

	return ""


func line_id_exists(
	dialogue_lines: Array[Dictionary],
	line_id: String
) -> bool:
	for line: Dictionary in dialogue_lines:
		if str(line.get("id", "")) == line_id:
			return true

	return false