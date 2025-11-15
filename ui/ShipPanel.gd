# res://scenes/ShipPanel.gd
extends Control

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var ship_name_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ShipNameLabel
@onready var engine_label: Label = $PanelContainer/MarginContainer/VBoxContainer/EngineLabel
@onready var cargo_capacity_label: Label = $PanelContainer/MarginContainer/VBoxContainer/CargoCapacityLabel
@onready var cargo_usage_label: Label = $PanelContainer/MarginContainer/VBoxContainer/CargoUsageLabel
@onready var engine_upgrade_button: Button = $PanelContainer/MarginContainer/VBoxContainer/EngineUpgradeButton
@onready var cargo_upgrade_button: Button = $PanelContainer/MarginContainer/VBoxContainer/CargoUpgradeButton
@onready var hint_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HintLabel
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/CloseButton


func _ready() -> void:
    title_label.text = "Ship Status"

    _refresh_info()
    _refresh_buttons()

    engine_upgrade_button.pressed.connect(_on_EngineUpgradeButton_pressed)
    cargo_upgrade_button.pressed.connect(_on_CargoUpgradeButton_pressed)
    close_button.pressed.connect(_on_CloseButton_pressed)


func _refresh_info() -> void:
    ship_name_label.text = "Name: %s" % GameState.ship_name
    engine_label.text = "Engine Level: %d" % GameState.ship_engine_level

    var capacity: float = GameState.cargo_capacity_weight
    var used: float = _calculate_cargo_weight()
    cargo_capacity_label.text = "Cargo Capacity: %.1f" % capacity
    cargo_usage_label.text = "Cargo Used: %.1f / %.1f" % [used, capacity]


func _refresh_buttons() -> void:
    var has_drydock: bool = Galaxy.system_has_drydock(GameState.current_system_id)

    # Engine upgrade button
    if GameState.ship_engine_level >= GameState.MAX_ENGINE_LEVEL:
        engine_upgrade_button.text = "Engine Max Level (%d)" % GameState.ship_engine_level
        engine_upgrade_button.disabled = true
    else:
        var eng_cost: float = GameState.get_engine_upgrade_cost()
        var next_level: int = GameState.ship_engine_level + 1
        engine_upgrade_button.text = "Upgrade Engine to L%d (%.0f cr)" % [next_level, eng_cost]
        engine_upgrade_button.disabled = (not has_drydock or GameState.player_money < eng_cost)

    # Cargo upgrade button
    if GameState.cargo_hold_level >= GameState.MAX_CARGO_HOLD_LEVEL:
        cargo_upgrade_button.text = "Cargo Hold Max Level (%d)" % GameState.cargo_hold_level
        cargo_upgrade_button.disabled = true
    else:
        var cargo_cost: float = GameState.get_cargo_hold_upgrade_cost()
        var next_cargo_level: int = GameState.cargo_hold_level + 1
        cargo_upgrade_button.text = "Upgrade Cargo Hold to L%d (%.0f cr)" % [next_cargo_level, cargo_cost]
        cargo_upgrade_button.disabled = (not has_drydock or GameState.player_money < cargo_cost)

    if not has_drydock:
        hint_label.text = "No dry dock at this system. Travel to a system with a dry dock to upgrade."
    else:
        hint_label.text = "Dry dock available: upgrade your engine and cargo hold here."


func _calculate_cargo_weight() -> float:
    var total: float = 0.0
    for commodity_id_variant in GameState.cargo.keys():
        var commodity_id: String = str(commodity_id_variant)
        var qty: int = int(GameState.cargo[commodity_id_variant])
        if qty <= 0:
            continue

        var commodity: Dictionary = CommodityDB.get_commodity(commodity_id)
        var weight_per_unit: float = float(commodity.get("weight_per_unit", 1.0))
        total += weight_per_unit * float(qty)

    return total


func _on_EngineUpgradeButton_pressed() -> void:
    GameState.upgrade_engine()
    _refresh_info()
    _refresh_buttons()


func _on_CargoUpgradeButton_pressed() -> void:
    GameState.upgrade_cargo_hold()
    _refresh_info()
    _refresh_buttons()


func _on_CloseButton_pressed() -> void:
    queue_free()
