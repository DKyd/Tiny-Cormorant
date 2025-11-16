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

func _next_id() -> String:
	_id_counter += 1
	return "CON_%04d" % _id_counter


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
		#Log.add("DEBUG: Generated contract with cargo_lines for %s" % dest_name)


	return result

# For now, a simple list of commodity IDs that exist in your CommodityDB.
# 👉 You should replace these with real IDs from your CommodityDB.
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
