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

	if GameState.freight_docs.is_empty():
		info_label.text = "No freight documents yet."
		return

	info_label.text = "Freight documents currently on record: %d" % GameState.freight_docs.size()

	var index := 0
	for doc_variant in GameState.freight_docs:
		var doc: Dictionary = doc_variant

		var doc_id: String = doc.get("doc_id", "FDOC-????")
		var status: String = doc.get("status", "unknown")
		var doc_type: String = doc.get("doc_type", "contract")

		var label := ""
		if doc_type == "bill_of_sale":
			var commodity_id: String = ""
			var qty: int = 0
			var cargo_lines_variant = doc.get("cargo_lines", [])
			if cargo_lines_variant is Array and not cargo_lines_variant.is_empty():
				var first_line_variant = cargo_lines_variant[0]
				if first_line_variant is Dictionary:
					var line: Dictionary = first_line_variant
					commodity_id = String(line.get("commodity_id", ""))
					qty = int(line.get("sold_qty", line.get("declared_qty", 0)))
			if commodity_id == "":
				commodity_id = doc.get("commodity_id", "?")
				qty = int(doc.get("quantity", 0))
			var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
			var commodity_name: String = commodity.get("name", commodity_id)
			label = "[%s] Bill of Sale: %d x %s (%s)" \
				% [doc_id, qty, commodity_name, status]
		elif doc_type == "purchase_order":
			var commodity_id_po: String = doc.get("commodity_id", "?")
			var commodity_po: Dictionary = CommodityDB.get_commodity(commodity_id_po)
			var commodity_name_po: String = commodity_po.get("name", commodity_id_po)
			var qty_po: int = int(doc.get("quantity", 0))
			label = "[%s] Purchase Order: %d x %s (%s)" \
				% [doc_id, qty_po, commodity_name_po, status]
		else:
			var origin_id: String = doc.get("origin_system_id", "?")
			var dest_id: String = doc.get("destination_system_id", "?")

			var origin_sys: Dictionary = Galaxy.get_system(origin_id)
			var dest_sys: Dictionary = Galaxy.get_system(dest_id)

			var origin_name: String = origin_sys.get("name", origin_id)
			var dest_name: String = dest_sys.get("name", dest_id)

			label = "[%s] %s -> %s  (%s)" \
				% [doc_id, origin_name, dest_name, status]

		var item_index := docs_list.add_item(label)

		# Store the doc index or doc_id as metadata for later selection
		docs_list.set_item_metadata(item_index, index)
		index += 1
func _update_hint() -> void:
	if GameState.freight_docs.is_empty():
		hint_label.text = "Docs are created when you accept contracts or buy cargo."
	else:
		hint_label.text = "Select a document to see more details in the log."
func _on_DocsList_item_selected(index: int) -> void:

	# For now, we just log a bit of info when the player selects a doc.
	var meta = docs_list.get_item_metadata(index)
	if meta == null:
		return

	var doc_index: int = int(meta)
	if doc_index < 0 or doc_index >= GameState.freight_docs.size():
		return

	var doc: Dictionary = GameState.freight_docs[doc_index]
	var doc_id: String = doc.get("doc_id", "FDOC-????")
	var doc_type: String = doc.get("doc_type", "contract")
	var contract_id: String = doc.get("contract_id", "")
	var origin_id: String = doc.get("origin_system_id", "?")
	var dest_id: String = doc.get("destination_system_id", "?")

	if doc_type == "bill_of_sale":
		var commodity_id: String = ""
		var qty: int = 0
		var cargo_lines_variant = doc.get("cargo_lines", [])
		if cargo_lines_variant is Array and not cargo_lines_variant.is_empty():
			var first_line_variant = cargo_lines_variant[0]
			if first_line_variant is Dictionary:
				var line: Dictionary = first_line_variant
				commodity_id = String(line.get("commodity_id", ""))
				qty = int(line.get("sold_qty", line.get("declared_qty", 0)))
		if commodity_id == "":
			commodity_id = doc.get("commodity_id", "?")
			qty = int(doc.get("quantity", 0))
		var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
		var commodity_name: String = String(commodity.get("name", commodity_id))
		var location_name: String = String(doc.get("location_name", ""))
		if location_name == "":
			location_name = String(doc.get("purchase_location_name", ""))
		var market_kind: String = doc.get("market_kind", GameState.MARKET_KIND_LEGAL)
		Log.add_entry("Doc %s (bill of sale): %d x %s at %s (%s)."
			% [doc_id, qty, commodity_name, location_name, market_kind])
		return
	elif doc_type == "purchase_order":
		var commodity_id_po: String = doc.get("commodity_id", "?")
		var commodity_po: Dictionary = CommodityDB.get_commodity(commodity_id_po)
		var commodity_name_po: String = String(commodity_po.get("name", commodity_id_po))
		var qty_po: int = int(doc.get("quantity", 0))
		var location_name_po: String = String(doc.get("purchase_location_name", ""))
		Log.add_entry("Doc %s (purchase order): %d x %s at %s, status=%s."
			% [doc_id, qty_po, commodity_name_po, location_name_po, doc.get("status", "unknown")], "OTHER")
		var cargo_lines_po: Array = doc.get("cargo_lines", [])
		if cargo_lines_po.is_empty():
			Log.add_entry("Doc %s has no declared cargo." % doc_id, "OTHER")
		else:
			var parts_po: Array = []
			for line_variant in cargo_lines_po:
				var line_po: Dictionary = line_variant
				var cid_po: String = line_po.get("commodity_id", "?")
				var qty_line_po: int = int(line_po.get("declared_qty", 0))
				parts_po.append("%d x %s" % [qty_line_po, cid_po])
			Log.add_entry("Doc %s cargo: %s" % [doc_id, ", ".join(parts_po)], "OTHER")
		return

	var origin_sys: Dictionary = Galaxy.get_system(origin_id)
	var dest_sys: Dictionary = Galaxy.get_system(dest_id)

	var origin_name: String = origin_sys.get("name", origin_id)
	var dest_name: String = dest_sys.get("name", dest_id)
	var status: String = doc.get("status", "unknown")

	Log.add_entry("Doc %s (contract %s): %s -> %s, status=%s."
		% [doc_id, contract_id, origin_name, dest_name, status])

	var cargo_lines: Array = doc.get("cargo_lines", [])
	if cargo_lines.is_empty():
		Log.add_entry("Doc %s has no declared cargo." % doc_id)
	else:
		var parts: Array = []
		for line_variant in cargo_lines:
			var line: Dictionary = line_variant
			var cid: String = line.get("commodity_id", "?")
			var qty: int = int(line.get("declared_qty", 0))
			parts.append("%d x %s" % [qty, cid])

		Log.add_entry("Doc %s cargo: %s" % [doc_id, ", ".join(parts)])

func _on_CloseButton_pressed() -> void:
	queue_free()


