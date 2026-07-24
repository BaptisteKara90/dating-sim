class_name DialogueFileDelete
extends RefCounted


func delete(dialogue_file_path: String) -> bool:
	if dialogue_file_path.is_empty():
		push_error("Le chemin du dialogue est vide.")
		return false

	if not FileAccess.file_exists(dialogue_file_path):
		push_error(
			"Le fichier n'existe pas : "
			+ dialogue_file_path
		)
		return false

	var directory_path: String = (
		dialogue_file_path.get_base_dir()
	)
	var file_name: String = (
		dialogue_file_path.get_file()
	)

	var directory: DirAccess = DirAccess.open(
		directory_path
	)

	if directory == null:
		push_error(
			"Impossible d'ouvrir le dossier : "
			+ directory_path
		)
		return false

	var error: Error = directory.remove(file_name)

	if error != OK:
		push_error(
			"Impossible de supprimer le fichier : "
			+ error_string(error)
		)
		return false

	return true