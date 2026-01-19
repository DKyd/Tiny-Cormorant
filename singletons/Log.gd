extends Node

# Cap log history to prevent unbounded growth while preserving recent context.
const MAX_LOG_ENTRIES: int = 300

signal message_added

# entries is the canonical log store; messages exists for legacy UI compatibility
var entries: Array[Dictionary] = []
var messages: Array[String] = []
# Public API: add_entry(text) appends a message and emits message_added.
func add_entry(text: String, category: String = "") -> void:
	if _should_skip_entry(text):
		return
	var normalized_category: String = _normalize_category(category, text)
	var context: Dictionary = _capture_context()
	var entry := {
		"text": text,
		"category": normalized_category,
		"tick": int(context.get("tick", -1)),
		"system_id": String(context.get("system_id", "")),
		"location_id": String(context.get("location_id", "")),
	}

	entries.append(entry)
	messages.append(text)
	while entries.size() > MAX_LOG_ENTRIES:
		entries.pop_front()
		if messages.size() > 0:
			messages.pop_front()
	while messages.size() > MAX_LOG_ENTRIES:
		messages.pop_front()

	emit_signal("message_added")

func _should_skip_entry(text: String) -> bool:
	var trimmed: String = text.strip_edges()
	if trimmed.begins_with("Customs inspection requested:"):
		return true
	if trimmed.begins_with("Customs at "):
		return true
	return false

func get_entry_count() -> int:
	return entries.size()

func get_entry(index: int) -> Dictionary:
	if index < 0 or index >= entries.size():
		return {}
	return entries[index].duplicate()

func get_entry_text(index: int) -> String:
	var entry: Dictionary = get_entry(index)
	if entry.is_empty():
		return ""
	return String(entry.get("text", ""))

func get_entry_category(index: int) -> String:
	var entry: Dictionary = get_entry(index)
	if entry.is_empty():
		return "OTHER"
	return String(entry.get("category", "OTHER"))

func get_entry_context(index: int) -> Dictionary:
	var entry: Dictionary = get_entry(index)
	if entry.is_empty():
		return {}
	return {
		"tick": int(entry.get("tick", -1)),
		"system_id": String(entry.get("system_id", "")),
		"location_id": String(entry.get("location_id", "")),
	}

func _capture_context() -> Dictionary:
	var tick: int = -1
	var system_id: String = ""
	var location_id: String = ""
	var gs := get_node_or_null("/root/GameState")
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
		"tick": tick,
		"system_id": system_id,
		"location_id": location_id,
	}

func _normalize_category(category: String, text: String) -> String:
	var normalized: String = category.strip_edges().to_upper()
	if normalized != "":
		return normalized
	return _infer_category(text)

func _infer_category(text: String) -> String:
	var trimmed: String = text.strip_edges()
	var upper: String = trimmed.to_upper()
	if upper.begins_with("CUSTOMS:") or upper.begins_with("CUSTOMS "):
		return "CUSTOMS"
	if upper.begins_with("TRAVEL:") or upper.begins_with("SHIP:") or upper.begins_with("WAIT:"):
		return "SHIP"
	return "OTHER"
