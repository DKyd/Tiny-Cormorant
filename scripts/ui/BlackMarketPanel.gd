extends Control

signal close_requested

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var info_label: Label = $MarginContainer/VBoxContainer/InfoLabel
@onready var offers_list: ItemList = $MarginContainer/VBoxContainer/OffersList
@onready var qty_spin: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/QtySpin
@onready var buy_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/BuyButton
@onready var close_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/CloseButton
@onready var player_money_label: Label = $MarginContainer/VBoxContainer/PlayerMoneyLabel
@onready var cargo_weight_label: Label = $MarginContainer/VBoxContainer/CargoWeightLabel

var entries: Array = []


func _ready() -> void:
	title_label.text = "Black Market"

	qty_spin.min_value = 1
	qty_spin.max_value = 999
	qty_spin.step = 1

	offers_list.select_mode = ItemList.SELECT_SINGLE
	offers_list.mouse_filter = Control.MOUSE_FILTER_STOP

	buy_button.pressed.connect(_on_BuyButton_pressed)
	close_button.pressed.connect(_on_CloseButton_pressed)
	offers_list.item_selected.connect(_on_OffersList_item_selected)

	if GameState.has_signal("ship_changed"):
		GameState.ship_changed.connect(_on_ship_changed)
	if GameState.has_signal("system_changed"):
		GameState.system_changed.connect(_on_system_changed)

	refresh_all()


func refresh_all() -> void:
	_refresh_player_info()
	_refresh_market_list()


func _refresh_player_info() -> void:
	player_money_label.text = "Credits: %.0f" % GameState.player_money

	var weight: float = GameState.get_total_cargo_weight()
	var capacity: float = GameState.cargo_capacity_weight
	cargo_weight_label.text = "Cargo: %.1f / %.1f" % [weight, capacity]


func _refresh_market_list() -> void:
	entries.clear()
	offers_list.clear()

	var sys_id: String = GameState.current_system_id
	if sys_id == "":
		info_label.text = "No system selected."
		buy_button.disabled = true
		return

	var price_list: Array = Economy.get_black_market_offers_for_system(sys_id)
	if price_list.is_empty():
		info_label.text = "No black market offers available."
		buy_button.disabled = true
		return

	info_label.text = "Black market offers: %d" % price_list.size()
	price_list.sort_custom(Callable(self, "_sort_price_entries_by_name"))

	for entry_variant in price_list:
		var entry: Dictionary = entry_variant
		var name: String = entry.get("name", "???")
		var price: float = float(entry.get("price", 0.0))
		var commodity_id: String = entry.get("id", "")
		var line: String = "%s  -  %.0f cr" % [name, price]

		var idx: int = offers_list.add_item(line)
		if entries.size() <= idx:
			entries.resize(idx + 1)
		entries[idx] = {
			"id": commodity_id,
			"name": name,
			"price": price,
		}

	buy_button.disabled = false


func _sort_price_entries_by_name(a: Dictionary, b: Dictionary) -> bool:
	var name_a: String = a.get("name", "")
	var name_b: String = b.get("name", "")
	return name_a < name_b


func _on_OffersList_item_selected(_index: int) -> void:
	qty_spin.value = 1


func _on_BuyButton_pressed() -> void:
	var selected: PackedInt32Array = offers_list.get_selected_items()
	if selected.size() == 0:
		Log.add_entry("No black market item selected to buy.")
		return

	var idx: int = selected[0]
	if idx < 0 or idx >= entries.size():
		Log.add_entry("Invalid black market selection.")
		return

	var entry: Dictionary = entries[idx]
	var commodity_id: String = entry.get("id", "")
	var price: float = float(entry.get("price", 0.0))

	if commodity_id == "":
		Log.add_entry("Selected black market entry has no commodity id.")
		return

	var qty_to_buy: int = int(qty_spin.value)
	if qty_to_buy <= 0:
		return

	var total_cost: float = price * float(qty_to_buy)
	if total_cost > GameState.player_money:
		Log.add_entry("Not enough credits to buy %d units." % qty_to_buy)
		return

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

	GameState.player_money -= total_cost
	GameState.add_cargo(commodity_id, qty_to_buy)
	GameState.record_market_purchase(
		commodity_id,
		qty_to_buy,
		price,
		total_cost,
		GameState.MARKET_KIND_BLACK_MARKET
	)

	Log.add_entry("Bought %d x %s on the black market for %.0f cr."
		% [qty_to_buy, commodity.get("name", commodity_id), total_cost])

	refresh_all()


func _on_CloseButton_pressed() -> void:
	emit_signal("close_requested")


func _on_ship_changed() -> void:
	refresh_all()


func _on_system_changed(_new_system_id: String) -> void:
	refresh_all()
