extends Control

signal close_requested

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var info_label: Label = $MarginContainer/VBoxContainer/InfoLabel
@onready var player_money_label: Label = $MarginContainer/VBoxContainer/InfoRow/PlayerMoneyLabel
@onready var cargo_weight_label: Label = $MarginContainer/VBoxContainer/InfoRow/CargoWeightLabel
@onready var offers_grid: Tree = $MarginContainer/VBoxContainer/ContentRow/OffersColumn/OffersGrid
@onready var inventory_grid: Tree = $MarginContainer/VBoxContainer/ContentRow/InventoryColumn/InventoryGrid
@onready var create_purchase_order_button: Button = $MarginContainer/VBoxContainer/ContentRow/OffersColumn/OffersHeader/CreatePurchaseOrderButton
@onready var sell_manifest_inventory_button: Button = $MarginContainer/VBoxContainer/ContentRow/InventoryColumn/InventoryHeader/SellManifestInventoryButton
@onready var close_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/CloseButton
@onready var purchase_order_dialog: Window = $PurchaseOrderDialog

var price_by_commodity: Dictionary = {}
var _sell_dialog: Window
var _sell_qty_spin: SpinBox
var _sell_status_label: Label
var _sell_total_label: Label
var _sell_unit_price_label: Label
var _sell_commodity_label: Label
var _sell_commodity_id: String = ""
var _sell_market_kind: String = GameState.MARKET_KIND_BLACK_MARKET
var _sell_raw_qty_text: String = ""
var _has_sellable_cargo: bool = false

func _ready() -> void:
	title_label.text = "Black Market"

	offers_grid.mouse_filter = Control.MOUSE_FILTER_STOP

	if create_purchase_order_button != null:
		create_purchase_order_button.pressed.connect(_on_create_purchase_order_pressed)
	if sell_manifest_inventory_button != null:
		sell_manifest_inventory_button.pressed.connect(_on_sell_manifest_inventory_pressed)
	close_button.pressed.connect(_on_CloseButton_pressed)

	if purchase_order_dialog != null:
		purchase_order_dialog.confirmed.connect(_on_purchase_order_confirmed)
		purchase_order_dialog.cancelled.connect(_on_purchase_order_cancelled)
		purchase_order_dialog.hide()

	_build_sell_dialog()

	if GameState.has_signal("ship_changed"):
		GameState.ship_changed.connect(_on_ship_changed)
	if GameState.has_signal("system_changed"):
		GameState.system_changed.connect(_on_system_changed)

	refresh_all()


func refresh_all() -> void:
	_refresh_player_info()
	_refresh_market_list()
	_refresh_inventory_list()


func _refresh_player_info() -> void:
	player_money_label.text = "Credits: %.0f" % GameState.player_money

	var weight: float = GameState.get_total_cargo_weight()
	var capacity: float = GameState.cargo_capacity_weight
	cargo_weight_label.text = "Cargo: %.1f / %.1f" % [weight, capacity]


func _refresh_market_list() -> void:
	offers_grid.clear()
	price_by_commodity.clear()

	var location_id: String = GameState.current_location_id
	if not GameState.location_has_black_market(location_id):
		info_label.text = "No black market at this location."
		_set_market_interactive(false)
		return

	var sys_id: String = GameState.current_system_id
	if sys_id == "":
		info_label.text = "No system selected."
		_set_market_interactive(false)
		return

	var price_list: Array = Economy.get_black_market_offers_for_system(sys_id)
	if price_list.is_empty():
		info_label.text = "No black market offers available."
		_set_market_interactive(false)
		return

	info_label.text = "Black market offers: %d" % price_list.size()
	price_list.sort_custom(Callable(self, "_sort_price_entries_by_name"))

	_configure_offers_grid()
	var root: TreeItem = offers_grid.create_item()

	for entry_variant in price_list:
		var entry: Dictionary = entry_variant
		var name: String = entry.get("name", "???")
		var price: float = float(entry.get("price", 0.0))
		var commodity_id: String = entry.get("commodity_id", entry.get("id", ""))
		var item: TreeItem = offers_grid.create_item(root)
		item.set_text(0, name)
		item.set_text(1, "-")
		item.set_text(2, "%.0f" % price)
		item.set_metadata(0, commodity_id)
		price_by_commodity[commodity_id] = price

	_set_market_interactive(true)


func _refresh_inventory_list() -> void:
	if inventory_grid == null:
		return
	inventory_grid.clear()

	var cargo_entries: Array = []
	_has_sellable_cargo = false
	for commodity_variant in GameState.cargo.keys():
		var commodity_id: String = String(commodity_variant)
		var qty: int = int(GameState.cargo.get(commodity_variant, 0))
		if qty <= 0:
			continue

		var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
		var name: String = String(commodity.get("name", commodity_id))
		var price_text: String = "-"
		if price_by_commodity.has(commodity_id):
			price_text = "%.0f" % float(price_by_commodity[commodity_id])
		cargo_entries.append({
			"id": commodity_id,
			"name": name,
			"qty": qty,
			"price_text": price_text,
		})
		_has_sellable_cargo = true

	cargo_entries.sort_custom(Callable(self, "_sort_inventory_entries"))
	_configure_inventory_grid()
	var root: TreeItem = inventory_grid.create_item()
	for entry_variant in cargo_entries:
		var entry: Dictionary = entry_variant
		var item: TreeItem = inventory_grid.create_item(root)
		item.set_text(0, String(entry.get("name", "???")))
		item.set_text(1, str(int(entry.get("qty", 0))))
		item.set_text(2, String(entry.get("price_text", "-")))
		item.set_metadata(0, String(entry.get("id", "")))
	if sell_manifest_inventory_button != null:
		sell_manifest_inventory_button.disabled = not _has_sellable_cargo


func _sort_inventory_entries(a: Dictionary, b: Dictionary) -> bool:
	var name_a: String = String(a.get("name", ""))
	var name_b: String = String(b.get("name", ""))
	if name_a == name_b:
		return String(a.get("id", "")) < String(b.get("id", ""))
	return name_a < name_b


func _set_market_interactive(enabled: bool) -> void:
	if create_purchase_order_button != null:
		create_purchase_order_button.disabled = not enabled
	if sell_manifest_inventory_button != null:
		sell_manifest_inventory_button.disabled = (not enabled) or (not _has_sellable_cargo)
	if offers_grid != null:
		if enabled:
			offers_grid.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			offers_grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if inventory_grid != null:
		if enabled:
			inventory_grid.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			inventory_grid.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _sort_price_entries_by_name(a: Dictionary, b: Dictionary) -> bool:
	var name_a: String = a.get("name", "")
	var name_b: String = b.get("name", "")
	if name_a == name_b:
		var id_a: String = a.get("commodity_id", a.get("id", ""))
		var id_b: String = b.get("commodity_id", b.get("id", ""))
		return id_a < id_b
	return name_a < name_b


func _configure_offers_grid() -> void:
	offers_grid.columns = 3
	offers_grid.set_column_titles_visible(true)
	offers_grid.set_column_title(0, "Commodity")
	offers_grid.set_column_title(1, "Qty")
	offers_grid.set_column_title(2, "Price")
	offers_grid.hide_root = true


func _configure_inventory_grid() -> void:
	inventory_grid.columns = 3
	inventory_grid.set_column_titles_visible(true)
	inventory_grid.set_column_title(0, "Commodity")
	inventory_grid.set_column_title(1, "Qty")
	inventory_grid.set_column_title(2, "Price")
	inventory_grid.hide_root = true


func _on_create_purchase_order_pressed() -> void:
	if purchase_order_dialog == null:
		return
	var selected: TreeItem = offers_grid.get_selected()
	if selected == null:
		if purchase_order_dialog.has_method("set_status"):
			purchase_order_dialog.call("set_status", "Select a black market commodity first.")
		return
	var commodity_id_variant = selected.get_metadata(0)
	var commodity_id: String = ""
	if commodity_id_variant != null:
		commodity_id = String(commodity_id_variant)
	if commodity_id == "":
		if purchase_order_dialog.has_method("set_status"):
			purchase_order_dialog.call("set_status", "Selected entry is missing a commodity id.")
		return
	if not price_by_commodity.has(commodity_id):
		if purchase_order_dialog.has_method("set_status"):
			purchase_order_dialog.call("set_status", "Selected entry has no price data.")
		return

	var unit_price: float = float(price_by_commodity[commodity_id])
	var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
	if commodity.is_empty():
		if purchase_order_dialog.has_method("set_status"):
			purchase_order_dialog.call("set_status", "Unknown commodity.")
		return

	var commodity_name: String = String(commodity.get("name", commodity_id))
	var weight: float = GameState.get_total_cargo_weight()
	var capacity: float = GameState.cargo_capacity_weight

	if purchase_order_dialog.has_method("setup"):
		purchase_order_dialog.call(
			"setup",
			commodity_id,
			commodity_name,
			unit_price,
			GameState.player_money,
			weight,
			capacity
		)

	purchase_order_dialog.popup_centered()


func _on_purchase_order_confirmed(commodity_id: String, qty: int) -> void:
	if commodity_id == "" or qty <= 0:
		if purchase_order_dialog != null and purchase_order_dialog.has_method("set_status"):
			purchase_order_dialog.call("set_status", "Invalid purchase.")
		return

	if not price_by_commodity.has(commodity_id):
		if purchase_order_dialog != null and purchase_order_dialog.has_method("set_status"):
			purchase_order_dialog.call("set_status", "Selected entry has no price data.")
		return

	var price: float = float(price_by_commodity[commodity_id])
	var total_cost: float = price * float(qty)
	if total_cost > GameState.player_money:
		if purchase_order_dialog != null and purchase_order_dialog.has_method("set_status"):
			purchase_order_dialog.call("set_status", "Not enough credits.")
		return

	var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
	if commodity.is_empty():
		if purchase_order_dialog != null and purchase_order_dialog.has_method("set_status"):
			purchase_order_dialog.call("set_status", "Unknown commodity.")
		return

	var per_unit_weight: float = float(commodity.get("weight_per_unit", 1.0))
	var added_weight: float = per_unit_weight * float(qty)
	var current_weight: float = GameState.get_total_cargo_weight()
	var capacity: float = GameState.cargo_capacity_weight
	if current_weight + added_weight > capacity:
		if purchase_order_dialog != null and purchase_order_dialog.has_method("set_status"):
			purchase_order_dialog.call("set_status", "Not enough cargo capacity.")
		return

	GameState.player_money -= total_cost
	GameState.add_cargo(commodity_id, qty)
	GameState.record_market_purchase(
		commodity_id,
		qty,
		price,
		total_cost,
		GameState.MARKET_KIND_BLACK_MARKET
	)

	Log.add_entry("Bought %d x %s on the black market for %.0f cr."
		% [qty, commodity.get("name", commodity_id), total_cost])

	if purchase_order_dialog != null:
		purchase_order_dialog.hide()
	refresh_all()


func _on_purchase_order_cancelled() -> void:
	if purchase_order_dialog != null:
		purchase_order_dialog.hide()


func _on_sell_manifest_inventory_pressed() -> void:
	if _sell_dialog == null:
		return
	if inventory_grid == null:
		return

	var selected: TreeItem = inventory_grid.get_selected()
	if selected == null:
		return

	var commodity_id_variant = selected.get_metadata(0)
	var commodity_id: String = ""
	if commodity_id_variant != null:
		commodity_id = String(commodity_id_variant)
	if commodity_id == "":
		return

	var have_qty: int = GameState.get_cargo_quantity(commodity_id)
	if have_qty <= 0:
		_sell_status_label.text = "No cargo available."
		return

	_sell_commodity_id = commodity_id
	_sell_commodity_label.text = "Commodity: %s" % selected.get_text(0)
	_sell_qty_spin.max_value = have_qty
	_sell_qty_spin.value = clamp(1, int(_sell_qty_spin.min_value), int(_sell_qty_spin.max_value))
	var le := _sell_qty_spin.get_line_edit()
	if le != null:
		le.text = str(int(_sell_qty_spin.value))
	_sell_raw_qty_text = str(int(_sell_qty_spin.value))
	_sell_status_label.text = ""
	_refresh_sell_quote()
	_sell_dialog.popup_centered()


func _build_sell_dialog() -> void:
	_sell_dialog = Window.new()
	_sell_dialog.title = "Sell Manifest"
	_sell_dialog.exclusive = true
	_sell_dialog.unresizable = true
	_sell_dialog.visible = false
	_sell_dialog.size = Vector2i(420, 260)
	add_child(_sell_dialog)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	_sell_dialog.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	_sell_commodity_label = Label.new()
	_sell_commodity_label.text = "Commodity:"
	vbox.add_child(_sell_commodity_label)

	_sell_unit_price_label = Label.new()
	_sell_unit_price_label.text = "Unit Price:"
	vbox.add_child(_sell_unit_price_label)

	var qty_row := HBoxContainer.new()
	qty_row.add_theme_constant_override("separation", 8)
	vbox.add_child(qty_row)

	var qty_label := Label.new()
	qty_label.text = "Quantity:"
	qty_row.add_child(qty_label)

	_sell_qty_spin = SpinBox.new()
	_sell_qty_spin.min_value = 1
	_sell_qty_spin.max_value = 999
	_sell_qty_spin.allow_greater = true
	_sell_qty_spin.allow_lesser = true
	_sell_qty_spin.step = 1
	_sell_qty_spin.value_changed.connect(_on_sell_qty_changed)
	qty_row.add_child(_sell_qty_spin)
	var le := _sell_qty_spin.get_line_edit()
	if le != null:
		le.text_changed.connect(_on_sell_qty_text_changed)

	_sell_total_label = Label.new()
	_sell_total_label.text = "Total:"
	vbox.add_child(_sell_total_label)

	_sell_status_label = Label.new()
	_sell_status_label.text = ""
	vbox.add_child(_sell_status_label)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)
	vbox.add_child(buttons)

	var confirm_button := Button.new()
	confirm_button.text = "Confirm"
	confirm_button.pressed.connect(_on_sell_confirm_pressed)
	buttons.add_child(confirm_button)

	var cancel_button := Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(_on_sell_cancel_pressed)
	buttons.add_child(cancel_button)

	_sell_dialog.close_requested.connect(_on_sell_cancel_pressed)


func _on_sell_qty_changed(_value: float) -> void:
	_refresh_sell_quote()


func _on_sell_qty_text_changed(new_text: String) -> void:
	_sell_raw_qty_text = String(new_text).strip_edges()
	if _sell_qty_spin == null:
		return
	if _sell_raw_qty_text != "" and _sell_raw_qty_text.is_valid_int():
		var parsed_qty: int = int(_sell_raw_qty_text)
		var clamped_qty: int = clamp(parsed_qty, int(_sell_qty_spin.min_value), int(_sell_qty_spin.max_value))
		_sell_qty_spin.value = clamped_qty
	_refresh_sell_quote()


func _refresh_sell_quote() -> void:
	if _sell_commodity_id == "":
		_sell_unit_price_label.text = "Unit Price:"
		_sell_total_label.text = "Total:"
		return

	var qty: int = int(_sell_qty_spin.value)
	var quote: Dictionary = Economy.quote_sale_price(
		_sell_commodity_id,
		qty,
		GameState.current_system_id,
		GameState.current_location_id,
		_sell_market_kind
	)
	if not bool(quote.get("ok", false)):
		_sell_unit_price_label.text = "Unit Price: -"
		_sell_total_label.text = "Total: -"
		_sell_status_label.text = String(quote.get("error", "No market price available."))
		return

	_sell_status_label.text = ""
	var unit_price: float = float(quote.get("final_unit_price", quote.get("unit_price", 0.0)))
	var total_price: float = float(quote.get("total_price", 0.0))
	_sell_unit_price_label.text = "Unit Price: %.0f cr" % unit_price
	_sell_total_label.text = "Total: %.0f cr" % total_price


func _on_sell_confirm_pressed() -> void:
	if _sell_commodity_id == "":
		_sell_status_label.text = "Select cargo to sell."
		return

	var have_qty: int = GameState.get_cargo_quantity(_sell_commodity_id)
	var parsed_qty: int = 0
	var raw_text := _sell_raw_qty_text
	if raw_text != "" and raw_text.is_valid_int():
		parsed_qty = int(raw_text)
	else:
		parsed_qty = int(_sell_qty_spin.value)
	if parsed_qty <= 0:
		_sell_status_label.text = "Invalid quantity."
		return
	if parsed_qty > have_qty:
		_sell_status_label.text = "Not enough cargo (have %d)." % have_qty
		Log.add_entry(
			"Sale blocked: attempted to sell %d but only %d available." % [parsed_qty, have_qty],
			"OTHER"
		)
		return

	var qty: int = parsed_qty
	var result: Dictionary = GameState.sell_manifest_goods(
		_sell_commodity_id,
		qty,
		GameState.current_system_id,
		GameState.current_location_id,
		_sell_market_kind
	)
	if bool(result.get("ok", false)):
		_sell_dialog.hide()
		_sell_commodity_id = ""
		_sell_raw_qty_text = ""
		if _sell_status_label != null:
			_sell_status_label.text = ""
		if _sell_commodity_label != null:
			_sell_commodity_label.text = "Commodity:"
		if _sell_unit_price_label != null:
			_sell_unit_price_label.text = "Unit Price:"
		if _sell_total_label != null:
			_sell_total_label.text = "Total:"
		refresh_all()
		return

	_sell_status_label.text = String(result.get("error", "Sale failed."))


func _on_sell_cancel_pressed() -> void:
	if _sell_dialog != null:
		_sell_dialog.hide()
	_sell_commodity_id = ""
	_sell_raw_qty_text = ""
	if _sell_status_label != null:
		_sell_status_label.text = ""
	if _sell_commodity_label != null:
		_sell_commodity_label.text = "Commodity:"
	if _sell_unit_price_label != null:
		_sell_unit_price_label.text = "Unit Price:"
	if _sell_total_label != null:
		_sell_total_label.text = "Total:"

func _on_CloseButton_pressed() -> void:
	emit_signal("close_requested")


func _on_ship_changed() -> void:
	refresh_all()


func _on_system_changed(_new_system_id: String) -> void:
	refresh_all()
