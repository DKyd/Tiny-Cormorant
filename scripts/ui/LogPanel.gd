extends PanelContainer

@onready var log_list: ItemList = $MarginContainer/VBoxContainer/LogList


func _ready() -> void:
	Log.message_added.connect(_on_log_message_added)
	_refresh_log()


func _refresh_log() -> void:
	log_list.clear()
	for msg in Log.messages:
		log_list.add_item(msg)

	var count: int = log_list.get_item_count()
	if count > 0:
		log_list.select(count - 1)
		log_list.ensure_current_is_visible()


func _on_log_message_added() -> void:
	_refresh_log()