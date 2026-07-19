extends RefCounted


func load(file_path: String) -> Array[Dictionary]:
	if not FileAccess.file_exists(file_path):
		push_error("Dialogue file not found: " + file_path)
		return []

	var file: FileAccess = FileAccess.open(
		file_path,
		FileAccess.READ
	)

	if file == null:
		push_error("Unable to open dialogue file: " + file_path)
		return []

	var json_content: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(json_content)

	if parsed == null:
		push_error("Invalid dialogue JSON: " + file_path)
		return []

	if typeof(parsed) != TYPE_ARRAY:
		push_error("Dialogue JSON must contain an array.")
		return []

	var loaded_lines: Array[Dictionary] = []

	for entry: Variant in parsed:
		if entry is Dictionary:
			loaded_lines.append(entry as Dictionary)

	return loaded_lines