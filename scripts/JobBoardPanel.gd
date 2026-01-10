extends Control

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var info_label: Label = $PanelContainer/MarginContainer/VBoxContainer/InfoLabel
@onready var contracts_list: ItemList = $PanelContainer/MarginContainer/VBoxContainer/ContractsList
@onready var accept_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/AcceptButton
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CloseButton
@onready var hint_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HintLabel

var contracts: Array = []  # available contracts for this location


func _ready() -> void:
	title_label.text = "Job Board"

	_build_contracts_for_current_location()
	_refresh_list()

	contracts_list.item_selected.connect(_on_contract_selected)
	accept_button.pressed.connect(_on_accept_pressed)
	close_button.pressed.connect(_on_close_pressed)


func _build_contracts_for_current_location() -> void:
	var loc_id: String = GameState.current_location_id

	# Safety check: must have a valid location
	if loc_id == "":
		contracts = []
		info_label.text = "No location selected."
		return

	contracts = Contracts.get_contracts_for_location(loc_id)

	# UI feedback
	if contracts.is_empty():
		info_label.text = "No contracts available here."
	else:
		var loc: Dictionary = Galaxy.get_location(loc_id)
		var loc_name: String = String(loc.get("name", loc_id))
		info_label.text = "Contracts available at %s." % loc_name



func _refresh_list() -> void:
	contracts_list.clear()

	var count: int = contracts.size()
	for i in range(count):
		var c: Dictionary = contracts[i]

		# --- Destination system (fallback layer) ---
		var dest_sys_id: String = String(c.get("destination", ""))
		var dest_sys: Dictionary = Galaxy.get_system(dest_sys_id)
		var dest_sys_name: String = String(dest_sys.get("name", dest_sys_id))

		# --- Origin: prefer location name if present ---
		var origin_loc_name: String = String(
			c.get("origin_location_name",
				c.get("origin_location_id", ""))
		)
		if origin_loc_name == "":
			var origin_sys_id: String = String(c.get("origin", ""))
			var origin_sys: Dictionary = Galaxy.get_system(origin_sys_id)
			origin_loc_name = String(origin_sys.get("name", origin_sys_id))

		# --- Destination: prefer location name, fall back to system name ---
		var dest_loc_name: String = String(
			c.get("destination_location_name",
				c.get("destination_location_id", dest_sys_name))
		)

		var jumps: int = int(c.get("jumps", 0))
		var reward: float = float(c.get("reward", 0.0))

		# Example:
		# Agriport Harvest-00-01 → Refinery Forge-03-02  -  3 jumps, 600 cr
		var line: String = "%s → %s  -  %d jumps, %.0f cr" % [
			origin_loc_name,
			dest_loc_name,
			jumps,
			reward
		]

		contracts_list.add_item(line)
		contracts_list.set_item_metadata(i, i)  # store index into contracts array

	# Enable/disable accept button
	accept_button.disabled = (count == 0)


func _on_contract_selected(index: int) -> void:
	if index < 0 or index >= contracts.size():
		info_label.text = "Select a contract to see details."
		return

	var c: Dictionary = contracts[index]

	# Destination system (for extra info)
	var dest_sys_id: String = String(c.get("destination", ""))
	var dest_sys: Dictionary = Galaxy.get_system(dest_sys_id)
	var dest_sys_name: String = String(dest_sys.get("name", dest_sys_id))

	# Origin: prefer location name if present
	var origin_loc_name: String = String(
		c.get("origin_location_name",
			c.get("origin_location_id", ""))
	)
	if origin_loc_name == "":
		var origin_sys_id: String = String(c.get("origin", ""))
		var origin_sys: Dictionary = Galaxy.get_system(origin_sys_id)
		origin_loc_name = String(origin_sys.get("name", origin_sys_id))

	# Destination: prefer location name, fall back to system name
	var dest_loc_name: String = String(
		c.get("destination_location_name",
			c.get("destination_location_id", dest_sys_name))
	)

	var jumps: int = int(c.get("jumps", 0))
	var reward: float = float(c.get("reward", 0.0))

	info_label.text = "%s → %s (%s)  |  %d jumps, reward %.0f cr." % [
		origin_loc_name,
		dest_loc_name,
		dest_sys_id,
		jumps,
		reward
	]


func _on_accept_pressed() -> void:
	var selected: PackedInt32Array = contracts_list.get_selected_items()
	if selected.size() == 0:
		info_label.text = "No contract selected."
		return

	var idx: int = selected[0]
	if idx < 0 or idx >= contracts.size():
		info_label.text = "Invalid contract."
		return

	var contract: Dictionary = contracts[idx]
	var contract_id: String = String(contract.get("id", ""))
	if contract_id == "":
		info_label.text = "Invalid contract."
		return

	print("Accepting contract: ", contract)
	#prints to game log for added player info
	#Log.add_entry("DEBUG: Accepting contract %s with %d cargo_lines." 
    #% [contract.get("id", "?"), contract.get("cargo_lines", []).size()])

	var result: Dictionary = Contracts.accept_contract(contract_id)
	if not bool(result.get("ok", false)):
		info_label.text = String(result.get("error", "Unable to accept contract."))
		return

	# remove it from local list so you can't take it twice
	contracts.remove_at(idx)
	_refresh_list()
	info_label.text = "Contract accepted."


func _on_close_pressed() -> void:
	queue_free()

