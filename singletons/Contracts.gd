extends Node

# Simple travel contract: go from origin -> destination and get paid
# {
#   "id": String,
#   "origin": String,
#   "destination": String,
#   "reward": float,
#   "jumps": int

#	"commodity_id": "ORE_IRON",
#   "quantity": 50,
# }

var _id_counter: int = 0
var contracts_by_location_id: Dictionary = {}

func _next_id() -> String:
	_id_counter += 1
	return "CON_%04d" % _id_counter


func get_contracts_for_location(location_id: String) -> Array:
	if location_id == "":
		return []
	if not contracts_by_location_id.has(location_id):
		return []
	return contracts_by_location_id[location_id]


func refresh_contracts_for_location(location_id: String, count: int = 3) -> Array:
	if location_id == "":
		return []
	var generated: Array = generate_contracts_for_location(location_id, count)
	contracts_by_location_id[location_id] = generated
	return generated


func generate_contracts_for_system(system_id: String, count: int = 3) -> Array:
	var result: Array = []
	var all_ids: Array = Galaxy.get_all_system_ids()
	if all_ids.size() == 0:
		return result

	# very simple: pick random destinations, require a valid path
	var tries: int = 0
	while result.size() < count and tries < count * 10:
		tries += 1
		var dest_id: String = all_ids[randi() % all_ids.size()]
		if dest_id == system_id:
			continue

		var path: Array = Galaxy.find_path(system_id, dest_id)
		if path.is_empty() or path.size() < 2:
			continue

		var jumps: int = path.size() - 1

		# reward scales with distance, with a bit of randomness
		var base_reward: float = 200.0
		var reward: float = base_reward * float(jumps) * (0.8 + randf() * 0.6)

		var dest_system: Dictionary = Galaxy.get_system(dest_id)
		var dest_name: String = dest_system.get("name", dest_id)

		# 🔹 NEW: pick cargo for this contract
		var commodity_id: String = _pick_contract_commodity()
		var quantity: int = _pick_contract_quantity(jumps)

		var cargo_lines: Array = [
			{
				"commodity_id": commodity_id,
				"declared_qty": quantity,
				"cargo_space": quantity,
			}
		]

		result.append({
			"id": _next_id(),
			"origin": system_id,
			"destination": dest_id,
			"destination_name": dest_name,
			"jumps": jumps,
			"reward": reward,

			# 🔹 NEW: describe cargo for this contract
			"cargo_lines": cargo_lines,
		})

		var last_contract: Dictionary = result.back()
		print("Generated contract: ", last_contract)

		#prints to game log for additional player info
		#Log.add_entry("DEBUG: Generated contract with cargo_lines for %s" % dest_name)


	return result


func generate_contracts_for_location(origin_loc_id: String, count: int = 3) -> Array:
	var result: Array = []

	# Look up the origin location
	var origin_loc: Dictionary = Galaxy.get_location(origin_loc_id)
	if origin_loc.is_empty():
		# Fallback: use system-based generation if something goes wrong
		var sys_id: String = GameState.current_system_id
		return generate_contracts_for_system(sys_id, count)

	var origin_sys_id: String = String(origin_loc.get("system_id", ""))
	if origin_sys_id == "":
		var sys_id: String = GameState.current_system_id
		return generate_contracts_for_system(sys_id, count)

	# Re-use the system-level generator for destinations / jumps / reward / cargo
	var system_level_contracts: Array = generate_contracts_for_system(origin_sys_id, count)

	for c_variant in system_level_contracts:
		var c: Dictionary = c_variant
		var dest_sys_id: String = String(c.get("destination", ""))
		if dest_sys_id == "":
			continue

		var dest_locs: Array = Galaxy.get_locations_for_system(dest_sys_id)
		if dest_locs.is_empty():
			continue

		# Prefer locations with a market
		var market_locs: Array = []
		for loc_variant in dest_locs:
			var loc: Dictionary = loc_variant
			var spaces: Array = loc.get("spaces", [])
			if "market" in spaces:
				market_locs.append(loc)

		var chosen_dest_loc: Dictionary
		if market_locs.size() > 0:
			chosen_dest_loc = market_locs[randi() % market_locs.size()]
		else:
			chosen_dest_loc = dest_locs[randi() % dest_locs.size()]

		var dest_loc_id: String = String(chosen_dest_loc.get("id", ""))
		var dest_loc_name: String = String(chosen_dest_loc.get("name", dest_loc_id))

		# Copy original contract and enrich it with location info
		var enriched: Dictionary = c.duplicate(true)
		enriched["origin_location_id"] = origin_loc_id
		enriched["origin_location_name"] = String(origin_loc.get("name", origin_loc_id))
		enriched["destination_location_id"] = dest_loc_id
		enriched["destination_location_name"] = dest_loc_name

		result.append(enriched)

	return result


const CONTRACT_COMMODITY_IDS := [
	"chem_industrial",
	"art_objects",
	"med_supplies",
	"water_purified",
]

func _pick_contract_commodity() -> String:
	if CONTRACT_COMMODITY_IDS.is_empty():
		return "ORE_IRON"  # fallback, make sure this exists in CommodityDB
	var idx := randi() % CONTRACT_COMMODITY_IDS.size()
	return CONTRACT_COMMODITY_IDS[idx]


func _pick_contract_quantity(jumps: int) -> int:
	# Simple rule: base quantity plus a bit more for longer routes
	var base := 20
	var extra := jumps * 5
	return randi_range(base, base + extra)

