# res://singletons/Galaxy.gd
extends Node

var systems: Dictionary = {}  # id -> system dict

# Tunables for MVP
var target_system_count: int = 8
var min_locations_per_system: int = 1
var max_locations_per_system: int = 3

func _ready() -> void:
    # For now, generate on startup. Later you can load a seed/save.
    generate_galaxy(target_system_count)


func generate_galaxy(count: int) -> void:
    systems.clear()

    # 1) Create systems with basic properties
    for i in count:
        var sys_id := "SYS_%03d" % i
        var sys_type := _pick_system_type(i, count)
        var security := _pick_security(sys_type)
        var population := _generate_population(sys_type)

        var system: Dictionary = {
            "id": sys_id,
            "name": _generate_system_name(sys_type, i),
            "system_type": sys_type,
            "security_level": security,
            "population": population,
            "locations": [],
            "neighbors": []
        }

        # generate locations for this system
        system["locations"] = _generate_locations_for_system(system)

        systems[sys_id] = system

    # 2) Add warp lane connections to make a connected graph
    _connect_systems_line()
    _add_extra_connections(2)


## ----------- SYSTEM PROPERTY GENERATION -----------

func _pick_system_type(index: int, total: int) -> String:
    # Simple distribution: about 1/3 each, with some bias if you want.
    var r := randi() % 3
    match r:
        0:
            return "mining"
        1:
            return "agri"
        _:
            return "industrial"


func _pick_security(system_type: String) -> String:
    # Simple heuristic: industrial a bit safer, mining/agri more mixed
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
    # Very rough ranges by type
    match system_type:
        "mining":
            return randi_range(200_000, 3_000_000)
        "agri":
            return randi_range(500_000, 5_000_000)
        "industrial":
            return randi_range(2_000_000, 12_000_000)
        _:
            return randi_range(500_000, 5_000_000)


func _generate_system_name(system_type: String, index: int) -> String:
    var prefix := ""
    match system_type:
        "mining":
            prefix = "Pit"
        "agri":
            prefix = "Harvest"
        "industrial":
            prefix = "Forge"
        _:
            prefix = "Node"

    return "%s-%02d" % [prefix, index]


## ----------- LOCATION GENERATION -----------

func _generate_locations_for_system(system: Dictionary) -> Array:
    var locations: Array = []
    var count := randi_range(min_locations_per_system, max_locations_per_system)

    for i in count:
        var loc_id := "%s_LOC_%02d" % [system["id"], i]
        var loc_name := _generate_location_name(system, i)

        var has_dry_dock := false
        var has_crew := false

        # Simple rules: some systems get dry docks, some get crew hubs
        if i == 0 and system["system_type"] == "industrial":
            has_dry_dock = true
        elif i == 0 and system["system_type"] == "mining":
            has_crew = true
        else:
            # small random chance anywhere
            has_dry_dock = (randi() % 100) < 15
            has_crew = (randi() % 100) < 25

        var loc: Dictionary = {
            "id": loc_id,
            "name": loc_name,
            "has_market": true,
            "has_contracts_board": true,
            "has_dry_dock": has_dry_dock,
            "has_crew_hiring": has_crew
        }

        locations.append(loc)

    return locations


func _generate_location_name(system: Dictionary, index: int) -> String:
    var base := ""
    match system["system_type"]:
        "mining":
            base = "Station"
        "agri":
            base = "Agriport"
        "industrial":
            base = "Dock"
        _:
            base = "Port"

    return "%s %d" % [base, index + 1]


## ----------- WARP LANE CONNECTIONS -----------

func _connect_systems_line() -> void:
    # Connect all systems in a simple line so the graph is definitely connected.
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
    return systems[id]["neighbors"]


func find_path(start_id: String, target_id: String) -> Array:
    # Breadth-first search on the systems graph.
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

        var neighbors: Array = systems[current].get("neighbors", []) as Array
        for neighbor_variant in neighbors:
            var neighbor: String = str(neighbor_variant)
            if not came_from.has(neighbor):
                came_from[neighbor] = current
                queue.append(neighbor)

    if not came_from.has(target_id):
        # no path
        return []

    # Reconstruct path from target back to start
    var path: Array = []
    var node: String = target_id
    while node != "":
        path.push_front(node)
        node = came_from.get(node, "")

    return path
