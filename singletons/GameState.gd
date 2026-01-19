# res://singletons/GameState.gd
extends Node

var current_system_id: String = ""
var current_location_id: String = ""
var time_tick: int = 0

var player_money: float = 10_000.0  # starter money

# travel cost tuning
var low_security_travel_cost: float = 50.0
var medium_security_travel_cost: float = 100.0
var high_security_travel_cost: float = 150.0

# Contracts offered in system
var active_contracts: Array = []  # array of contract dictionaries
var abandoned_contracts: Dictionary = {}  # contract_id -> true (runtime only)

# Ship data
var ship_name: String = "Starter Freighter"
var ship_engine_level: int = 1

# Very simple cargo model: { commodity_id: quantity }
var cargo: Dictionary = {}
var cargo_capacity_weight: float = 100.0  # tweak later
var cargo_hold_level: int = 1

const MAX_ENGINE_LEVEL: int = 5
const MAX_CARGO_HOLD_LEVEL: int = 5
const INTER_SYSTEM_TRAVEL_TICKS: int = 2
const INTRA_SYSTEM_TRAVEL_TICKS: int = 5

var ship_engine_upgrade_base_cost: float = 2000.0
var cargo_hold_upgrade_base_cost: float = 1500.0
var cargo_hold_capacity_bonus_per_level: float = 25.0
var engine_discount_per_level: float = 0.1  # 10% travel cost discount per level

# freight documentation models
var freight_docs: Array = []          # array of freight doc dictionaries
var next_freight_doc_id: int = 1
var next_freight_doc_event_id: int = 1
var next_customs_inspection_id: int = 1
var cargo_lines: Array = []           # array of cargo line dictionaries
var next_cargo_line_id: int = 1
var _has_initialized_location: bool = false

const MARKET_KIND_LEGAL: String = "legal"
const MARKET_KIND_BLACK_MARKET: String = "black_market"
const EVIDENCE_FLAG_DECLARED_QTY_MODIFIED: String = "declared_quantity_modified"
const EVIDENCE_FLAG_CONTAINER_META_MODIFIED: String = "container_meta_modified"
const EVIDENCE_FLAG_DOCUMENT_DESTROYED: String = "document_destroyed"

signal system_changed(new_system_id: String)
signal location_changed(new_location_id: String)
signal ship_changed
signal time_advanced(new_tick: int, reason: String)
# Emitted after a freight document is successfully changed or destroyed.
signal freight_doc_changed(doc_id: String, change_kind: String)
signal customs_inspection_completed(report: Dictionary)

const CUSTOMS_AUTHENTICITY_THRESHOLD: int = 80

func _ready() -> void:
	_ensure_starting_system()


func advance_time(reason: String) -> void:
	time_tick += 1
	var message: String = reason.strip_edges()
	if message == "":
		message = "Time advanced"
	if message.ends_with("."):
		message = message.substr(0, message.length() - 1)
	Log.add_entry("%s. +1 tick." % message)
	emit_signal("time_advanced", time_tick, reason)


func _advance_time_ticks(ticks: int, reason: String) -> void:
	if ticks <= 0:
		return

	for _i in range(ticks):
		advance_time(reason)


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
		Log.add_entry("Travel failed: unknown system.", "SHIP")
		return

	var cost := get_travel_cost(new_system_id)
	if cost > player_money:
		Log.add_entry("Not enough credits to travel (need %.0f)." % cost, "SHIP")
		push_warning("Not enough credits to travel.")
		return

	player_money -= cost
	current_system_id = new_system_id

	# Reset to an explicit "not docked" state on system arrival.
	current_location_id = ""

	var system_name: String = String(system.get("name", new_system_id))
	_advance_time_ticks(
		INTER_SYSTEM_TRAVEL_TICKS,
		"Inter-system travel to %s" % system_name
	)

	Log.add_entry("Traveled to %s. +%d ticks." % [system_name, INTER_SYSTEM_TRAVEL_TICKS], "SHIP")
	emit_signal("system_changed", current_system_id)
	emit_signal("location_changed", current_location_id)


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

	var previous_system_id: String = current_system_id
	var previous_location_id: String = current_location_id

	var loc: Dictionary = Galaxy.get_location(loc_id)
	if loc.is_empty():
		push_warning("Unknown location: %s" % loc_id)
		return

	var sys_id: String = loc.get("system_id", "")
	if sys_id != "":
		current_system_id = sys_id

	var loc_name: String = String(loc.get("name", loc_id))
	if _has_initialized_location and sys_id != "" and sys_id == previous_system_id:
		if loc_id != previous_location_id:
			_advance_time_ticks(
				INTRA_SYSTEM_TRAVEL_TICKS,
				"In-system travel to %s" % loc_name
			)

	_has_initialized_location = true
	current_location_id = loc_id
	Contracts.refresh_contracts_for_location(current_location_id, 4)
	Log.add_entry("Docked at %s." % loc_name, "SHIP")
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
			Log.add_entry("Auto-travel stopped: not enough credits to reach %s." % dest_id, "SHIP")
			break

		travel_to_system(dest_id)
		# travel_to_system already logs and charges

func _get_sorted_location_ids_for_system(system_id: String) -> Array:
	var ids: Array = Galaxy.get_location_ids_for_system(system_id)
	var result: Array = []
	for id_variant in ids:
		result.append(String(id_variant))
	result.sort()
	return result

func _pick_deterministic_location_id(system_id: String, seed: String) -> String:
	var ids: Array = _get_sorted_location_ids_for_system(system_id)
	if ids.is_empty():
		return ""

	var hash_value: int
	if seed == "":
		hash_value = system_id.hash()
	else:
		hash_value = seed.hash()

	if hash_value < 0:
		hash_value = -hash_value
	var index: int = hash_value % ids.size()
	return String(ids[index])

func _ensure_contract_destination_location(contract: Dictionary) -> Dictionary:
	if contract.is_empty():
		return contract

	var dest_loc_id: String = String(contract.get("destination_location_id", ""))
	var dest_loc_name: String = String(contract.get("destination_location_name", ""))
	if dest_loc_id != "":
		if dest_loc_name == "":
			var dest_loc: Dictionary = Galaxy.get_location(dest_loc_id)
			if not dest_loc.is_empty():
				contract["destination_location_name"] = String(dest_loc.get("name", dest_loc_id))
		return contract

	var dest_sys_id: String = String(contract.get("destination", ""))
	if dest_sys_id == "":
		Log.add_entry("Contract repair skipped: missing destination system for %s."
			% String(contract.get("id", "?")))
		return contract

	var repaired_loc_id: String = _pick_deterministic_location_id(
		dest_sys_id,
		String(contract.get("id", ""))
	)
	if repaired_loc_id == "":
		Log.add_entry("Contract repair failed: no destinations in %s." % dest_sys_id)
		return contract

	var repaired_loc: Dictionary = Galaxy.get_location(repaired_loc_id)
	if repaired_loc.is_empty():
		Log.add_entry("Contract repair failed: unknown destination location.")
		return contract

	contract["destination_location_id"] = repaired_loc_id
	contract["destination_location_name"] = String(repaired_loc.get("name", repaired_loc_id))

	if String(contract.get("destination_name", "")) == "":
		var dest_system: Dictionary = Galaxy.get_system(dest_sys_id)
		if not dest_system.is_empty():
			contract["destination_name"] = String(dest_system.get("name", dest_sys_id))

	return contract

func add_contract(contract: Dictionary) -> void:
	var normalized: Dictionary = _ensure_contract_destination_location(contract.duplicate(true))
	active_contracts.append(normalized)
	Log.add_entry("Accepted contract to %s (%d jumps) for %.0f cr."
	  % [normalized.get("destination_name", normalized.get("destination", "?")),
		int(normalized.get("jumps", 0)),
		float(normalized.get("reward", 0.0))])

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

func _has_active_contract_id(contract_id: String) -> bool:
	if contract_id == "":
		return false
	for contract_variant in active_contracts:
		var c: Dictionary = contract_variant
		if String(c.get("id", "")) == contract_id:
			return true
	return false

func is_contract_active(contract_id: String) -> bool:
	return _has_active_contract_id(contract_id)

func _is_contract_abandoned(contract_id: String) -> bool:
	if contract_id == "":
		return false
	return abandoned_contracts.has(contract_id)

func is_contract_abandoned(contract_id: String) -> bool:
	if contract_id == "":
		return false
	return abandoned_contracts.has(contract_id)

func _should_skip_contract_for_obligations(contract: Dictionary) -> bool:
	var contract_id: String = String(contract.get("id", ""))
	return contract_id != "" and is_contract_abandoned(contract_id)

func get_active_contract_destination_system_ids() -> Array:
	var dest_ids: Array = []
	for contract_variant in active_contracts:
		var c: Dictionary = contract_variant
		if _should_skip_contract_for_obligations(c):
			continue
		var dest_id: String = String(c.get("destination", ""))
		if dest_id == "":
			continue
		if not dest_ids.has(dest_id):
			dest_ids.append(dest_id)
	return dest_ids

func count_active_contract_destinations_to_system(sys_id: String) -> int:
	var count: int = 0
	for contract_variant in active_contracts:
		var c: Dictionary = contract_variant
		if _should_skip_contract_for_obligations(c):
			continue
		var dest_id: String = String(c.get("destination", ""))
		if dest_id == sys_id:
			count += 1
	return count

func count_active_contract_destinations_to_location(loc_id: String) -> int:
	var count: int = 0
	for contract_variant in active_contracts:
		var c: Dictionary = contract_variant
		if _should_skip_contract_for_obligations(c):
			continue
		var dest_loc_id: String = String(c.get("destination_location_id", ""))
		if dest_loc_id == loc_id:
			count += 1
	return count


func _mark_contract_abandoned(contract_id: String) -> bool:
	if contract_id == "":
		return false
	if abandoned_contracts.has(contract_id):
		return false
	abandoned_contracts[contract_id] = true
	Log.add_entry("Contract %s abandoned: paperwork destroyed." % contract_id)
	return true

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
	"cargo_lines": cargo_lines,
	"next_cargo_line_id": next_cargo_line_id,
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
	var repaired_contracts: Array = []
	for contract_variant in active_contracts:
		var contract: Dictionary = contract_variant
		repaired_contracts.append(_ensure_contract_destination_location(contract))
	active_contracts = repaired_contracts

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
	cargo_lines = data.get("cargo_lines", [])
	next_cargo_line_id = int(data.get("next_cargo_line_id", next_cargo_line_id))
	for i in range(freight_docs.size()):
		var doc: Dictionary = freight_docs[i]
		if String(doc.get("doc_type", "")) == "":
			doc["doc_type"] = "contract"
			freight_docs[i] = doc

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
	var origin_location_id: String = str(contract.get("origin_location_id", current_location_id))
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
		"doc_type": "contract",
		"contract_id": contract.get("id", ""),
		"status": "active",

		"origin_system_id": origin_id,
		"destination_system_id": dest_id,
		"container_meta": _build_container_meta(
			doc_id,
			true,
			"contract",
			origin_id,
			origin_location_id
		),

		"cargo_lines": cargo_lines,
	}


	freight_docs.append(doc)

	#Log.add_entry("DEBUG: Created freight doc %s with %d cargo_lines."
	#% [doc_id, cargo_lines.size()])

	Log.add_entry("Created freight document %s for contract to %s." % [doc_id, dest_id])
	return doc


func _next_freight_doc_event_id() -> String:
	var event_id: String = "FDOC-EV-%04d" % next_freight_doc_event_id
	next_freight_doc_event_id += 1
	return event_id


func _build_container_meta(
	doc_id: String,
	sealed: bool,
	source: String,
	system_id: String,
	location_id: String
) -> Dictionary:
	var seal_state: String = "sealed" if sealed else "unsealed"
	var seal_id: String = ""
	if sealed:
		seal_id = "SEAL-%s" % doc_id

	return {
		"container_id": "CONT-%s" % doc_id,
		"seal_id": seal_id,
		"seal_state": seal_state,
		"notes": "",
		"packed_tick": time_tick,
		"provenance": {
			"source": source,
			"system_id": system_id,
			"location_id": location_id,
		},
	}


func _find_freight_doc_index(doc_id: String) -> int:
	if doc_id == "":
		return -1
	for i in range(freight_docs.size()):
		var doc: Dictionary = freight_docs[i]
		if String(doc.get("doc_id", "")) == doc_id:
			return i
	return -1


func _sum_declared_qty_from_lines(lines: Array) -> int:
	var total := 0
	for line_variant in lines:
		if not (line_variant is Dictionary):
			continue
		var line: Dictionary = line_variant
		total += int(line.get("declared_qty", 0))
	return total


func _normalize_freight_doc_runtime(doc: Dictionary) -> Dictionary:
	if not doc.has("declared_quantity"):
		if doc.has("quantity"):
			doc["declared_quantity"] = int(doc.get("quantity", 0))
		elif doc.has("cargo_lines"):
			doc["declared_quantity"] = _sum_declared_qty_from_lines(doc.get("cargo_lines", []))
		else:
			doc["declared_quantity"] = 0

	if not doc.has("container_meta") or not (doc.get("container_meta") is Dictionary):
		doc["container_meta"] = {}

	if not doc.has("is_destroyed"):
		doc["is_destroyed"] = false

	if not doc.has("edit_events") or not (doc.get("edit_events") is Array):
		doc["edit_events"] = []

	return doc


func _append_freight_doc_event(
	doc: Dictionary,
	event_type: String,
	before: Dictionary,
	after: Dictionary,
	tool_used: String,
	quality: int
) -> Dictionary:
	var events: Array = doc.get("edit_events", [])
	if not (events is Array):
		events = []

	events.append({
		"event_id": _next_freight_doc_event_id(),
		"event_type": event_type,
		"tick": time_tick,
		"source": "captains_quarters",
		"before": before,
		"after": after,
		"tool_used": tool_used,
		"quality": quality,
	})
	doc["edit_events"] = events
	return doc


func get_freight_doc(doc_id: String) -> Dictionary:
	var idx := _find_freight_doc_index(doc_id)
	if idx == -1:
		return {}
	var doc: Dictionary = freight_docs[idx]
	doc = _normalize_freight_doc_runtime(doc)
	freight_docs[idx] = doc
	return doc.duplicate(true)


func get_doc_evidence_flags(doc_id: String) -> Array:
	var doc: Dictionary = get_freight_doc(doc_id)
	if doc.is_empty():
		return []
	return _derive_doc_evidence_flags(doc)


func get_doc_authenticity(doc_id: String) -> int:
	var doc: Dictionary = get_freight_doc(doc_id)
	if doc.is_empty():
		return 0

	var flags: Array = _derive_doc_evidence_flags(doc)
	var score := 100
	if flags.has(EVIDENCE_FLAG_DECLARED_QTY_MODIFIED):
		score -= 20
	if flags.has(EVIDENCE_FLAG_CONTAINER_META_MODIFIED):
		score -= 20
	if flags.has(EVIDENCE_FLAG_DOCUMENT_DESTROYED):
		score = 0
	return clamp(score, 0, 100)


func _derive_doc_evidence_flags(doc: Dictionary) -> Array:
	var flags: Array = []
	var events_variant = doc.get("edit_events", [])
	if events_variant is Array:
		for event_variant in events_variant:
			if not (event_variant is Dictionary):
				continue
			var event: Dictionary = event_variant
			var event_type: String = str(event.get("event_type", ""))
			if event_type == "edit_declared_qty":
				if not flags.has(EVIDENCE_FLAG_DECLARED_QTY_MODIFIED):
					flags.append(EVIDENCE_FLAG_DECLARED_QTY_MODIFIED)
			elif event_type == "edit_meta":
				if not flags.has(EVIDENCE_FLAG_CONTAINER_META_MODIFIED):
					flags.append(EVIDENCE_FLAG_CONTAINER_META_MODIFIED)

	if bool(doc.get("is_destroyed", false)):
		if not flags.has(EVIDENCE_FLAG_DOCUMENT_DESTROYED):
			flags.append(EVIDENCE_FLAG_DOCUMENT_DESTROYED)

	return flags


func _next_customs_inspection_id() -> String:
	var inspection_id: String = "CINS-%04d" % next_customs_inspection_id
	next_customs_inspection_id += 1
	return inspection_id


func _ensure_sentence_end(text: String) -> String:
	var trimmed: String = text.strip_edges()
	if trimmed == "":
		return ""
	if trimmed.ends_with("."):
		return trimmed
	return "%s." % trimmed


func _format_customs_summary(classification: String, reasons_variant) -> String:
	var summary: String = ""
	if reasons_variant is Array and reasons_variant.size() > 0:
		summary = String(reasons_variant[0])
	if summary == "":
		if classification == "CLEAN":
			summary = "No irregularities detected"
		else:
			summary = "Inspection flagged issues"
	return _ensure_sentence_end(summary)


func _format_customs_recommendation(report: Dictionary) -> String:
	var penalty_variant = report.get("recommended_penalty", {})
	if not (penalty_variant is Dictionary):
		return ""
	var penalty: Dictionary = penalty_variant
	var action: String = String(penalty.get("recommended_action", ""))
	if action == "":
		action = String(penalty.get("action", ""))
	if action != "":
		return _ensure_sentence_end("Recommended action: %s" % action)
	var suggested_amount: float = float(penalty.get("suggested_amount", 0.0))
	if suggested_amount > 0.0:
		return "Recommended fine: %.0f credits." % suggested_amount
	return ""


func _format_customs_log_entry(report: Dictionary) -> String:
	var classification_raw: String = String(report.get("classification", "")).to_upper()
	var classification: String = classification_raw
	match classification_raw:
		"CLEAN", "SUSPICIOUS", "INVALID":
			classification = classification_raw
		_:
			classification = "SUSPICIOUS"

	var summary: String = _format_customs_summary(classification, report.get("reasons", []))
	var recommendation: String = _format_customs_recommendation(report)
	var message: String = "CUSTOMS: %s — %s" % [classification, summary]
	if recommendation != "":
		message = "%s %s" % [message, recommendation]
	return message


func run_customs_inspection(context: Dictionary = {}) -> Dictionary:
	var system_id: String = str(context.get("system_id", current_system_id))
	var location_id: String = str(context.get("location_id", current_location_id))

	var doc_ids: Array = []
	for doc_variant in freight_docs:
		if not (doc_variant is Dictionary):
			continue
		var doc: Dictionary = doc_variant
		var doc_id: String = str(doc.get("doc_id", ""))
		if doc_id != "":
			doc_ids.append(doc_id)

	var num_docs_considered := doc_ids.size()
	var num_destroyed_docs := 0
	var min_authenticity := 0
	if num_docs_considered > 0:
		min_authenticity = 100

	var declared_qty_modified_count := 0
	var container_meta_modified_count := 0

	for doc_id in doc_ids:
		var doc: Dictionary = get_freight_doc(doc_id)
		if doc.is_empty():
			continue

		if bool(doc.get("is_destroyed", false)):
			num_destroyed_docs += 1

		var authenticity := get_doc_authenticity(doc_id)
		if authenticity < min_authenticity:
			min_authenticity = authenticity

		var flags: Array = get_doc_evidence_flags(doc_id)
		if flags.has(EVIDENCE_FLAG_DECLARED_QTY_MODIFIED):
			declared_qty_modified_count += 1
		if flags.has(EVIDENCE_FLAG_CONTAINER_META_MODIFIED):
			container_meta_modified_count += 1

	var reasons: Array = []
	var classification: String = "clean"

	if num_docs_considered == 0:
		classification = "suspicious"
		reasons.append("No freight documents found.")
	elif num_destroyed_docs > 0:
		classification = "invalid"
		reasons.append("Destroyed freight document detected.")
	elif min_authenticity < CUSTOMS_AUTHENTICITY_THRESHOLD:
		classification = "suspicious"
		reasons.append("Authenticity below %d." % CUSTOMS_AUTHENTICITY_THRESHOLD)
	elif declared_qty_modified_count > 0 or container_meta_modified_count > 0:
		classification = "suspicious"
		reasons.append("Modification evidence present.")

	var report := {
		"inspection_id": _next_customs_inspection_id(),
		"tick": time_tick,
		"system_id": system_id,
		"location_id": location_id,
		"classification": classification,
		"reasons": reasons,
		"doc_summary": {
			"num_docs_considered": num_docs_considered,
			"num_missing_docs": 0,
			"num_destroyed_docs": num_destroyed_docs,
			"min_authenticity": min_authenticity,
			"evidence_flags": {
				"declared_quantity_modified_count": declared_qty_modified_count,
				"container_meta_modified_count": container_meta_modified_count,
				"document_destroyed_count": num_destroyed_docs,
			},
		},
		"recommended_penalty": {
			"should_issue_fine": false,
			"suggested_amount": 0.0,
			"issuer_org_id": "",
			"payable_at_system_id": "",
			"payable_at_location_id": "",
			"due_tick": 0,
		},
	}

	Log.add_entry(_format_customs_log_entry(report), "CUSTOMS")
	emit_signal("customs_inspection_completed", report)
	return report


func modify_freight_doc(doc_id: String, changes: Dictionary, source: String) -> Dictionary:
	var result := {
		"ok": false,
		"error": "",
	}

	if source != "captains_quarters":
		result.error = "Unauthorized source."
		Log.add_entry("FreightDoc modification denied: unauthorized source.")
		return result

	var idx := _find_freight_doc_index(doc_id)
	if idx == -1:
		result.error = "Unknown document."
		Log.add_entry("FreightDoc modification failed: unknown document.")
		return result

	var doc: Dictionary = freight_docs[idx]
	doc = _normalize_freight_doc_runtime(doc)

	var tool_used: String = String(changes.get("tool_used", "none"))
	var quality: int = int(changes.get("quality", 0))

	var before_declared := {
		"declared_quantity": int(doc.get("declared_quantity", 0)),
		"container_meta": (doc.get("container_meta", {}) as Dictionary).duplicate(true),
	}
	var before_meta := before_declared.duplicate(true)

	var after_declared := before_declared.duplicate(true)
	var after_meta := before_meta.duplicate(true)

	var has_declared_change := changes.has("declared_quantity")
	var has_meta_change := changes.has("container_meta")

	var declared_ok := true
	var meta_ok := true
	if has_declared_change:
		var new_qty: int = int(changes.get("declared_quantity", 0))
		after_declared["declared_quantity"] = new_qty
		if new_qty < 0:
			declared_ok = false
			result.error = "Invalid declared quantity."

	if has_meta_change:
		var meta_variant = changes.get("container_meta", {})
		if not (meta_variant is Dictionary):
			meta_ok = false
			result.error = "Invalid container metadata."
		else:
			var merged: Dictionary = before_meta["container_meta"].duplicate(true)
			for key in meta_variant.keys():
				merged[key] = meta_variant[key]
			after_meta["container_meta"] = merged

	if not has_declared_change and not has_meta_change:
		result.error = "No valid changes requested."

	if bool(doc.get("is_destroyed", false)):
		result.error = "Document is destroyed."

	if result.error != "":
		if not has_declared_change and not has_meta_change:
			doc = _append_freight_doc_event(doc, "edit_noop", before_declared, after_declared, tool_used, quality)
		else:
			if has_declared_change:
				doc = _append_freight_doc_event(doc, "edit_declared_qty", before_declared, after_declared, tool_used, quality)
			if has_meta_change:
				doc = _append_freight_doc_event(doc, "edit_meta", before_meta, after_meta, tool_used, quality)
		freight_docs[idx] = doc
		Log.add_entry("FreightDoc modification failed: %s" % result.error)
		return result

	if not declared_ok or not meta_ok:
		if has_declared_change:
			doc = _append_freight_doc_event(doc, "edit_declared_qty", before_declared, after_declared, tool_used, quality)
		if has_meta_change:
			doc = _append_freight_doc_event(doc, "edit_meta", before_meta, after_meta, tool_used, quality)
		freight_docs[idx] = doc
		Log.add_entry("FreightDoc modification failed: %s" % result.error)
		return result

	if has_declared_change:
		doc["declared_quantity"] = after_declared["declared_quantity"]
		doc = _append_freight_doc_event(doc, "edit_declared_qty", before_declared, after_declared, tool_used, quality)
	if has_meta_change:
		doc["container_meta"] = after_meta["container_meta"]
		doc = _append_freight_doc_event(doc, "edit_meta", before_meta, after_meta, tool_used, quality)

	freight_docs[idx] = doc
	result.ok = true
	Log.add_entry("FreightDoc modified: %s." % doc_id)
	emit_signal("freight_doc_changed", doc_id, "modified")
	return result


func _detach_doc_from_cargo_lines(doc_id: String) -> void:
	for i in range(cargo_lines.size()):
		var line: Dictionary = cargo_lines[i]
		if not line.has("doc_ids"):
			continue
		var ids_variant = line.get("doc_ids")
		if not (ids_variant is Array):
			continue
		var ids: Array = ids_variant
		var updated: Array = []
		for id_variant in ids:
			var id: String = String(id_variant)
			if id != doc_id:
				updated.append(id)
		line["doc_ids"] = updated
		cargo_lines[i] = line


func destroy_freight_doc(doc_id: String, reason: String, source: String) -> Dictionary:
	var result := {
		"ok": false,
		"error": "",
	}

	if source != "captains_quarters":
		result.error = "Unauthorized source."
		Log.add_entry("FreightDoc destruction denied: unauthorized source.")
		return result

	var idx := _find_freight_doc_index(doc_id)
	if idx == -1:
		result.error = "Unknown document."
		Log.add_entry("FreightDoc destruction failed: unknown document.")
		return result

	var doc: Dictionary = freight_docs[idx]
	doc = _normalize_freight_doc_runtime(doc)

	var tool_used: String = "none"
	var quality: int = 0
	var before := {
		"is_destroyed": bool(doc.get("is_destroyed", false)),
	}
	var after := before.duplicate(true)
	after["reason"] = reason

	if bool(doc.get("is_destroyed", false)):
		result.error = "Document already destroyed."
		doc = _append_freight_doc_event(doc, "destroy_doc", before, after, tool_used, quality)
		freight_docs[idx] = doc
		Log.add_entry("FreightDoc destruction failed: document already destroyed.")
		return result

	doc["is_destroyed"] = true
	doc["status"] = "destroyed"
	# Future: issuer recovery / penalties.
	doc = _append_freight_doc_event(doc, "destroy_doc", before, after, tool_used, quality)
	freight_docs[idx] = doc
	_detach_doc_from_cargo_lines(doc_id)

	if String(doc.get("doc_type", "")) == "contract":
		var contract_id: String = String(doc.get("contract_id", ""))
		if contract_id != "" and _has_active_contract_id(contract_id):
			_mark_contract_abandoned(contract_id)

	result.ok = true
	Log.add_entry("FreightDoc destroyed: %s." % doc_id)
	emit_signal("freight_doc_changed", doc_id, "destroyed")
	return result


func _next_cargo_line_id() -> String:
	var line_id: String = "CARGO-%04d" % next_cargo_line_id
	next_cargo_line_id += 1
	return line_id


func _normalize_market_kind(value: String) -> String:
	if value == MARKET_KIND_BLACK_MARKET:
		return MARKET_KIND_BLACK_MARKET
	return MARKET_KIND_LEGAL


func _create_bill_of_sale_doc(
	cargo_line_id: String,
	commodity_id: String,
	quantity: int,
	unit_price: float,
	total_cost: float,
	market_kind: String
) -> Dictionary:
	var doc_id: String = "FDOC-%04d" % next_freight_doc_id
	next_freight_doc_id += 1

	var system_id: String = current_system_id
	var location_id: String = current_location_id
	var location_name: String = ""
	var location: Dictionary = get_current_location()
	if not location.is_empty():
		location_name = String(location.get("name", location_id))

	var doc := {
		"doc_id": doc_id,
		"doc_type": "bill_of_sale",
		"status": "active",

		"cargo_line_id": cargo_line_id,
		"commodity_id": commodity_id,
		"quantity": quantity,
		"unit_price": unit_price,
		"total_cost": total_cost,
		"market_kind": _normalize_market_kind(market_kind),

		"purchase_system_id": system_id,
		"purchase_location_id": location_id,
		"purchase_location_name": location_name,
		"purchase_tick": time_tick,

		# Keep origin/destination fields for existing list rendering.
		"origin_system_id": system_id,
		"destination_system_id": system_id,
		"container_meta": _build_container_meta(
			doc_id,
			false,
			"market_purchase",
			system_id,
			location_id
		),

		"cargo_lines": [
			{
				"commodity_id": commodity_id,
				"declared_qty": quantity,
				"cargo_space": quantity,
			}
		],
	}

	freight_docs.append(doc)

	var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
	var commodity_name: String = String(commodity.get("name", commodity_id))
	Log.add_entry("Created bill of sale %s for %d x %s."
		% [doc_id, quantity, commodity_name])

	return doc


func record_market_purchase(
	commodity_id: String,
	quantity: int,
	unit_price: float,
	total_cost: float,
	market_kind: String
) -> void:
	if commodity_id == "" or quantity <= 0:
		return

	var cargo_line_id: String = _next_cargo_line_id()
	var normalized_kind: String = _normalize_market_kind(market_kind)
	var doc: Dictionary = _create_bill_of_sale_doc(
		cargo_line_id,
		commodity_id,
		quantity,
		unit_price,
		total_cost,
		normalized_kind
	)

	cargo_lines.append({
		"cargo_line_id": cargo_line_id,
		"commodity_id": commodity_id,
		"quantity": quantity,
		"doc_ids": [doc.get("doc_id", "")],
		"market_kind": normalized_kind,
		"unit_price": unit_price,
		"total_cost": total_cost,
		"purchase_system_id": current_system_id,
		"purchase_location_id": current_location_id,
		"purchase_tick": time_tick,
	})

func create_purchase_order(
	commodity_id: String,
	quantity: int,
	unit_price: float,
	total_cost: float,
	system_id: String,
	location_id: String
) -> String:
	var doc_id: String = "FDOC-%04d" % next_freight_doc_id
	next_freight_doc_id += 1

	var location_name: String = ""
	var location: Dictionary = Galaxy.get_location(location_id)
	if not location.is_empty():
		location_name = String(location.get("name", location_id))

	var doc := {
		"doc_id": doc_id,
		"doc_type": "purchase_order",
		"status": "active",

		"commodity_id": commodity_id,
		"quantity": quantity,
		"unit_price": unit_price,
		"total_cost": total_cost,
		"purchase_tick": time_tick,

		"purchase_system_id": system_id,
		"purchase_location_id": location_id,
		"purchase_location_name": location_name,

		"origin_system_id": system_id,
		"destination_system_id": system_id,
		"container_meta": _build_container_meta(
			doc_id,
			false,
			"purchase_order",
			system_id,
			location_id
		),

		"cargo_lines": [
			{
				"commodity_id": commodity_id,
				"declared_qty": quantity,
				"cargo_space": quantity,
			}
		],
	}

	freight_docs.append(doc)
	return doc_id

func purchase_market_goods(commodity_id: String, qty: int) -> Dictionary:
	var result := {
		"ok": false,
		"error": "",
		"total_cost": 0.0,
	}

	if commodity_id == "":
		result.error = "Invalid commodity."
		Log.add_entry("Purchase failed: invalid commodity.", "SHIP")
		return result

	if qty <= 0:
		result.error = "Invalid quantity."
		Log.add_entry("Purchase failed: invalid quantity.", "SHIP")
		return result

	if current_location_id == "":
		result.error = "No market available."
		Log.add_entry("Purchase failed: no market available.", "SHIP")
		return result

	var location: Dictionary = Galaxy.get_location(current_location_id)
	if location.is_empty():
		result.error = "No market available."
		Log.add_entry("Purchase failed: no market available.", "SHIP")
		return result

	var spaces_variant = location.get("spaces", [])
	var has_market: bool = false
	if spaces_variant is Array:
		var spaces: Array = spaces_variant
		has_market = spaces.has("market")

	if not has_market:
		result.error = "No market available."
		Log.add_entry("Purchase failed: no market available.", "SHIP")
		return result

	var sys_id: String = current_system_id
	if sys_id == "":
		result.error = "No market available."
		Log.add_entry("Purchase failed: no market available.", "SHIP")
		return result

	var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
	if commodity.is_empty():
		result.error = "Unknown commodity."
		Log.add_entry("Purchase failed: unknown commodity.", "SHIP")
		return result

	var unit_price: float = 0.0
	var price_found: bool = false
	var price_list: Array = Economy.get_price_list_for_system(sys_id)
	for entry_variant in price_list:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		if String(entry.get("id", "")) == commodity_id:
			unit_price = float(entry.get("price", 0.0))
			price_found = true
			break

	if not price_found:
		result.error = "No market price available."
		Log.add_entry("Purchase failed: no market price available.", "SHIP")
		return result

	var total_cost: float = unit_price * float(qty)
	if total_cost > player_money:
		result.error = "Not enough credits."
		Log.add_entry("Purchase failed: not enough credits.", "SHIP")
		return result

	var per_unit_weight: float = float(commodity.get("weight_per_unit", 1.0))
	var added_weight: float = per_unit_weight * float(qty)
	var current_weight: float = get_total_cargo_weight()
	if current_weight + added_weight > cargo_capacity_weight:
		result.error = "Not enough cargo capacity."
		Log.add_entry("Purchase failed: not enough cargo capacity.", "SHIP")
		return result

	player_money -= total_cost
	add_cargo(commodity_id, qty)
	create_purchase_order(
		commodity_id,
		qty,
		unit_price,
		total_cost,
		current_system_id,
		current_location_id
	)

	result.ok = true
	result.total_cost = total_cost
	Log.add_entry("Bought %d x %s for %.0f cr."
		% [qty, commodity.get("name", commodity_id), total_cost], "SHIP")
	return result

func _get_consumed_sale_quantities() -> Dictionary:
	var consumed: Dictionary = {}
	for doc_variant in freight_docs:
		if not (doc_variant is Dictionary):
			continue
		var doc: Dictionary = doc_variant
		if String(doc.get("doc_type", "")) != "bill_of_sale":
			continue
		var cargo_lines_variant = doc.get("cargo_lines", [])
		if not (cargo_lines_variant is Array):
			continue
		var cargo_lines: Array = cargo_lines_variant
		for line_variant in cargo_lines:
			if not (line_variant is Dictionary):
				continue
			var line: Dictionary = line_variant
			var line_sources_variant = line.get("sources", [])
			if not (line_sources_variant is Array):
				continue
			var line_sources: Array = line_sources_variant
			for source_variant in line_sources:
				if not (source_variant is Dictionary):
					continue
				var source: Dictionary = source_variant
				var source_doc_id: String = String(source.get("doc_id", ""))
				var source_qty: int = int(source.get("qty", 0))
				if source_doc_id == "" or source_qty <= 0:
					continue
				var commodity_id: String = String(line.get("commodity_id", ""))
				if commodity_id == "":
					continue
				var key: String = "%s|%s" % [source_doc_id, commodity_id]
				consumed[key] = int(consumed.get(key, 0)) + source_qty
	return consumed

func _build_sale_sources(commodity_id: String, qty: int) -> Dictionary:
	var result := {
		"ok": false,
		"error": "",
		"sources": [],
	}
	if commodity_id == "" or qty <= 0:
		result.error = "Invalid commodity or quantity."
		return result

	var consumed: Dictionary = _get_consumed_sale_quantities()
	var remaining: int = qty
	var sources: Array = []

	for doc_variant in freight_docs:
		if remaining <= 0:
			break
		if not (doc_variant is Dictionary):
			continue
		var doc: Dictionary = doc_variant
		var doc_type: String = String(doc.get("doc_type", ""))
		if doc_type != "purchase_order" and doc_type != "contract":
			continue
		var doc_id: String = String(doc.get("doc_id", ""))
		if doc_id == "":
			continue

		var cargo_lines_variant = doc.get("cargo_lines", [])
		if not (cargo_lines_variant is Array):
			continue
		var cargo_lines: Array = cargo_lines_variant
		for line_variant in cargo_lines:
			if remaining <= 0:
				break
			if not (line_variant is Dictionary):
				continue
			var line: Dictionary = line_variant
			if String(line.get("commodity_id", "")) != commodity_id:
				continue
			var declared_qty: int = int(line.get("declared_qty", 0))
			if declared_qty <= 0:
				continue

			var key: String = "%s|%s" % [doc_id, commodity_id]
			var already_consumed: int = int(consumed.get(key, 0))
			var available: int = declared_qty - already_consumed
			if available <= 0:
				continue
			var take_qty: int = min(remaining, available)
			sources.append({
				"doc_id": doc_id,
				"qty": take_qty,
			})
			remaining -= take_qty

	if remaining > 0:
		result.error = "Insufficient source documentation."
		return result

	result.ok = true
	result.sources = sources
	return result

func _create_bill_of_sale_for_sale(
	commodity_id: String,
	quantity: int,
	unit_price: float,
	total_price: float,
	system_id: String,
	location_id: String,
	location_name: String,
	market_kind: String,
	sources: Array
) -> String:
	var doc_id: String = "FDOC-%04d" % next_freight_doc_id
	next_freight_doc_id += 1

	var doc := {
		"doc_id": doc_id,
		"doc_type": "bill_of_sale",
		"status": "active",

		"system_id": system_id,
		"location_id": location_id,
		"location_name": location_name,
		"tick": time_tick,
		"market_kind": _normalize_market_kind(market_kind),

		"container_meta": _build_container_meta(
			doc_id,
			false,
			"bill_of_sale",
			system_id,
			location_id
		),

		"cargo_lines": [
			{
				"commodity_id": commodity_id,
				"sold_qty": quantity,
				"unit_price": unit_price,
				"total_price": total_price,
				"sources": sources,
			}
		],
	}

	freight_docs.append(doc)
	return doc_id

func sell_manifest_goods(
	commodity_id: String,
	qty: int,
	system_id: String,
	location_id: String,
	market_kind: String
) -> Dictionary:
	var result := {
		"ok": false,
		"error": "",
		"total_price": 0.0,
	}

	if commodity_id == "":
		result.error = "Invalid commodity."
		Log.add_entry("Sale failed: invalid commodity.", "OTHER")
		return result

	if qty <= 0:
		result.error = "Invalid quantity."
		Log.add_entry("Sale failed: invalid quantity.", "OTHER")
		return result

	if location_id == "":
		result.error = "No market available."
		Log.add_entry("Sale failed: no market available.", "OTHER")
		return result

	var location: Dictionary = Galaxy.get_location(location_id)
	if location.is_empty():
		result.error = "No market available."
		Log.add_entry("Sale failed: no market available.", "OTHER")
		return result

	var spaces_variant = location.get("spaces", [])
	var has_market: bool = false
	if spaces_variant is Array:
		var spaces: Array = spaces_variant
		has_market = spaces.has("market")
	if not has_market:
		result.error = "No market available."
		Log.add_entry("Sale failed: no market available.", "OTHER")
		return result

	if system_id == "":
		result.error = "No market available."
		Log.add_entry("Sale failed: no market available.", "OTHER")
		return result

	var have_qty: int = get_cargo_quantity(commodity_id)
	if have_qty <= 0:
		result.error = "No cargo available."
		Log.add_entry("Sale failed: no cargo available.", "OTHER")
		return result

	if qty > have_qty:
		result.error = "Not enough cargo."
		Log.add_entry("Sale failed: not enough cargo.", "OTHER")
		return result

	var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
	if commodity.is_empty():
		result.error = "Unknown commodity."
		Log.add_entry("Sale failed: unknown commodity.", "OTHER")
		return result

	var quote: Dictionary = Economy.quote_sale_price(
		commodity_id,
		qty,
		system_id,
		location_id,
		market_kind
	)
	if not bool(quote.get("ok", false)):
		result.error = String(quote.get("error", "No market price available."))
		Log.add_entry("Sale failed: %s" % result.error.to_lower(), "OTHER")
		return result

	var final_unit_price: float = float(quote.get("final_unit_price", quote.get("unit_price", 0.0)))
	var total_price: float = float(quote.get("total_price", 0.0))
	if final_unit_price <= 0.0 or total_price <= 0.0:
		result.error = "No market price available."
		Log.add_entry("Sale failed: no market price available.", "OTHER")
		return result

	var sources_result: Dictionary = _build_sale_sources(commodity_id, qty)
	if not bool(sources_result.get("ok", false)):
		result.error = String(sources_result.get("error", "Insufficient source documentation."))
		Log.add_entry("Sale failed: %s" % result.error.to_lower(), "OTHER")
		return result

	var sources_variant = sources_result.get("sources")
	if not (sources_variant is Array):
		result.error = "Insufficient source documentation."
		Log.add_entry("Sale failed: %s" % result.error.to_lower(), "OTHER")
		return result
	var sources: Array = sources_variant
	var location_name: String = String(location.get("name", location_id))

	remove_cargo(commodity_id, qty)
	player_money += total_price

	_create_bill_of_sale_for_sale(
		commodity_id,
		qty,
		final_unit_price,
		total_price,
		system_id,
		location_id,
		location_name,
		market_kind,
		sources
	)

	result.ok = true
	result.total_price = total_price
	Log.add_entry("Bill of Sale: Sold %d x %s for %.0f cr."
		% [qty, commodity.get("name", commodity_id), total_price], "OTHER")
	return result

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

func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var key : int = event.keycode

		# T = advance time by 1 tick
		if key == KEY_T:
			advance_time("manual test: T key")

		# Y = copy current system market (legal) to clipboard
		if key == KEY_Y:
			if current_system_id == "":
				return
			var text := Economy.get_price_list_text_for_system_at(current_system_id, time_tick, "legal")
			DisplayServer.clipboard_set(text)
