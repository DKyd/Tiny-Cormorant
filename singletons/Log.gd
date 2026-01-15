extends Node

# Cap log history to prevent unbounded growth while preserving recent context.
const MAX_LOG_ENTRIES: int = 300

signal message_added

var messages: Array[String] = []
# Public API: add_entry(text) appends a message and emits message_added.
func add_entry(text: String) -> void:
	messages.append(text)
	while messages.size() > MAX_LOG_ENTRIES:
		messages.pop_front()

	emit_signal("message_added")
