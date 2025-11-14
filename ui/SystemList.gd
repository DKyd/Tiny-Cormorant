# res://ui/SystemList.gd
extends Control

@onready var title_label: Label = $MainSplit/MarginContainer/VBoxContainer/TitleLabel
@onready var system_name_label: Label = $MainSplit/MarginContainer/VBoxContainer/CurrentSystemPanel/VBoxContainer/SystemNameLabel
@onready var system_type_label: Label = $MainSplit/MarginContainer/VBoxContainer/CurrentSystemPanel/VBoxContainer/SystemTypeLabel
@onready var security_label: Label = $MainSplit/MarginContainer/VBoxContainer/CurrentSystemPanel/VBoxContainer/SecurityLabel
@onready var population_label: Label = $MainSplit/MarginContainer/VBoxContainer/CurrentSystemPanel/VBoxContainer/PopulationLabel

@onready var dock_button: Button = $MainSplit/MarginContainer/VBoxContainer/DockButton
@onready var log_label: Label = $MainSplit/MarginContainer/VBoxContainer/LogLabel
@onready var log_list: ItemList = $MainSplit/MarginContainer/VBoxContainer/LogList

@onready var market_panel: Control = $MainSplit/MarketPanel


func _ready() -> void:
    title_label.text = "System Navigation"

    GameState._ensure_starting_system()

	# listne for system changes
    GameState.system_changed.connect(_on_system_changed)

    # listen for log updates
    Log.message_added.connect(_on_log_message_added)

    # dock / open map
    dock_button.pressed.connect(_on_DockButton_pressed)

    _refresh_ui()


func _refresh_ui() -> void:
    var sys_id: String = GameState.current_system_id
    if sys_id == "":
        system_name_label.text = "No system selected"
        system_type_label.text = ""
        security_label.text = ""
        population_label.text = ""
    else:
        var system: Dictionary = Galaxy.get_system(sys_id)
        if system.is_empty():
            system_name_label.text = "Unknown system"
            system_type_label.text = ""
            security_label.text = ""
            population_label.text = ""
        else:
            var sys_name: String = system.get("name", "???")
            var sys_type: String = system.get("system_type", "unknown")
            var sys_sec: String = system.get("security_level", "unknown")
            var sys_pop: int = int(system.get("population", 0))

            system_name_label.text = "Name: %s (%s)" % [sys_name, sys_id]
            system_type_label.text = "Type: %s" % sys_type
            security_label.text = "Security: %s" % sys_sec
            population_label.text = "Population: %s" % _format_population(sys_pop)

    # refresh market panel for this system
    if is_instance_valid(market_panel) and market_panel.has_method("refresh_all"):
        market_panel.refresh_all()

    # refresh log UI
    _refresh_log()


func _refresh_log() -> void:
    log_list.clear()
    for msg in Log.messages:
        log_list.add_item(msg)
    # optional: keep last message in view
    if log_list.get_item_count() > 0:
        log_list.select(log_list.get_item_count() - 1)
        log_list.ensure_current_is_visible()


func _format_population(pop: int) -> String:
    if pop >= 1_000_000:
        return "%.1f M" % (float(pop) / 1_000_000.0)
    elif pop >= 1_000:
        return "%.1f K" % (float(pop) / 1_000.0)
    return str(pop)


func _on_log_message_added() -> void:
    _refresh_log()


func _on_DockButton_pressed() -> void:
    var map_panel_scene: PackedScene = load("res://scenes/MapPanel.tscn")
    if map_panel_scene == null:
        push_error("Failed to load MapPanel.tscn")
        return

    var map_panel: Control = map_panel_scene.instantiate()
    add_child(map_panel)

    map_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    map_panel.set_offsets_preset(Control.PRESET_FULL_RECT)

func _on_system_changed(new_system_id: String) -> void:
    _refresh_ui()