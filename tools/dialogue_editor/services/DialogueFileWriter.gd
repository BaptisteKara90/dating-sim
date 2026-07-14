extends RefCounted

const DIALOGUE_DIRECTORY: String = "res://data/dialogues"


func save(
	dialogue_name: String,
	dialogue_lines: Array[Dictionary]
) -> String:
	var id_generator: RefCounted = preload(
		"res://tools/dialogue_editor/services/DialogueIdGenerator.gd"
	).new()

	var dialogue_slug: String = id_generator.slugify(dialogue_name)

	if dialogue_slug.is_empty():
		return "Impossible de générer le nom du fichier."

	if not DirAccess.dir_exists_absolute(DIALOGUE_DIRECTORY):
		var directory_error: Error = DirAccess.make_dir_recursive_absolute(
			DIALOGUE_DIRECTORY
		)

		if directory_error != OK:
			return "Impossible de créer le dossier des dialogues."

	var file_path: String = "%s/%s.json" % [
		DIALOGUE_DIRECTORY,
		dialogue_slug
	]

	var lines_to_save: Array[Dictionary] = _prepare_lines_for_save(
		dialogue_lines
	)

	var file: FileAccess = FileAccess.open(
		file_path,
		FileAccess.WRITE
	)

	if file == null:
		return "Impossible de créer le fichier : " + file_path

	var json_content: String = JSON.stringify(
		lines_to_save,
		"\t",
		false
	)

	file.store_string(json_content)
	file.close()

	return ""


func get_file_path(dialogue_name: String) -> String:
	var id_generator: RefCounted = preload(
		"res://tools/dialogue_editor/services/DialogueIdGenerator.gd"
	).new()

	var dialogue_slug: String = id_generator.slugify(dialogue_name)

	return "%s/%s.json" % [
		DIALOGUE_DIRECTORY,
		dialogue_slug
	]


func _prepare_lines_for_save(
	dialogue_lines: Array[Dictionary]
) -> Array[Dictionary]:
	var copied_lines: Array[Dictionary] = []

	for line: Dictionary in dialogue_lines:
		copied_lines.append(line.duplicate(true))

	if copied_lines.is_empty():
		return copied_lines

	var existing_ids: Dictionary = {}

	for line: Dictionary in copied_lines:
		var line_id: String = str(line.get("id", ""))
		existing_ids[line_id] = true

	# La dernière ligne linéaire est considérée comme terminale
	# si son ID suivant n'existe pas encore.
	var last_line: Dictionary = copied_lines[copied_lines.size() - 1]

	if last_line.has("next"):
		var next_id: String = str(last_line.get("next", ""))

		if not existing_ids.has(next_id):
			last_line.erase("next")

	return copied_lines