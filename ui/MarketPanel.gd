# res://ui/MarketPanel.gd
extends Control

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var system_label: Label = $MarginContainer/VBoxContainer/SystemLabel
@onready var commodities_list: ItemList = $MarginContainer/VBoxContainer/CommoditiesList
@onready var qty_spin: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/QtySpin
@onready var buy_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/BuyButton
@onready var sell_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/SellButton
@onready var player_money_label: Label = $MarginContainer/VBoxContainer/PlayerMoneyLabel
@onready var cargo_weight_label: Label = $MarginContainer/VBoxContainer/CargoWeightLabel
@onready var cargo_list: ItemList = $MarginContainer/VBoxContainer/CargoList
@onready var job_board_button: Button = $MarginContainer/VBoxContainer/JobBoardButton
@onready var contracts_button: Button = $MarginContainer/VBoxContainer/ContractsButton
@onready var docs_button: Button = $MarginContainer/VBoxContainer/DocsButton
@onready var ship_button: Button = $MarginContainer/VBoxContainer/ShipButton

# index in ItemList -> commodity entry { id, name, price }
var entries: Array = []

var price_by_commodity: Dictionary = {}  # commodity_id -> price


func _ready() -> void:
	title_label.text = "Market"
	qty_spin.min_value = 1
	qty_spin.max_value = 999
	qty_spin.step = 1

	refresh_all()

	GameState.ship_changed.connect(_on_ship_changed)

	buy_button.pressed.connect(_on_BuyButton_pressed)
	sell_button.pressed.connect(_on_SellButton_pressed)
	job_board_button.pressed.connect(_on_JobBoardButton_pressed)
	contracts_button.pressed.connect(_on_ContractsButton_pressed)
	docs_button.pressed.connect(_on_DocsButton_pressed)
	ship_button.pressed.connect(_on_ShipButton_pressed)
	commodities_list.item_selected.connect(_on_CommoditiesList_item_selected)


func refresh_all() -> void:
	print("MarketPanel.refresh_all for system: ", GameState.current_system_id)
	_refresh_system_label()
	_refresh_player_info()
	_refresh_market_list()
	_refresh_cargo_list()


func _refresh_system_label() -> void:
	var sys_id: String = GameState.current_system_id
	var system: Dictionary = Galaxy.get_system(sys_id)
	if system.is_empty():
		system_label.text = "System: (none)"
		return

	var name: String = system.get("name", sys_id)
	var stype: String = system.get("system_type", "unknown")
	system_label.text = "System: %s (%s)" % [name, stype]


func _refresh_player_info() -> void:
	var money: float = GameState.player_money
	player_money_label.text = "Credits: %.0f" % money

	var weight: float = GameState.get_total_cargo_weight()
	var cap: float = GameState.cargo_capacity_weight
	cargo_weight_label.text = "Cargo: %.1f / %.1f" % [weight, cap]


func _refresh_market_list() -> void:
	entries.clear()
	commodities_list.clear()
	price_by_commodity.clear()   # 🔹 NEW

	var sys_id: String = GameState.current_system_id
	if sys_id == "":
		return

	var price_list: Array = Economy.get_price_list_for_system(sys_id)
	# Sort by name
	price_list.sort_custom(_sort_price_entries_by_name)

	var index: int = 0
	for entry_variant in price_list:
		var entry: Dictionary = entry_variant

		var name: String = entry.get("name", "???")
		var price: float = float(entry.get("price", 0.0))
		var id: String = entry.get("id", "")
		var line: String = "%s  -  %.0f cr" % [name, price]

		# Add to UI list
		var i := commodities_list.add_item(line)

		# Store UI entry for BUY button
		if entries.size() <= i:
			entries.resize(i + 1)
		entries[i] = {
			"id": id,
			"name": name,
			"price": price
		}

		# tore price for SELL button to use later
		price_by_commodity[id] = price

		index += 1


func _refresh_cargo_list() -> void:
	cargo_list.clear()

	for commodity_id in GameState.cargo.keys():
		var qty: int = GameState.get_cargo_quantity(commodity_id)
		if qty <= 0:
			continue

		var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
		var name: String = commodity.get("name", commodity_id)

		var label := "%s x %d" % [name, qty]
		var idx := cargo_list.add_item(label)

		cargo_list.set_item_metadata(idx, commodity_id)



static func _sort_price_entries_by_name(a: Dictionary, b: Dictionary) -> bool:
	var an: String = a.get("name", "")
	var bn: String = b.get("name", "")
	return an < bn


func _on_CommoditiesList_item_selected(index: int) -> void:
	# OPTIONAL: we could show more info here later, but for now we just ensure qty is sane
	if index < 0 or index >= entries.size():
		return
	if qty_spin.value < 1:
		qty_spin.value = 1


func _on_BuyButton_pressed() -> void:
	var selected: PackedInt32Array = commodities_list.get_selected_items()
	if selected.size() == 0:
		return
	var idx: int = selected[0]
	if idx < 0 or idx >= entries.size():
		return

	var entry: Dictionary = entries[idx]
	var commodity_id: String = entry.get("id", "")
	var price: float = float(entry.get("price", 0.0))
	var qty: int = int(qty_spin.value)
	if qty <= 0:
		return

	var total_cost: float = price * float(qty)
	if total_cost > GameState.player_money:
		push_warning("Not enough credits to buy.")
		return

	# check cargo capacity
	var added_weight: float = _get_commodity_weight(commodity_id) * float(qty)
	var current_weight: float = GameState.get_total_cargo_weight()
	if current_weight + added_weight > GameState.cargo_capacity_weight:
		push_warning("Not enough cargo capacity.")
		return

	# perform purchase
	GameState.player_money -= total_cost
	GameState.add_cargo(commodity_id, qty)

	Log.add("Bought %d x %s @ %.0f ea" % [qty, entry["name"], price])

	_refresh_player_info()
	_refresh_cargo_list()


func _on_SellButton_pressed() -> void:
	# 1) Make sure a cargo item is selected
	var selected := cargo_list.get_selected_items()
	if selected.size() == 0:
		Log.add("No cargo selected to sell.")
		return

	var idx: int = selected[0]

	# metadata is always a commodity_id string
	var meta: String = cargo_list.get_item_metadata(idx)
	if meta == "":
		Log.add("Selected cargo has no commodity metadata.")
		return

	if meta == null:
		Log.add("Internal error: cargo item missing metadata.")
		return

	var commodity_id: String = meta

	# 2) Check how much of this cargo we actually have
	var have_qty: int = GameState.get_cargo_quantity(commodity_id)
	if have_qty <= 0:
		Log.add("You have no units of that cargo to sell.")
		return

	# 3) Determine how much the player wants to sell
	var qty_to_sell: int = int(qty_spin.value)
	if qty_to_sell <= 0:
		return

	# Clamp to what we actually have
	if qty_to_sell > have_qty:
		qty_to_sell = have_qty

	# 4) Get the current market price for this commodity in this system
	if not price_by_commodity.has(commodity_id):
		Log.add("No market price available for this commodity here.")
		return

	var price: float = float(price_by_commodity[commodity_id])

	# 5) Apply transaction: add money, remove cargo
	var revenue: float = price * float(qty_to_sell)
	GameState.player_money += revenue
	GameState.remove_cargo(commodity_id, qty_to_sell)

	Log.add("Sold %d x %s for %.0f cr." %
		[qty_to_sell, commodity_id, revenue])

	# 6) Refresh UI so money, cargo list, and weights update
	refresh_all()



func _get_commodity_weight(commodity_id: String) -> float:
	var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
	if commodity.is_empty():
		return 1.0
	return float(commodity.get("weight_per_unit", 1.0))

func _on_JobBoardButton_pressed() -> void:
	var scene: PackedScene = load("res://scenes/JobBoardPanel.tscn")
	if scene == null:
		push_error("Failed to load JobBoardPanel.tscn")
		return
		
	var panel: Control = scene.instantiate()
	# add to the root so it covers everything
	var root: Node = get_tree().current_scene
	
	if root == null:
		root = get_tree().root
	root.add_child(panel)
	
	if panel is Control:
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		panel.set_offsets_preset(Control.PRESET_FULL_RECT)


func _on_ContractsButton_pressed() -> void:
	var scene: PackedScene = load("res://scenes/ContractsPanel.tscn")
	if scene == null:
		push_error("Failed to load ContractsPanel.tscn")
		return
		
	var panel: Control = scene.instantiate()

	var root: Node = get_tree().current_scene
	if root == null:
		root = get_tree().root
	root.add_child(panel)

	if panel is Control:
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		panel.set_offsets_preset(Control.PRESET_FULL_RECT)

func _on_ShipButton_pressed() -> void:
	var scene: PackedScene = load("res://scenes/ShipPanel.tscn")
	if scene == null:
		push_error("Failed to load ShipPanel.tscn")
		return

	var panel: Control = scene.instantiate()

	var root: Node = get_tree().current_scene
	if root == null:
		root = get_tree().root
	root.add_child(panel)

	if panel is Control:
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		panel.set_offsets_preset(Control.PRESET_FULL_RECT)

func _on_ship_changed() -> void:
	refresh_all()

func _on_DocsButton_pressed() -> void:
	var scene: PackedScene = load("res://scenes/FreightDocsPanel.tscn")
	if scene == null:
		push_error("Failed to load FreightDocsPanel.tscn")
		return

	var panel: Control = scene.instantiate()

	# Add to the root so it overlays the whole UI
	var root: Node = get_tree().current_scene
	if root == null:
		root = get_tree().root
	root.add_child(panel)

	if panel is Control:
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		panel.set_offsets_preset(Control.PRESET_FULL_RECT)
