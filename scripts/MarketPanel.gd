# res://scenes/MarketPanel.gd
extends Control

# --- UI references ---

signal request_create_purchase_order
signal request_sell_manifest_inventory

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var player_money_label: Label = $MarginContainer/VBoxContainer/InfoRow/PlayerMoneyLabel
@onready var cargo_weight_label: Label = $MarginContainer/VBoxContainer/InfoRow/CargoWeightLabel

@onready var market_grid: Tree = $MarginContainer/VBoxContainer/ContentRow/MarketColumn/MarketGrid
@onready var inventory_grid: Tree = $MarginContainer/VBoxContainer/ContentRow/InventoryColumn/InventoryGrid
@onready var create_purchase_order_button: Button = $MarginContainer/VBoxContainer/ContentRow/MarketColumn/MarketHeader/CreatePurchaseOrderButton
@onready var sell_manifest_inventory_button: Button = $MarginContainer/VBoxContainer/ContentRow/InventoryColumn/InventoryHeader/SellManifestInventoryButton
@onready var purchase_order_dialog: Window = $PurchaseOrderDialog

# --- Market data ---

var price_by_commodity: Dictionary = {}  # commodity_id -> price
var _sell_dialog: Window
var _sell_qty_spin: SpinBox
var _sell_status_label: Label
var _sell_total_label: Label
var _sell_unit_price_label: Label
var _sell_commodity_label: Label
var _sell_commodity_id: String = ""
var _sell_market_kind: String = GameState.MARKET_KIND_LEGAL
var _sell_raw_qty_text: String = ""



func _ready() -> void:
	title_label.text = "Market"

	if create_purchase_order_button != null:
		create_purchase_order_button.pressed.connect(_on_create_purchase_order_pressed)

	if sell_manifest_inventory_button != null:
		sell_manifest_inventory_button.pressed.connect(_on_sell_manifest_inventory_pressed)

	if purchase_order_dialog != null:
		purchase_order_dialog.confirmed.connect(_on_purchase_order_confirmed)
		purchase_order_dialog.cancelled.connect(_on_purchase_order_cancelled)
		purchase_order_dialog.hide()

	_build_sell_dialog()

	refresh_all()


# --- Public refresh entrypoint ---

func refresh_all() -> void:
	_refresh_player_info()
	_refresh_market_list()
	_refresh_cargo_list()


# --- Refresh helpers ---

func _refresh_player_info() -> void:
	player_money_label.text = "Credits: %.0f" % GameState.player_money

	var weight: float = GameState.get_total_cargo_weight()
	var capacity: float = GameState.cargo_capacity_weight
	cargo_weight_label.text = "Cargo: %.1f / %.1f" % [weight, capacity]


func _refresh_market_list() -> void:
	market_grid.clear()
	price_by_commodity.clear()

	var sys_id: String = GameState.current_system_id
	if sys_id == "":
		return

	var price_list: Array = Economy.get_price_list_for_system(sys_id)

	# Sort alphabetically by commodity name
	price_list.sort_custom(Callable(self, "_sort_price_entries_by_name"))

	_configure_market_grid()
	var root: TreeItem = market_grid.create_item()

	for entry_variant in price_list:
		var entry: Dictionary = entry_variant

		var name: String = entry.get("name", "???")
		var price: float = float(entry.get("price", 0.0))
		var id: String = entry.get("id", "")

		var item: TreeItem = market_grid.create_item(root)
		item.set_text(0, name)
		item.set_text(1, "-")
		item.set_text(2, "%.0f" % price)
		item.set_metadata(0, id)

		price_by_commodity[id] = price


func _refresh_cargo_list() -> void:
	inventory_grid.clear()
	_configure_inventory_grid()
	var root: TreeItem = inventory_grid.create_item()

	for commodity_id in GameState.cargo.keys():
		var qty: int = GameState.get_cargo_quantity(commodity_id)
		if qty <= 0:
			continue

		var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
		if commodity.is_empty():
			continue

		var name: String = commodity.get("name", commodity_id)
		var price_text: String = "-"
		if price_by_commodity.has(commodity_id):
			price_text = "%.0f" % float(price_by_commodity[commodity_id])

		var item: TreeItem = inventory_grid.create_item(root)
		item.set_text(0, name)
		item.set_text(1, str(qty))
		item.set_text(2, price_text)
		item.set_metadata(0, commodity_id)


# --- Sorting helper ---

func _sort_price_entries_by_name(a: Dictionary, b: Dictionary) -> bool:
	var name_a: String = a.get("name", "")
	var name_b: String = b.get("name", "")
	return name_a < name_b

func _configure_market_grid() -> void:
	market_grid.columns = 3
	market_grid.set_column_titles_visible(true)
	market_grid.set_column_title(0, "Commodity")
	market_grid.set_column_title(1, "Qty")
	market_grid.set_column_title(2, "Price")
	market_grid.hide_root = true


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

	var selected: TreeItem = market_grid.get_selected()
	if selected == null:
		if purchase_order_dialog.has_method("set_status"):
			purchase_order_dialog.call("set_status", "Select a market commodity first.")
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

	var commodity_name: String = selected.get_text(0)
	var unit_price: float = float(price_by_commodity[commodity_id])
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


func _on_sell_manifest_inventory_pressed() -> void:
	if _sell_dialog == null:
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


func _on_purchase_order_confirmed(commodity_id: String, qty: int) -> void:
	var result: Dictionary = GameState.purchase_market_goods(commodity_id, qty)
	if bool(result.get("ok", false)):
		if purchase_order_dialog != null:
			purchase_order_dialog.hide()
		refresh_all()
		return

	if purchase_order_dialog != null and purchase_order_dialog.has_method("set_status"):
		purchase_order_dialog.call("set_status", String(result.get("error", "Purchase failed.")))


func _on_purchase_order_cancelled() -> void:
	if purchase_order_dialog != null:
		purchase_order_dialog.hide()


# --- Ship / System change signals ---

func _on_ship_changed() -> void:
	# cargo, capacity, maybe engine level changed
	refresh_all()


func _on_system_changed(new_system_id: String) -> void:
	# prices and system label change
	refresh_all()


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
		refresh_all()
		return

	_sell_status_label.text = String(result.get("error", "Sale failed."))


func _on_sell_cancel_pressed() -> void:
	if _sell_dialog != null:
		_sell_dialog.hide()
