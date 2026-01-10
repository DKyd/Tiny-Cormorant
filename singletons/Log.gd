extends Node

# TODO(issue-XXXX): Cap message history (e.g., keep last 500) to prevent unbounded growth in long sessions.

signal message_added

var messages: Array[String] = []
var max_messages: int = 30

# Public API: add_entry(text) appends a message and emits message_added.
func add_entry(text: String) -> void:
    messages.append(text)
    if messages.size() > max_messages:
        messages.pop_front()

    emit_signal("message_added")
