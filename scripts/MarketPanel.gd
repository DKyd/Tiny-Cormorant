# res://scenes/MarketPanel.gd
extends Control

# --- UI references ---

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel

@onready var commodities_list: ItemList = $MarginContainer/VBoxContainer/CommoditiesList
@onready var cargo_list: ItemList = $MarginContainer/VBoxContainer/CargoList

@onready var qty_spin: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/QtySpin

@onready var buy_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/BuyButton
@onready var sell_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/SellButton

@onready var player_money_label: Label = $MarginContainer/VBoxContainer/PlayerMoneyLabel
@onready var cargo_weight_label: Label = $MarginContainer/VBoxContainer/CargoWeightLabel

# --- Market data ---

# index in ItemList -> { id, name, price }
var entries: Array = []              # Array<Dictionary>
var price_by_commodity: Dictionary = {}  # commodity_id -> price



func _ready() -> void:
	print("MarketPanel: _ready. current_system_id =", GameState.current_system_id)
	
	print("=== MarketPanel runtime tree ===")
	print_tree_pretty()

	title_label.text = "Market"

	qty_spin.min_value = 1
	qty_spin.max_value = 999
	qty_spin.step = 1

	# Make lists expand and actually occupy vertical space
	commodities_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	commodities_list.custom_minimum_size.y = 160

	cargo_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cargo_list.custom_minimum_size.y = 100

	commodities_list.select_mode = ItemList.SELECT_SINGLE
	commodities_list.mouse_filter = Control.MOUSE_FILTER_STOP

	cargo_list.select_mode = ItemList.SELECT_SINGLE
	cargo_list.mouse_filter = Control.MOUSE_FILTER_STOP

	refresh_all()

	print("MarketPanel: size after ready =", size)
	print("MarketPanel: commodities_list size =", commodities_list.size)
	print("MarketPanel: cargo_list size =", cargo_list.size)
	print("MarketPanel: commodities_list rect =", commodities_list.get_rect())


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
	entries.clear()
	commodities_list.clear()
	price_by_commodity.clear()

	var sys_id: String = GameState.current_system_id
	if sys_id == "":
		return

	var price_list: Array = Economy.get_price_list_for_system(sys_id)

	# Sort alphabetically by commodity name
	price_list.sort_custom(Callable(self, "_sort_price_entries_by_name"))

	for entry_variant in price_list:
		var entry: Dictionary = entry_variant

		var name: String = entry.get("name", "???")
		var price: float = float(entry.get("price", 0.0))
		var id: String = entry.get("id", "")
		var line: String = "%s  -  %.0f cr" % [name, price]

		var idx: int = commodities_list.add_item(line)

		if entries.size() <= idx:
			entries.resize(idx + 1)
		entries[idx] = {
			"id": id,
			"name": name,
			"price": price
		}

		price_by_commodity[id] = price


func _refresh_cargo_list() -> void:
	cargo_list.clear()

	for commodity_id in GameState.cargo.keys():
		var qty: int = GameState.get_cargo_quantity(commodity_id)
		if qty <= 0:
			continue

		var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
		if commodity.is_empty():
			continue

		var name: String = commodity.get("name", commodity_id)
		var label: String = "%s x %d" % [name, qty]

		var idx: int = cargo_list.add_item(label)
		# so we can look this up in SELL
		cargo_list.set_item_metadata(idx, commodity_id)


# --- Sorting helper ---

func _sort_price_entries_by_name(a: Dictionary, b: Dictionary) -> bool:
	var name_a: String = a.get("name", "")
	var name_b: String = b.get("name", "")
	return name_a < name_b


# --- BUY / SELL logic ---

func _on_CommoditiesList_item_selected(index: int) -> void:
	# Optional UX: set qty to 1 when selecting a new commodity
	qty_spin.value = 1


func _on_BuyButton_pressed() -> void:
	var selected: PackedInt32Array = commodities_list.get_selected_items()
	if selected.size() == 0:
		Log.add_entry("No market commodity selected to buy.")
		return

	var idx: int = selected[0]
	if idx < 0 or idx >= entries.size():
		Log.add_entry("Invalid market selection.")
		return

	var entry: Dictionary = entries[idx]
	var commodity_id: String = entry.get("id", "")
	var price: float = float(entry.get("price", 0.0))

	if commodity_id == "":
		Log.add_entry("Selected market entry has no commodity id.")
		return

	var qty_to_buy: int = int(qty_spin.value)
	if qty_to_buy <= 0:
		return

	# Check money
	var total_cost: float = price * float(qty_to_buy)
	if total_cost > GameState.player_money:
		Log.add_entry("Not enough credits to buy %d units." % qty_to_buy)
		return

	# Check cargo capacity by weight
	var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
	if commodity.is_empty():
		Log.add_entry("Unknown commodity: %s" % commodity_id)
		return

	var per_unit_weight: float = float(commodity.get("weight_per_unit", 1.0))
	var added_weight: float = per_unit_weight * float(qty_to_buy)
	var current_weight: float = GameState.get_total_cargo_weight()
	var capacity: float = GameState.cargo_capacity_weight

	if current_weight + added_weight > capacity:
		Log.add_entry("Not enough cargo capacity for that purchase.")
		return

	# Apply transaction
	GameState.player_money -= total_cost
	GameState.add_cargo(commodity_id, qty_to_buy)

	Log.add_entry("Bought %d x %s for %.0f cr."
		% [qty_to_buy, commodity.get("name", commodity_id), total_cost])

	refresh_all()


func _on_SellButton_pressed() -> void:
	# SELL is based on cargo selection, not market list
	var selected: PackedInt32Array = cargo_list.get_selected_items()
	if selected.size() == 0:
		Log.add_entry("No cargo selected to sell.")
		return

	var idx: int = selected[0]
	if idx < 0:
		return

	var meta = cargo_list.get_item_metadata(idx)
	if meta == null:
		Log.add_entry("Selected cargo has no commodity metadata.")
		return

	var commodity_id: String = str(meta)

	# How much do we own?
	var have_qty: int = GameState.get_cargo_quantity(commodity_id)
	if have_qty <= 0:
		Log.add_entry("You have no units of that cargo to sell.")
		return

	var qty_to_sell: int = int(qty_spin.value)
	if qty_to_sell <= 0:
		return

	if qty_to_sell > have_qty:
		qty_to_sell = have_qty

	# Get price for this commodity in the current system
	if not price_by_commodity.has(commodity_id):
		Log.add_entry("No market price available here for that cargo.")
		return

	var price: float = float(price_by_commodity[commodity_id])
	var revenue: float = price * float(qty_to_sell)

	GameState.player_money += revenue
	GameState.remove_cargo(commodity_id, qty_to_sell)

	var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
	var name: String = commodity.get("name", commodity_id)

	Log.add_entry("Sold %d x %s for %.0f cr."
		% [qty_to_sell, name, revenue])

	refresh_all()


# --- Ship / System change signals ---

func _on_ship_changed() -> void:
	# cargo, capacity, maybe engine level changed
	refresh_all()


func _on_system_changed(new_system_id: String) -> void:
	# prices and system label change
	refresh_all()

