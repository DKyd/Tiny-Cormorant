extends Node

signal message_added

var messages: Array[String] = []
var max_messages: int = 30

func add(text: String) -> void:
    messages.append(text)
    if messages.size() > max_messages:
        messages.pop_front()

    emit_signal("message_added")
