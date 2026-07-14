extends RefCounted


func slugify(value: String) -> String:
	var slug: String = value.strip_edges().to_lower()

	var replacements: Dictionary = {
		"à": "a",
		"â": "a",
		"ä": "a",
		"á": "a",
		"ç": "c",
		"é": "e",
		"è": "e",
		"ê": "e",
		"ë": "e",
		"î": "i",
		"ï": "i",
		"ô": "o",
		"ö": "o",
		"ù": "u",
		"û": "u",
		"ü": "u"
	}

	for source_character: String in replacements:
		var replacement: String = str(replacements[source_character])
		slug = slug.replace(source_character, replacement)

	var regex: RegEx = RegEx.new()
	var compile_error: Error = regex.compile("[^a-z0-9]+")

	if compile_error != OK:
		push_error("Impossible de compiler la regex des identifiants.")
		return ""

	slug = regex.sub(slug, "_", true)
	slug = slug.trim_prefix("_")
	slug = slug.trim_suffix("_")

	return slug


func generate_line_id(
	dialogue_name: String,
	line_number: int
) -> String:
	var dialogue_slug: String = slugify(dialogue_name)

	if dialogue_slug.is_empty():
		return ""

	return "%s_%02d" % [dialogue_slug, line_number]


func generate_choice_target_id(
	parent_line_id: String,
	choice_number: int
) -> String:
	return "%s.%d" % [parent_line_id, choice_number]