extends Node

# Cap log history to prevent unbounded growth while preserving recent context.
const MAX_LOG_ENTRIES: int = 300

signal message_added

var messages: Array[String] = []
# Public API: add_entry(text) appends a message and emits message_added.
func add_entry(text: String) -> void:
	if _should_skip_entry(text):
		return
	messages.append(text)
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
