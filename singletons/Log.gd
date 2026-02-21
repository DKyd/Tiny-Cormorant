extends Node

# Cap log history to prevent unbounded growth while preserving recent context.
const MAX_LOG_ENTRIES: int = 300

signal message_added

# entries is the canonical log store; messages exists for legacy UI compatibility
var entries: Array[Dictionary] = []
var messages: Array[String] = []
# Public API: add_entry(text) appends a message and emits message_added.
func add_entry(text: String, category: String = "", is_dev: bool = false) -> void:
	if _should_skip_entry(text, is_dev):
		return
	var normalized_category: String = _normalize_category(category, text)
	var context: Dictionary = _capture_context()
	var entry := {
		"text": text,
		"category": normalized_category,
		"is_dev": is_dev,
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

func _should_skip_entry(text: String, is_dev: bool) -> bool:
	if is_dev:
		return false
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

func get_tail(max_entries: int, include_dev: bool) -> Array[Dictionary]:
	if max_entries <= 0:
		return []
	var tail: Array[Dictionary] = []
	for i in range(entries.size() - 1, -1, -1):
		var entry: Dictionary = entries[i]
		if entry.is_empty():
			continue
		var is_dev: bool = bool(entry.get("is_dev", false))
		if is_dev and not include_dev:
			continue
		tail.append(entry.duplicate())
		if tail.size() >= max_entries:
			break
	tail.reverse()
	return tail

func format_tail_text(max_entries: int, include_dev: bool, include_prefix: bool) -> String:
	var tail: Array[Dictionary] = get_tail(max_entries, include_dev)
	if tail.is_empty():
		return ""
	var lines: PackedStringArray = []
	for entry in tail:
		var text: String = String(entry.get("text", ""))
		if text == "":
			continue
		var line: String = text
		if include_prefix:
			line = "%s%s" % [_format_entry_prefix(entry), text]
		lines.append(line)
	if lines.is_empty():
		return ""
	return "\n".join(lines) + "\n"

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

func _format_entry_prefix(entry: Dictionary) -> String:
	var tick: int = int(entry.get("tick", -1))
	var system_id: String = String(entry.get("system_id", ""))
	var location_id: String = String(entry.get("location_id", ""))
	return "[t=%d sys=%s loc=%s] " % [tick, system_id, location_id]