# res://singletons/Galaxy.gd
extends Node

##
# Galaxy model:
# - systems: star systems (warp graph, security, population)
# - locations: stations/colonies within systems
#
# System structure (example):
# {
#   "id": "SYS_000",
#   "name": "Forge-00",
#   "system_type": "industrial",   # kept for compatibility
#   "security_level": "medium",
#   "population": 3_000_000,
#   "neighbors": ["SYS_001", ...],
#   "locations": ["LOC_000_00", "LOC_000_01"],
#   "has_drydock": true
# }
#
# Location structure (example):
# {
#   "id": "LOC_000_00",
#   "system_id": "SYS_000",
#   "name": "Forge Orbital Docks",
#   "type": "industrial_refinery",
#   "spaces": ["market", "gov_office", "dry_dock"],
#   "economy_type": "industrial",
#   "tariff_rate": 0.05,
#   "factions": {},
#   "description": "Flavor text"
# }
##

var systems: Dictionary = {}   # system_id -> system dict
var locations: Dictionary = {} # location_id -> location dict

# Tunables for MVP / early full-game work
var target_system_count: int = 25
var min_locations_per_system: int = 1
var max_locations_per_system: int = 3

const ORG_ID_GOVERNMENT: String = "government"
const ORG_ID_CARTEL: String = "cartel"

# Location types you defined
const LOCATION_TYPES := [
	"corporate_colony",
	"trade_hub",
	"core_world",
	"agricultural",
	"mining",
	"industrial_refinery",
	"military",
	"shipyard",
	"tourist_hub",
	"monastic",
	"colony"
]

# Space weights by location type
const SPACE_WEIGHTS := {
	"corporate_colony": {
		"market": 3,
		"gov_office": 2,
		"cantina": 2,
		"back_room": 2,
		"corp_office": 4,
		"dry_dock": 2,
	},
	"trade_hub": {
		"market": 4,
		"gov_office": 2,
		"cantina": 3,
		"back_room": 3,
		"corp_office": 2,
		"dry_dock": 2,
	},
	"core_world": {
		"market": 3,
		"gov_office": 3,
		"cantina": 2,
		"back_room": 1,
		"corp_office": 4,
		"dry_dock": 2,
	},
	"agricultural": {
		"market": 2,
		"gov_office": 1,
		"cantina": 2,
		"back_room": 2,
		"corp_office": 1,
		"dry_dock": 1,
	},
	"mining": {
		"market": 2,
		"gov_office": 1,
		"cantina": 3,
		"back_room": 3,
		"corp_office": 0,
		"dry_dock": 2,
	},
	"industrial_refinery": {
		"market": 2,
		"gov_office": 2,
		"cantina": 2,
		"back_room": 2,
		"corp_office": 2,
		"dry_dock": 4,
	},
	"military": {
		"market": 1,
		"gov_office": 4,
		"cantina": 1,
		"back_room": 1,
		"corp_office": 1,
		"dry_dock": 4,
	},
	"shipyard": {
		"market": 2,
		"gov_office": 2,
		"cantina": 2,
		"back_room": 2,
		"corp_office": 1,
		"dry_dock": 4,
	},
	"tourist_hub": {
		"market": 3,
		"gov_office": 1,
		"cantina": 4,
		"back_room": 2,
		"corp_office": 0,
		"dry_dock": 1,
	},
	"monastic": {
		"market": 1,
		"gov_office": 1,
		"cantina": 1,
		"back_room": 1,
		"corp_office": 0,
		"dry_dock": 0,
	},
	"colony": {
		"market": 2,
		"gov_office": 1,
		"cantina": 2,
		"back_room": 2,
		"corp_office": 0,
		"dry_dock": 1,
	},
}


func _ready() -> void:
	# For now, generate on startup. Later you can load a seed/save instead.
	generate_galaxy(target_system_count)


func generate_galaxy(count: int) -> void:
	systems.clear()
	locations.clear()

	# 1) Create systems with basic properties (similar to your old version)
	for i in count:
		var sys_id := "SYS_%03d" % i

		var system_type := _pick_system_type(i, count) # kept for compatibility
		var security := _pick_security(system_type)
		var population := _generate_population(system_type)
		var name := _generate_system_name(system_type, i)

		var system: Dictionary = {
			"id": sys_id,
			"name": name,
			"system_type": system_type,     # still used by Economy / UI today
			"security_level": security,
			"population": population,
			"neighbors": [],
			"locations": [],                # filled after location generation
			"has_drydock": false,           # updated based on locations
			"factions": {},                 # reserved for later
		}

		systems[sys_id] = system

	# 2) Add warp lane connections to make a connected graph
	_connect_systems_line()
	_add_extra_connections(2)

	# 3) Generate locations for each system
	for sys_id in systems.keys():
		var sys: Dictionary = systems[sys_id]
		var loc_ids: Array = _generate_locations_for_system(sys_id, sys)
		sys["locations"] = loc_ids

		# System-level has_drydock is true if ANY location has a dry_dock space
		var has_drydock := false
		for loc_id in loc_ids:
			var loc: Dictionary = locations.get(loc_id, {})
			if not loc.is_empty():
				var spaces: Array = loc.get("spaces", [])
				if "dry_dock" in spaces:
					has_drydock = true
					break

		sys["has_drydock"] = has_drydock
		systems[sys_id] = sys


## ----------- SYSTEM PROPERTY GENERATION -----------

func _pick_system_type(index: int, total: int) -> String:
	# Simple distribution kept from earlier version for compatibility
	# You can later refactor this away once everything uses locations instead.
	var r := randi() % 5
	match r:
		0:
			return "mining"
		1:
			return "agri"
		2:
			return "industrial"
		3:
			return "hub"
		_:
			return "core"


func _pick_security(system_type: String) -> String:
	var roll := randi() % 100
	match system_type:
		"industrial":
			if roll < 20:
				return "low"
			elif roll < 60:
				return "medium"
			else:
				return "high"
		"mining":
			if roll < 40:
				return "low"
			elif roll < 80:
				return "medium"
			else:
				return "high"
		"agri":
			if roll < 30:
				return "low"
			elif roll < 70:
				return "medium"
			else:
				return "high"
		_:
			return "medium"


func _generate_population(system_type: String) -> int:
	match system_type:
		"mining":
			return randi_range(200_000, 3_000_000)
		"agri":
			return randi_range(500_000, 5_000_000)
		"industrial":
			return randi_range(2_000_000, 12_000_000)
		_:
			return randi_range(500_000, 8_000_000)


func _generate_system_name(system_type: String, index: int) -> String:
	var prefix := ""
	match system_type:
		"mining":
			prefix = "Pit"
		"agri":
			prefix = "Harvest"
		"industrial":
			prefix = "Forge"
		"hub":
			prefix = "Node"
		"core":
			prefix = "Core"
		_:
			prefix = "Sys"

	return "%s-%02d" % [prefix, index]


## ----------- LOCATION GENERATION -----------

func _generate_locations_for_system(system_id: String, system: Dictionary) -> Array:
	var loc_ids: Array = []
	var count := randi_range(min_locations_per_system, max_locations_per_system)

	for i in count:
		var loc_id := "%s_LOC_%02d" % [system_id, i]

		var loc_type := _pick_location_type(system, i)
		var spaces: Array = _pick_spaces_for_location(loc_type)
		if spaces.is_empty():
			# Guarantee at least a market for now.
			spaces.append("market")

		var economy_type := _infer_economy_type_from_location_type(loc_type)
		var name := _generate_location_name(system, loc_type, i)
		var tariff_rate := _pick_tariff_rate(loc_type)
		var description := _generate_location_flavor_text(loc_type, spaces)

		var loc: Dictionary = {
			"id": loc_id,
			"system_id": system_id,
			"name": name,
			"type": loc_type,
			"spaces": spaces,
			"economy_type": economy_type,
			"tariff_rate": tariff_rate,
			"base_influences": [],
			"delta_influences": [],
			"factions": {},      # filled later when we add factions
			"description": description,
		}

		loc["base_influences"] = _build_base_influences(loc, system)
		locations[loc_id] = loc
		loc_ids.append(loc_id)

	return loc_ids


func _pick_location_type(system: Dictionary, index: int) -> String:
	# Simple first pass:
	# - bias based on system_type, but still allow all location types.
	var sys_type: String = system.get("system_type", "mixed")

	var candidates: Array = LOCATION_TYPES.duplicate()
	# Tiny tweak: for now we just random-pick, but we could weight based on sys_type later.
	var idx := randi() % candidates.size()
	return candidates[idx]


func _pick_spaces_for_location(loc_type: String) -> Array:
	var result: Array = []

	var weights: Dictionary = SPACE_WEIGHTS.get(loc_type, {})
	var all_spaces: Array = [
		"market",
		"gov_office",
		"cantina",
		"back_room",
		"corp_office",
		"dry_dock"
	]

	for space_name in all_spaces:
		var w := int(weights.get(space_name, 0))
		var chance: float = 0.0

		match w:
			0:
				chance = 0.0
			1:
				chance = 0.2
			2:
				chance = 0.4
			3:
				chance = 0.7
			4:
				chance = 0.9
			_:
				chance = 0.0

		# Tiny global "weird chance" so rare combos can appear anywhere
		if w == 0:
			if randf() < 0.02:
				result.append(space_name)
		else:
			if randf() < chance:
				result.append(space_name)

	# 🔷 Ensure uniqueness
	var dict := {}
	for item in result:
		dict[item] = true

	var keys: Array = dict.keys()
	keys.sort()
	result = keys

	# 🔷 Make markets very common across all types
	# If this location doesn't have a market, give it one ~85% of the time.
	if not result.has("market"):
		if randf() < 0.85:
			result.append("market")
			result.sort()

	return result


func _infer_economy_type_from_location_type(loc_type: String) -> String:
	match loc_type:
		"agricultural":
			return "agri"
		"mining":
			return "mining"
		"industrial_refinery":
			return "industrial"
		"corporate_colony", "trade_hub", "core_world":
			return "mixed"
		"shipyard":
			return "industrial"
		"military":
			return "military"
		"tourist_hub":
			return "tourism"
		"monastic":
			return "religious"
		"colony":
			return "frontier"
		_:
			return "mixed"


func _pick_tariff_rate(loc_type: String) -> float:
	match loc_type:
		"trade_hub", "core_world", "corporate_colony":
			return 0.06
		"military":
			return 0.08
		"shipyard", "industrial_refinery":
			return 0.05
		"tourist_hub":
			return 0.04
		"agricultural", "mining", "colony":
			return 0.03
		"monastic":
			return 0.01
		_:
			return 0.04


func _generate_location_name(system: Dictionary, loc_type: String, index: int) -> String:
	var base: String = ""
	match loc_type:
		"corporate_colony":
			base = "Colony"
		"trade_hub":
			base = "Exchange"
		"core_world":
			base = "Spire"
		"agricultural":
			base = "Agriport"
		"mining":
			base = "Station"
		"industrial_refinery":
			base = "Refinery"
		"military":
			base = "Garrison"
		"shipyard":
			base = "Yards"
		"tourist_hub":
			base = "Promenade"
		"monastic":
			base = "Cloister"
		"colony":
			base = "Outpost"
		_:
			base = "Port"

	var sys_name: String = system.get("name", "SYS")
	return "%s %s-%02d" % [base, sys_name, index + 1]


func _generate_location_flavor_text(loc_type: String, spaces: Array) -> String:
	var has_market := "market" in spaces
	var has_cantina := "cantina" in spaces
	var has_back_room := "back_room" in spaces
	var has_drydock := "dry_dock" in spaces
	var has_gov := "gov_office" in spaces

	match loc_type:
		"mining":
			if has_cantina:
				return "Miners in dust-streaked jumpsuits crowd the bar, trading rumors between shifts."
			else:
				return "Ore haulers drift in lazy arcs outside, their holds full and hulls scored by rock fragments."
		"agricultural":
			if has_market:
				return "Freight pallets of grain and produce line the concourse, bound for hungry core worlds."
			else:
				return "Local growers amble through a quiet terminal that smells faintly of soil and fertilizer."
		"industrial_refinery":
			if has_drydock:
				return "Welders’ arcs flicker over half-skinned hulls while refined product moves in sealed containers."
			else:
				return "Pipelines and loading arms loom over the docks, pumping processed feedstock into waiting freighters."
		"shipyard":
			return "Skeletons of starships hang in scaffolding, every deck alive with the sound of tools and shouted orders."
		"trade_hub":
			return "Voices, signage, and cargo from a dozen systems collide in a restless, noisy exchange."
		"core_world":
			return "Polished decks, clean lighting, and uniformed staff give the terminal a veneer of effortless order."
		"corporate_colony":
			return "Company logos dominate every surface, from bulkheads to boarding passes."
		"military":
			return "Armed patrols and checkpoint scanners make it clear: this port answers to the chain of command."
		"tourist_hub":
			return "Holoads promise wonders beyond the airlock, while vendors hawk trinkets to passing travelers."
		"monastic":
			return "Quiet corridors echo with soft footsteps and the distant murmur of ritual chants."
		"colony":
			return "Half-finished bulkheads and improvised kiosks mark this as a frontier station still finding its shape."
		_:
			return "A functional but forgettable port, where cargo moves and nobody asks too many questions."


## ----------- WARP LANE CONNECTIONS -----------

func _connect_systems_line() -> void:
	var ids := systems.keys()
	ids.sort()

	for i in range(ids.size() - 1):
		var a_id: String = ids[i]
		var b_id: String = ids[i + 1]
		_add_bidirectional_neighbor(a_id, b_id)


func _add_extra_connections(extra_per_system: int) -> void:
	var ids := systems.keys()
	var n := ids.size()

	for i in range(n):
		var from_id: String = ids[i]
		for j in extra_per_system:
			var to_index := randi() % n
			var to_id: String = ids[to_index]
			if to_id != from_id:
				_add_bidirectional_neighbor(from_id, to_id)


func _add_bidirectional_neighbor(a_id: String, b_id: String) -> void:
	if not systems.has(a_id) or not systems.has(b_id):
		return

	var a_neighbors: Array = systems[a_id]["neighbors"]
	var b_neighbors: Array = systems[b_id]["neighbors"]

	if not a_neighbors.has(b_id):
		a_neighbors.append(b_id)
	if not b_neighbors.has(a_id):
		b_neighbors.append(a_id)

	systems[a_id]["neighbors"] = a_neighbors
	systems[b_id]["neighbors"] = b_neighbors


## ----------- QUERY HELPERS -----------

func get_system(id: String) -> Dictionary:
	return systems.get(id, {})


func get_all_system_ids() -> Array:
	var ids := systems.keys()
	ids.sort()
	return ids


func get_neighbors(id: String) -> Array:
	if not systems.has(id):
		return []
	return systems[id].get("neighbors", [])


func find_path(start_id: String, target_id: String) -> Array:
	if start_id == target_id:
		return [start_id]

	if not systems.has(start_id) or not systems.has(target_id):
		return []

	var queue: Array = []
	var came_from: Dictionary = {}

	queue.append(start_id)
	came_from[start_id] = ""  # sentinel

	while queue.size() > 0:
		var current: String = str(queue.pop_front())
		if current == target_id:
			break

		var neighbors: Array = systems[current].get("neighbors", [])
		for neighbor_variant in neighbors:
			var neighbor: String = str(neighbor_variant)
			if not came_from.has(neighbor):
				came_from[neighbor] = current
				queue.append(neighbor)

	if not came_from.has(target_id):
		return []

	var path: Array = []
	var node: String = target_id
	while node != "":
		path.push_front(node)
		node = came_from.get(node, "")

	return path


func system_has_drydock(system_id: String) -> bool:
	var system: Dictionary = get_system(system_id)
	if system.is_empty():
		return false

	# Prefer location-based check now
	var loc_ids: Array = system.get("locations", [])
	for loc_id_variant in loc_ids:
		var loc_id: String = str(loc_id_variant)
		var loc: Dictionary = locations.get(loc_id, {})
		if not loc.is_empty():
			var spaces: Array = loc.get("spaces", [])
			if "dry_dock" in spaces:
				return true

	# Fallback to old field, for safety
	return bool(system.get("has_drydock", false))


## ----------- LOCATION HELPERS -----------

func get_location(loc_id: String) -> Dictionary:
	return locations.get(loc_id, {})


func get_location_ids_for_system(system_id: String) -> Array:
	var system: Dictionary = get_system(system_id)
	if system.is_empty():
		return []
	return system.get("locations", [])


func get_locations_for_system(system_id: String) -> Array:
	var result: Array = []
	var ids: Array = get_location_ids_for_system(system_id)
	for loc_id_variant in ids:
		var loc_id: String = str(loc_id_variant)
		var loc: Dictionary = locations.get(loc_id, {})
		if not loc.is_empty():
			result.append(loc)
	return result


## ----------- INFLUENCE HELPERS -----------

# Ensures base/delta influence arrays exist for all locations.
func ensure_location_influences() -> void:
	for loc_id in locations.keys():
		var loc: Dictionary = locations[loc_id]
		if not loc.has("base_influences"):
			loc["base_influences"] = []
		if not loc.has("delta_influences"):
			loc["delta_influences"] = []
		locations[loc_id] = loc


# Clears influence arrays for all locations (legacy save fallback).
func clear_location_influences() -> void:
	for loc_id in locations.keys():
		var loc: Dictionary = locations[loc_id]
		loc["base_influences"] = []
		loc["delta_influences"] = []
		locations[loc_id] = loc


func _build_base_influences(location: Dictionary, system: Dictionary) -> Array:
	var influences: Array = []
	var loc_id: String = String(location.get("id", ""))
	if loc_id == "":
		return influences

	var system_id: String = String(system.get("id", ""))
	if system_id == "":
		system_id = String(location.get("system_id", ""))

	var loc_type: String = String(location.get("type", ""))
	var economy_type: String = String(location.get("economy_type", ""))
	var security_level: String = String(system.get("security_level", ""))

	var roll := _deterministic_unit(
		"%s|%s|%s|%s|%s" % [loc_id, system_id, loc_type, economy_type, security_level]
	)

	if _location_is_outlaw(location):
		var cartel_weight := 0.6 + roll * 0.3
		influences.append({
			"org_id": ORG_ID_CARTEL,
			"weight": _round_weight(cartel_weight),
		})
		return influences

	var cartel_base := 0.02
	var cartel_weight := clamp(cartel_base + roll * 0.08, 0.0, 0.2)
	var government_weight := clamp(1.0 - cartel_weight, 0.5, 1.0)

	influences.append({
		"org_id": ORG_ID_GOVERNMENT,
		"weight": _round_weight(government_weight),
	})
	if cartel_weight > 0.0:
		influences.append({
			"org_id": ORG_ID_CARTEL,
			"weight": _round_weight(cartel_weight),
		})

	return influences


func _location_is_outlaw(location: Dictionary) -> bool:
	if bool(location.get("outlaw", false)) or bool(location.get("is_outlaw", false)):
		return true

	var tags_variant = location.get("tags", [])
	if tags_variant is Array:
		return tags_variant.has("outlaw")
	if tags_variant is PackedStringArray:
		return tags_variant.has("outlaw")
	return false


func _round_weight(value: float) -> float:
	return floor(value * 100.0 + 0.5) / 100.0


# FNV-1a 32-bit hash for deterministic pseudo-randomness from stable inputs.
# This is not cryptographic; it is used for procedural determinism only.
func _fnv1a_32(value: String) -> int:
	var hash: int = 0x811c9dc5
	var prime: int = 0x01000193
	var bytes: PackedByteArray = value.to_utf8_buffer()

	for b in bytes:
		hash ^= int(b)
		hash = int((hash * prime) & 0xffffffff)

	return hash


func _deterministic_unit(value: String) -> float:
	var hash: int = _fnv1a_32(value)
	var unit: float = float(hash & 0x7fffffff) / float(0x7fffffff)
	return unit
