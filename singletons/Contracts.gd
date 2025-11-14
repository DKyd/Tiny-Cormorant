extends Node

# Simple travel contract: go from origin -> destination and get paid
# {
#   "id": String,
#   "origin": String,
#   "destination": String,
#   "reward": float,
#   "jumps": int
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

        result.append({
            "id": _next_id(),
            "origin": system_id,
            "destination": dest_id,
            "destination_name": dest_name,
            "jumps": jumps,
            "reward": reward
        })

    return result
