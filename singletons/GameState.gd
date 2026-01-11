# res://singletons/GameState.gd
extends Node

var current_system_id: String = ""
var current_location_id: String = ""

var player_money: float = 10_000.0  # starter money

# travel cost tuning
var low_security_travel_cost: float = 50.0
var medium_security_travel_cost: float = 100.0
var high_security_travel_cost: float = 150.0

# Contracts offered in system
var active_contracts: Array = []  # array of contract dictionaries

# Ship data
var ship_name: String = "Starter Freighter"
var ship_engine_level: int = 1

# Very simple cargo model: { commodity_id: quantity }
var cargo: Dictionary = {}
var cargo_capacity_weight: float = 100.0  # tweak later
var cargo_hold_level: int = 1

const MAX_ENGINE_LEVEL: int = 5
const MAX_CARGO_HOLD_LEVEL: int = 5

var ship_engine_upgrade_base_cost: float = 2000.0
var cargo_hold_upgrade_base_cost: float = 1500.0
var cargo_hold_capacity_bonus_per_level: float = 25.0
var engine_discount_per_level: float = 0.1  # 10% travel cost discount per level

# freight documentation models
var freight_docs: Array = []          # array of freight doc dictionaries
var next_freight_doc_id: int = 1

signal system_changed(new_system_id: String)
signal location_changed(new_location_id: String)
signal ship_changed

func _ready() -> void:
	_ensure_starting_system()


func _ensure_starting_system() -> void:
	if current_system_id != "":
		return

	var ids: Array = Galaxy.get_all_system_ids()
	if ids.size() > 0:
		current_system_id = ids[0]

	_ensure_starting_location() #Ensure location next


func _ensure_starting_location() -> void:
	if current_location_id != "":
		return

	if current_system_id == "":
		return

	var loc_ids: Array = Galaxy.get_location_ids_for_system(current_system_id)
	if loc_ids.size() > 0:
		# Take the first location as default â€œdockâ€
		var loc_id: String = String(loc_ids[0])
		set_current_location(loc_id)


func travel_to_system(new_system_id: String) -> void:
	var system: Dictionary = Galaxy.get_system(new_system_id)
	if system.is_empty():
		push_warning("Unknown system.")
		Log.add_entry("Travel failed: unknown system.")
		return

	var cost := get_travel_cost(new_system_id)
	if cost > player_money:
		Log.add_entry("Not enough credits to travel (need %.0f)." % cost)
		push_warning("Not enough credits to travel.")
		return

	player_money -= cost
	current_system_id = new_system_id

	# Reset to an explicit "not docked" state on system arrival.
	current_location_id = ""

	Log.add_entry("Traveled to %s (-%.0f cr)" % [new_system_id, cost])
	emit_signal("system_changed", current_system_id)
	emit_signal("location_changed", current_location_id)

	print("Traveled to system: %s (cost %.0f, remaining %.0f)" % [new_system_id, cost, player_money])


func get_cargo_quantity(commodity_id: String) -> int:
	return int(cargo.get(commodity_id, 0))


func add_cargo(commodity_id: String, quantity: int) -> void:
	if quantity == 0:
		return

	var current_qty: int = get_cargo_quantity(commodity_id)
	cargo[commodity_id] = current_qty + quantity

	# Notify UI that ship state has changed (cargo counts, capacity usage, etc.)
	emit_signal("ship_changed")


func remove_cargo(commodity_id: String, quantity: int) -> void:
	if quantity <= 0:
		return

	var current_qty: int = get_cargo_quantity(commodity_id)
	var new_qty: int = max(0, current_qty - quantity)
	cargo[commodity_id] = new_qty

	emit_signal("ship_changed")


func get_total_cargo_weight() -> float:
	var total: float = 0.0
	for commodity_id in cargo.keys():
		var qty: int = int(cargo[commodity_id])
		if qty <= 0:
			continue

		var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
		if commodity.is_empty():
			continue

		var w: float = float(commodity.get("weight_per_unit", 1.0))
		total += w * float(qty)

	return total

func get_free_cargo_space() -> float:
	return cargo_capacity_weight - get_total_cargo_weight()

func get_travel_cost(dest_system_id: String) -> float:
	var system: Dictionary = Galaxy.get_system(dest_system_id)
	if system.is_empty():
		return 0.0

	var sec: String = system.get("security_level", "medium")

	var base_cost: float
	match sec:
		"low":
			base_cost = low_security_travel_cost
		"high":
			base_cost = high_security_travel_cost
		_:
			base_cost = medium_security_travel_cost

	# Engine discount: each level above 1 reduces cost by engine_discount_per_level
	# Example with 0.1:
	#   L1 -> 1.0x, L2 -> 0.9x, L3 -> 0.8x, ...
	var level: int = ship_engine_level
	var discount: float = engine_discount_per_level * float(level - 1)
	var multiplier: float = max(0.5, 1.0 - discount)  # floor at 50% of base

	return base_cost * multiplier


func set_current_location(loc_id: String) -> void:
	if loc_id == "":
		return

	var loc: Dictionary = Galaxy.get_location(loc_id)
	if loc.is_empty():
		push_warning("Unknown location: %s" % loc_id)
		return

	var sys_id: String = loc.get("system_id", "")
	if sys_id != "":
		current_system_id = sys_id

	current_location_id = loc_id
	Contracts.refresh_contracts_for_location(current_location_id, 4)
	Log.add_entry("Docked at %s." % loc.get("name", loc_id))
	emit_signal("location_changed", current_location_id)

	check_travel_contracts_at(current_system_id, current_location_id)


func get_current_location() -> Dictionary:
	if current_location_id == "":
		return {}
	return Galaxy.get_location(current_location_id)


func auto_travel(path: Array) -> void:
	# path is an array of system ids, including current and destination
	if path.size() < 2:
		return

	var start_index := path.find(current_system_id)
	if start_index == -1:
		start_index = 0  # best effort

	for i in range(start_index + 1, path.size()):
		var dest_id: String = str(path[i])
		if dest_id == current_system_id:
			continue

		var cost: float = get_travel_cost(dest_id)
		if cost > player_money:
			Log.add_entry("Auto-travel stopped: not enough credits to reach %s." % dest_id)
			break

		travel_to_system(dest_id)
		# travel_to_system already logs and charges

func add_contract(contract: Dictionary) -> void:
	active_contracts.append(contract.duplicate(true))
	Log.add_entry("Accepted contract to %s (%d jumps) for %.0f cr."
	  % [contract.get("destination_name", contract.get("destination", "?")),
		int(contract.get("jumps", 0)),
		float(contract.get("reward", 0.0))])

func accept_contract(contract: Dictionary) -> Dictionary:
	var result := {
		"ok": false,
		"error": "",
	}

	if contract.is_empty():
		result.error = "Invalid contract."
		Log.add_entry("Contract acceptance failed: invalid contract data.")
		return result

	var contract_id: String = String(contract.get("id", ""))
	if contract_id == "":
		result.error = "Invalid contract."
		Log.add_entry("Contract acceptance failed: missing contract id.")
		return result

	if current_location_id == "":
		result.error = "You must be docked to accept contracts."
		Log.add_entry("Contract acceptance failed: not docked.")
		return result

	if not _is_contract_at_location(contract):
		result.error = "You must be docked at the origin to accept this contract."
		Log.add_entry("Contract acceptance failed: wrong dock location.")
		return result

	for contract_variant in active_contracts:
		var active_contract: Dictionary = contract_variant
		if String(active_contract.get("id", "")) == contract_id:
			result.error = "Contract is already active."
			Log.add_entry("Contract acceptance failed: contract already active.")
			return result

	if get_docs_for_contract(contract_id).size() > 0:
		result.error = "Contract already has a freight document."
		Log.add_entry("Contract acceptance failed: freight doc already exists.")
		return result

	var required_space: int = _get_required_cargo_space(contract)
	if float(required_space) > get_free_cargo_space():
		result.error = "Not enough cargo space."
		Log.add_entry("Contract acceptance failed: insufficient cargo space.")
		return result

	add_contract(contract)
	create_freight_doc_for_contract(contract)
	load_contract_cargo(contract)

	result.ok = true
	return result


func check_travel_contracts_at(system_id: String, location_id: String) -> void:
	if active_contracts.is_empty():
		return

	var remaining: Array = []

	for contract_variant in active_contracts:
		var contract: Dictionary = contract_variant

		var dest_sys_id: String = String(contract.get("destination", ""))
		var dest_loc_id: String = String(contract.get("destination_location_id", ""))
		var contract_id: String = String(contract.get("id", ""))

		if dest_sys_id == "" or dest_loc_id == "":
			Log.add_entry("Contract completion failed: missing destination for %s." % contract_id)
			remaining.append(contract)
			continue

		if dest_sys_id != system_id or dest_loc_id != location_id:
			remaining.append(contract)
			continue

		# This contract is being completed at this dock
		var reward: float = float(contract.get("reward", 0.0))

		var dest_name: String = String(
			contract.get("destination_location_name",
				contract.get("destination_name",
					dest_sys_id))
		)

		player_money += reward

		# Remove its cargo from the hold
		clear_contract_cargo(contract)

		# Mark freight docs for this contract as completed
		_mark_docs_completed_for_contract(contract_id)


		Log.add_entry("Completed contract %s to %s, earned %.0f cr." % [contract_id, dest_name, reward])

	active_contracts = remaining


func abandon_contract(contract_id: String) -> void:
	if contract_id == "":
		return

	var remaining: Array = []
	for contract_variant in active_contracts:
		var c: Dictionary = contract_variant
		var id: String = c.get("id", "")
		if id == contract_id:
			var dest_name: String = c.get("destination_name", c.get("destination", "???"))
			Log.add_entry("Abandoned contract to %s." % dest_name)
			continue
		remaining.append(c)

	active_contracts = remaining

func save_game() -> void:
	var path := "user://savegame.dat"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing.")
		return

	var data := {
	"current_system_id": current_system_id,
	"current_location_id": current_location_id,
	"player_money": player_money,
	"cargo": cargo,
	"active_contracts": active_contracts,
	"galaxy_systems": Galaxy.systems,

	# ship-related
	"ship_name": ship_name,
	"ship_engine_level": ship_engine_level,
	"cargo_capacity_weight": cargo_capacity_weight,
	"cargo_hold_level": cargo_hold_level,

	# freight doc stuff
	"freight_docs": freight_docs,
	"next_freight_doc_id": next_freight_doc_id,
	}

	file.store_var(data, true)
	Log.add_entry("Game saved.")


func load_game() -> void:
	var path := "user://savegame.dat"
	if not FileAccess.file_exists(path):
		Log.add_entry("No save file found.")
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file for reading.")
		return

	var data: Dictionary = file.get_var(true)

	current_system_id = data.get("current_system_id", current_system_id)
	current_location_id = data.get("current_location_id", current_location_id)
	player_money = data.get("player_money", player_money)
	cargo = data.get("cargo", {})
	active_contracts = data.get("active_contracts", [])

	var saved_systems: Dictionary = data.get("galaxy_systems", {})
	if not saved_systems.is_empty():
		Galaxy.systems = saved_systems

	# restore ship fields
	ship_name = data.get("ship_name", ship_name)
	ship_engine_level = data.get("ship_engine_level", ship_engine_level)
	cargo_capacity_weight = data.get("cargo_capacity_weight", cargo_capacity_weight)
	cargo_hold_level = data.get("cargo_hold_level", cargo_hold_level)

	if current_system_id == "" or Galaxy.get_system(current_system_id).is_empty():
		_ensure_starting_system()

	#freight doc stuff
	freight_docs = data.get("freight_docs", [])
	next_freight_doc_id = int(data.get("next_freight_doc_id", next_freight_doc_id))

	# Ensure weâ€™re in a valid place
	if current_system_id == "" or Galaxy.get_system(current_system_id).is_empty():
		_ensure_starting_system()

	if current_location_id == "" or Galaxy.get_location(current_location_id).is_empty():
		_ensure_starting_location()

	Log.add_entry("Game loaded.")
	emit_signal("system_changed", current_system_id)
	emit_signal("location_changed", current_location_id)


func get_engine_upgrade_cost() -> float:
	if ship_engine_level >= MAX_ENGINE_LEVEL:
		return 0.0
	return ship_engine_upgrade_base_cost * float(ship_engine_level)


func get_cargo_hold_upgrade_cost() -> float:
	if cargo_hold_level >= MAX_CARGO_HOLD_LEVEL:
		return 0.0
	return cargo_hold_upgrade_base_cost * float(cargo_hold_level)

func upgrade_engine() -> void:
	if not Galaxy.system_has_drydock(current_system_id):
		Log.add_entry("No dry dock available at this system.")
		return

	if ship_engine_level >= MAX_ENGINE_LEVEL:
		Log.add_entry("Engine is already at maximum level.")
		return

	var cost: float = get_engine_upgrade_cost()
	if player_money < cost:
		Log.add_entry("Not enough credits to upgrade engine (need %.0f cr)." % cost)
		return

	player_money -= cost
	ship_engine_level += 1
	Log.add_entry("Upgraded engine to level %d (-%.0f cr)." % [ship_engine_level, cost])

	emit_signal("ship_changed")


func upgrade_cargo_hold() -> void:
	if not Galaxy.system_has_drydock(current_system_id):
		Log.add_entry("No dry dock available at this system.")
		return

	if cargo_hold_level >= MAX_CARGO_HOLD_LEVEL:
		Log.add_entry("Cargo hold is already at maximum level.")
		return

	var cost: float = get_cargo_hold_upgrade_cost()
	if player_money < cost:
		Log.add_entry("Not enough credits to upgrade cargo hold (need %.0f cr)." % cost)
		return

	player_money -= cost
	cargo_hold_level += 1
	cargo_capacity_weight += cargo_hold_capacity_bonus_per_level

	Log.add_entry("Upgraded cargo hold to level %d (+%.1f capacity, -%.0f cr)."
		% [cargo_hold_level, cargo_hold_capacity_bonus_per_level, cost])

	emit_signal("ship_changed")

func create_freight_doc_for_contract(contract: Dictionary) -> Dictionary:
	var doc_id: String = "FDOC-%04d" % next_freight_doc_id
	next_freight_doc_id += 1

	var origin_id: String = contract.get("origin", current_system_id)
	var dest_id: String = contract.get("destination", "")

	var cargo_lines: Array = []

	# If the contract already has a cargo_lines array, copy it
	if contract.has("cargo_lines"):
		for line_variant in contract["cargo_lines"]:
			var line: Dictionary = line_variant
			var commodity_id: String = str(line.get("commodity_id", ""))
			var qty: int = int(line.get("declared_qty", 0))
			var cargo_space: int = int(line.get("cargo_space", qty))
			if commodity_id != "" and qty > 0:
				cargo_lines.append({
					"commodity_id": commodity_id,
					"declared_qty": qty,
					"cargo_space": cargo_space,
				})
	# Otherwise, fall back to simple single-line cargo
	elif contract.has("commodity_id") and contract.has("quantity"):
		var commodity_id: String = str(contract.get("commodity_id", ""))
		var qty: int = int(contract.get("quantity", 0))
		if commodity_id != "" and qty > 0:
			cargo_lines.append({
				"commodity_id": commodity_id,
				"declared_qty": qty,
				"cargo_space": qty,
			})

	var doc := {
		"doc_id": doc_id,
		"contract_id": contract.get("id", ""),
		"status": "active",

		"origin_system_id": origin_id,
		"destination_system_id": dest_id,

		"cargo_lines": cargo_lines,
	}

	print("Creating freight doc from contract: ", contract)
	print("Freight doc cargo_lines: ", cargo_lines)

	freight_docs.append(doc)

	print("All freight docs now: ", freight_docs)
	#Log.add_entry("DEBUG: Created freight doc %s with %d cargo_lines."
	#% [doc_id, cargo_lines.size()])

	Log.add_entry("Created freight document %s for contract to %s." % [doc_id, dest_id])
	return doc


func get_docs_for_contract(contract_id: String) -> Array:
	var result: Array = []
	for doc_variant in freight_docs:
		var doc: Dictionary = doc_variant
		if doc.get("contract_id", "") == contract_id:
			result.append(doc)
	return result


func get_docs_for_destination(system_id: String) -> Array:
	var result: Array = []
	for doc_variant in freight_docs:
		var doc: Dictionary = doc_variant
		if doc.get("destination_system_id", "") == system_id and doc.get("status", "active") == "active":
			result.append(doc)
	return result

func load_contract_cargo(contract: Dictionary) -> void:
	# Use same logic as create_freight_doc_for_contract
	if contract.has("cargo_lines"):
		for line_variant in contract["cargo_lines"]:
			var line: Dictionary = line_variant
			var commodity_id: String = str(line.get("commodity_id", ""))
			var qty: int = int(line.get("declared_qty", 0))
			if commodity_id != "" and qty > 0:
				add_cargo(commodity_id, qty)
	elif contract.has("commodity_id") and contract.has("quantity"):
		var commodity_id: String = str(contract.get("commodity_id", ""))
		var qty: int = int(contract.get("quantity", 0))
		if commodity_id != "" and qty > 0:
			add_cargo(commodity_id, qty)


func clear_contract_cargo(contract: Dictionary) -> void:
	# Uses the same cargo_lines structure as the freight doc / contract
	if contract.has("cargo_lines"):
		for line_variant in contract["cargo_lines"]:
			var line: Dictionary = line_variant
			var cid: String = str(line.get("commodity_id", ""))
			var qty: int = int(line.get("declared_qty", 0))
			if cid != "" and qty > 0:
				# Remove up to the declared amount; if the player sold some,
				# this will just clamp at 0.
				remove_cargo(cid, qty)

func _is_contract_at_location(contract: Dictionary) -> bool:
	var origin_loc_id: String = String(contract.get("origin_location_id", ""))
	if origin_loc_id != "":
		return origin_loc_id == current_location_id

	var origin_sys_id: String = String(contract.get("origin", ""))
	if origin_sys_id == "":
		return false
	return origin_sys_id == current_system_id

func _get_required_cargo_space(contract: Dictionary) -> int:
	var total := 0
	if contract.has("cargo_lines"):
		for line_variant in contract["cargo_lines"]:
			var line: Dictionary = line_variant
			var cargo_space: int = int(line.get("cargo_space", line.get("declared_qty", 0)))
			if cargo_space > 0:
				total += cargo_space
	elif contract.has("commodity_id") and contract.has("quantity"):
		total = int(contract.get("quantity", 0))
	return total


func _mark_docs_completed_for_contract(contract_id: String) -> void:
	if contract_id == "":
		return

	for i in range(freight_docs.size()):
		var doc: Dictionary = freight_docs[i]
		if doc.get("contract_id", "") == contract_id:
			doc["status"] = "completed"
			freight_docs[i] = doc

