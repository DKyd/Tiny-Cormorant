# res://scenes/FreightDocsPanel.gd
extends Control

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var info_label: Label = $PanelContainer/MarginContainer/VBoxContainer/InfoLabel
@onready var docs_list: ItemList = $PanelContainer/MarginContainer/VBoxContainer/DocsList
@onready var hint_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HintLabel
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/CloseButton


func _ready() -> void:
	title_label.text = "Freight Documents"

	docs_list.select_mode = ItemList.SELECT_SINGLE #forces list to be selectable
	docs_list.focus_mode = Control.FOCUS_ALL #forces keyboard focus
	docs_list.mouse_filter = Control.MOUSE_FILTER_STOP #ensures that mouse filter responds to click

	_refresh_list()
	_update_hint()

	close_button.pressed.connect(_on_CloseButton_pressed)
	docs_list.item_selected.connect(_on_DocsList_item_selected)


func _refresh_list() -> void:
	docs_list.clear()

	print("FreightDocsPanel: refreshing list. Docs in GameState: ", GameState.freight_docs.size())

	if GameState.freight_docs.is_empty():
		info_label.text = "No freight documents yet."
		return

	info_label.text = "Freight documents currently on record: %d" % GameState.freight_docs.size()

	var index := 0
	for doc_variant in GameState.freight_docs:
		var doc: Dictionary = doc_variant

		var doc_id: String = doc.get("doc_id", "FDOC-????")
		var status: String = doc.get("status", "unknown")

		var origin_id: String = doc.get("origin_system_id", "?")
		var dest_id: String = doc.get("destination_system_id", "?")

		var origin_sys: Dictionary = Galaxy.get_system(origin_id)
		var dest_sys: Dictionary = Galaxy.get_system(dest_id)

		var origin_name: String = origin_sys.get("name", origin_id)
		var dest_name: String = dest_sys.get("name", dest_id)

		var contract_id: String = doc.get("contract_id", "")

		var label := "[%s] %s → %s  (%s)" \
			% [doc_id, origin_name, dest_name, status]

		print("FreightDocsPanel: adding item ", index, " label=", label)

		var item_index := docs_list.add_item(label)

		# Store the doc index or doc_id as metadata for later selection
		docs_list.set_item_metadata(item_index, index)
		index += 1

	print("FreightDocsPanel: added ", docs_list.item_count, " items to docs_list.")	
	print("FreightDocsPanel: docs_list.item_count = ", docs_list.item_count)


func _update_hint() -> void:
	if GameState.freight_docs.is_empty():
		hint_label.text = "Docs are created when you accept contracts from the job board."
	else:
		hint_label.text = "Select a document to see more details in the log."


func _on_DocsList_item_selected(index: int) -> void:

	#Log.add("_on_DockList_item_selected")

	# For now, we just log a bit of info when the player selects a doc.
	var meta = docs_list.get_item_metadata(index)
	if meta == null:
		return

	var doc_index: int = int(meta)
	if doc_index < 0 or doc_index >= GameState.freight_docs.size():
		return

	var doc: Dictionary = GameState.freight_docs[doc_index]
	var doc_id: String = doc.get("doc_id", "FDOC-????")
	var contract_id: String = doc.get("contract_id", "")
	var origin_id: String = doc.get("origin_system_id", "?")
	var dest_id: String = doc.get("destination_system_id", "?")

	var origin_sys: Dictionary = Galaxy.get_system(origin_id)
	var dest_sys: Dictionary = Galaxy.get_system(dest_id)

	var origin_name: String = origin_sys.get("name", origin_id)
	var dest_name: String = dest_sys.get("name", dest_id)
	var status: String = doc.get("status", "unknown")

	Log.add("Doc %s (contract %s): %s → %s, status=%s."
		% [doc_id, contract_id, origin_name, dest_name, status])

	var cargo_lines: Array = doc.get("cargo_lines", [])
	if cargo_lines.is_empty():
		Log.add("Doc %s has no declared cargo." % doc_id)
	else:
		var parts: Array = []
		for line_variant in cargo_lines:
			var line: Dictionary = line_variant
			var cid: String = line.get("commodity_id", "?")
			var qty: int = int(line.get("declared_qty", 0))
			parts.append("%d x %s" % [qty, cid])

		Log.add("Doc %s cargo: %s" % [doc_id, ", ".join(parts)])


func _on_CloseButton_pressed() -> void:
	queue_free()
