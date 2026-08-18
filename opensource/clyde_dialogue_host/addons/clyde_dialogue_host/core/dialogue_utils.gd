class_name DialogueUtils
extends RefCounted

## Shared helpers for dialogue runtime.


static func is_nullish(value: String) -> bool:
	return value in DialogueConstants.NULLISH_STRINGS


static func normalize_speaker(speaker: String) -> String:
	return "" if is_nullish(speaker) else speaker


static func parse_roll_dice_args(args: Array) -> Dictionary:
	var stat_type := str(args[0]) if args.size() > 0 else ""
	var roll_id := str(args[1]) if args.size() > 1 else ""
	var tags: Array = []

	if args.size() > 2:
		if args[2] is Array:
			tags = args[2]
		else:
			tags = [str(args[2])]

	return {"stat_type": stat_type, "roll_id": roll_id, "tags": tags}


static func read_json_file(path: String) -> Variant:
	if path.is_empty() or not FileAccess.file_exists(path):
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_warning("DialogueUtils: cannot read %s" % path)
		return null

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed


static func write_json_file(path: String, data: Variant, indent: String = "\t") -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("DialogueUtils: cannot write %s" % path)
		return false
	file.store_string(JSON.stringify(data, indent))
	file.close()
	return true
