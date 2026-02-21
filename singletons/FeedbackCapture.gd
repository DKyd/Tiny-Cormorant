extends Node

const SCHEMA_VERSION: int = 1
const LOG_TAIL_MAX_ENTRIES: int = 120


func capture(note: String = "", tags: Array[String] = []) -> String:
	var feedback_root: String = "user://feedback"
	var feedback_root_abs: String = ProjectSettings.globalize_path(feedback_root)
	if DirAccess.make_dir_recursive_absolute(feedback_root_abs) != OK:
		_log_dev("Feedback capture failed: unable to create feedback root at %s" % feedback_root)
		return ""

	var folder_name: String = _build_timestamp_folder_name()
	var folder_path: String = "%s/%s" % [feedback_root, folder_name]
	var folder_path_abs: String = ProjectSettings.globalize_path(folder_path)
	if DirAccess.make_dir_recursive_absolute(folder_path_abs) != OK:
		_log_dev("Feedback capture failed: unable to create capture folder at %s" % folder_path)
		return ""

	var failures: PackedStringArray = []
	var snapshot: Dictionary = _build_snapshot(note, tags)
	if not _write_json("%s/snapshot.json" % folder_path, snapshot):
		failures.append("snapshot.json")

	var player_tail: String = Log.format_tail_text(LOG_TAIL_MAX_ENTRIES, false, false)
	if not _write_text("%s/player_log_tail.txt" % folder_path, player_tail):
		failures.append("player_log_tail.txt")

	var dev_tail: String = Log.format_tail_text(LOG_TAIL_MAX_ENTRIES, true, true)
	if not _write_text("%s/dev_log_tail.txt" % folder_path, dev_tail):
		failures.append("dev_log_tail.txt")

	var report: String = _build_report(folder_name, note, tags, failures)
	if not _write_text("%s/report.md" % folder_path, report):
		failures.append("report.md")

	if not failures.is_empty():
		_log_dev("Feedback capture completed with write failures in %s: %s" % [folder_path, ", ".join(failures)])

	return folder_path


func _build_timestamp_folder_name() -> String:
	var now: Dictionary = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d_%02d-%02d-%02d" % [
		int(now.get("year", 1970)),
		int(now.get("month", 1)),
		int(now.get("day", 1)),
		int(now.get("hour", 0)),
		int(now.get("minute", 0)),
		int(now.get("second", 0)),
	]


func _build_snapshot(note: String, tags: Array[String]) -> Dictionary:
	var tick: int = -1
	var system_id: String = ""
	var location_id: String = ""
	var gs: Node = get_node_or_null("/root/GameState")
	if gs != null:
		var raw_tick = gs.get("time_tick")
		if raw_tick != null:
			tick = int(raw_tick)
		var raw_system = gs.get("current_system_id")
		if raw_system != null:
			system_id = String(raw_system)
		var raw_location = gs.get("current_location_id")
		if raw_location != null:
			location_id = String(raw_location)

	return {
		"schema_version": SCHEMA_VERSION,
		"captured_at_ms": int(Time.get_unix_time_from_system() * 1000.0),
		"note": note,
		"tags": tags.duplicate(),
		"world": {
			"tick": tick,
			"system_id": system_id,
			"location_id": location_id,
		},
		"build": {
			"godot_version": Engine.get_version_info().get("string", ""),
			"platform": OS.get_name(),
		},
	}


func _build_report(folder_name: String, note: String, tags: Array[String], failures: PackedStringArray) -> String:
	var lines: PackedStringArray = [
		"# Feedback Capture Report",
		"",
		"- Capture folder: `user://feedback/%s`" % folder_name,
		"- Schema version: %d" % SCHEMA_VERSION,
	]
	if note != "":
		lines.append("- Note: %s" % note)
	if not tags.is_empty():
		lines.append("- Tags: %s" % ", ".join(PackedStringArray(tags)))
	if not failures.is_empty():
		lines.append("- Write failures: %s" % ", ".join(failures))
	else:
		lines.append("- Write failures: none")
	lines.append("")
	lines.append("## Files")
	lines.append("- snapshot.json")
	lines.append("- player_log_tail.txt")
	lines.append("- dev_log_tail.txt")
	lines.append("- report.md")
	return "\n".join(lines) + "\n"


func _write_json(path: String, payload: Dictionary) -> bool:
	return _write_text(path, JSON.stringify(payload, "\t", false))


func _write_text(path: String, contents: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(contents)
	return true


func _log_dev(message: String) -> void:
	var log_node: Node = get_node_or_null("/root/Log")
	if log_node != null:
		log_node.call("add_entry", message, "OTHER", true)