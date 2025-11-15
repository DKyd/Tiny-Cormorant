# res://singletons/GameState.gd
extends Node

var current_system_id: String = ""
var player_money: float = 10_000.0  # starter money

# Very simple cargo model: { commodity_id: quantity }
var cargo: Dictionary = {}
var cargo_capacity_weight: float = 100.0  # tweak later

# travel cost tuning
var low_security_travel_cost: float = 30.0
var medium_security_travel_cost: float = 50.0
var high_security_travel_cost: float = 80.0

# Contracts offered in system
var active_contracts: Array = []  # array of contract dictionaries

signal system_changed(new_system_id: String)

func _ready() -> void:
    _ensure_starting_system()


func _ensure_starting_system() -> void:
    if current_system_id != "":
        return

    var ids: Array = Galaxy.get_all_system_ids()
    if ids.size() > 0:
        current_system_id = ids[0]


func travel_to_system(new_system_id: String) -> void:
    var system: Dictionary = Galaxy.get_system(new_system_id)
    if system.is_empty():
        push_warning("Unknown system.")
        Log.add("Travel failed: unknown system.")
        return

    var cost := get_travel_cost(new_system_id)
    if cost > player_money:
        Log.add("Not enough credits to travel (need %.0f)." % cost)
        push_warning("Not enough credits to travel.")
        return

    player_money -= cost
    current_system_id = new_system_id
    
    Log.add("Traveled to %s (-%.0f cr)" % [new_system_id, cost])
    emit_signal("system_changed", current_system_id)
    print("Traveled to system: %s (cost %.0f, remaining %.0f)" % [new_system_id, cost, player_money])

	# checks for contract fulfillment on arrival
    check_travel_contracts_at(current_system_id)

func get_cargo_quantity(commodity_id: String) -> int:
    return int(cargo.get(commodity_id, 0))


func add_cargo(commodity_id: String, quantity: int) -> void:
    if quantity == 0:
        return
    var current_qty: int = get_cargo_quantity(commodity_id)
    cargo[commodity_id] = current_qty + quantity


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

func get_travel_cost(dest_system_id: String) -> float:
    var system: Dictionary = Galaxy.get_system(dest_system_id)
    if system.is_empty():
        return 0.0

    var sec: String = system.get("security_level", "medium")

    match sec:
        "low":
            return low_security_travel_cost
        "high":
            return high_security_travel_cost
        _:
            return medium_security_travel_cost


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
            Log.add("Auto-travel stopped: not enough credits to reach %s." % dest_id)
            break

        travel_to_system(dest_id)
        # travel_to_system already logs and charges

func add_contract(contract: Dictionary) -> void:
    active_contracts.append(contract.duplicate(true))
    Log.add("Accepted contract to %s (%d jumps) for %.0f cr."
      % [contract.get("destination_name", contract.get("destination", "?")),
        int(contract.get("jumps", 0)),
        float(contract.get("reward", 0.0))])

func check_travel_contracts_at(system_id: String) -> void:
    if active_contracts.is_empty():
        return

    var remaining: Array = []
    for contract_variant in active_contracts:
        var contract: Dictionary = contract_variant
        var dest_id: String = contract.get("destination", "")
        if dest_id == "" or dest_id != system_id:
            remaining.append(contract)
            continue

        var reward: float = float(contract.get("reward", 0.0))
        var dest_name: String = contract.get("destination_name", dest_id)
        player_money += reward
        Log.add("Completed contract to %s, earned %.0f cr." % [dest_name, reward])

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
            Log.add("Abandoned contract to %s." % dest_name)
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
        "player_money": player_money,
        "cargo": cargo,
        "active_contracts": active_contracts,
        "galaxy_systems": Galaxy.systems,
    }

    file.store_var(data, true)
    Log.add("Game saved.")


func load_game() -> void:
    var path := "user://savegame.dat"
    if not FileAccess.file_exists(path):
        Log.add("No save file found.")
        return

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Failed to open save file for reading.")
        return

    var data: Dictionary = file.get_var(true)

    current_system_id = data.get("current_system_id", current_system_id)
    player_money = data.get("player_money", player_money)
    cargo = data.get("cargo", {})
    active_contracts = data.get("active_contracts", [])

    var saved_systems: Dictionary = data.get("galaxy_systems", {})
    if not saved_systems.is_empty():
        Galaxy.systems = saved_systems

    # Safety: ensure we end up in a valid system
    if current_system_id == "" or Galaxy.get_system(current_system_id).is_empty():
        _ensure_starting_system()

    Log.add("Game loaded.")
    emit_signal("system_changed", current_system_id)
