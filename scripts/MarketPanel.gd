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



func _ready() -> void:
	title_label.text = "Market"

	if create_purchase_order_button != null:
		create_purchase_order_button.pressed.connect(_on_create_purchase_order_pressed)

	if sell_manifest_inventory_button != null:
		sell_manifest_inventory_button.pressed.connect(_on_sell_manifest_inventory_pressed)

	if purchase_order_dialog != null:
		purchase_order_dialog.confirmed.connect(_on_purchase_order_confirmed)
		purchase_order_dialog.cancelled.connect(_on_purchase_order_cancelled)

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
	request_sell_manifest_inventory.emit()


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


