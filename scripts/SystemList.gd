# res://scenes/SystemList.gd
extends Control

@onready var title_label: Label = $MainSplit/MarginContainer/VBoxContainer/TitleLabel
@onready var system_name_label: Label = $MainSplit/MarginContainer/VBoxContainer/CurrentSystemPanel/VBoxContainer/SystemNameLabel
@onready var system_type_label: Label = $MainSplit/MarginContainer/VBoxContainer/CurrentSystemPanel/VBoxContainer/SystemTypeLabel
@onready var security_label: Label = $MainSplit/MarginContainer/VBoxContainer/CurrentSystemPanel/VBoxContainer/SecurityLabel
@onready var population_label: Label = $MainSplit/MarginContainer/VBoxContainer/CurrentSystemPanel/VBoxContainer/PopulationLabel
@onready var dry_dock_label: Label = $MainSplit/MarginContainer/VBoxContainer/CurrentSystemPanel/VBoxContainer/DryDockLabel


@onready var dock_button: Button = $MainSplit/MarginContainer/VBoxContainer/DockButton
@onready var log_label: Label = $MainSplit/MarginContainer/VBoxContainer/LogLabel
@onready var log_list: ItemList = $MainSplit/MarginContainer/VBoxContainer/LogList
@onready var menu_button: Button = $MainSplit/MarginContainer/VBoxContainer/MenuButton

@onready var market_panel: Control = $MainSplit/MarketPanel


func _ready() -> void:
	title_label.text = "System Navigation"

	GameState._ensure_starting_system()

	# react to system changes (travel, auto-travel, etc.)
	GameState.system_changed.connect(_on_system_changed)

	# react to new log messages
	Log.message_added.connect(_on_log_message_added)

	#connect buttons
	dock_button.pressed.connect(_on_DockButton_pressed)
	menu_button.pressed.connect(_on_MenuButton_pressed)
	
	_refresh_ui()


func _refresh_ui() -> void:
	var sys_id: String = GameState.current_system_id
	if sys_id == "":
		system_name_label.text = "No system selected"
		system_type_label.text = ""
		security_label.text = ""
		population_label.text = ""
		dry_dock_label.text = ""
	else:
		var system: Dictionary = Galaxy.get_system(sys_id)
		if system.is_empty():
			system_name_label.text = "Unknown system"
			system_type_label.text = ""
			security_label.text = ""
			population_label.text = ""
			dry_dock_label.text = ""
		else:
			var sys_name: String = system.get("name", "???")
			var sys_type: String = system.get("system_type", "unknown")
			var sys_sec: String = system.get("security_level", "unknown")
			var sys_pop: int = int(system.get("population", 0))

			system_name_label.text = "Name: %s (%s)" % [sys_name, sys_id]
			system_type_label.text = "Type: %s" % sys_type
			security_label.text = "Security: %s" % sys_sec
			population_label.text = "Population: %s" % _format_population(sys_pop)

			var has_drydock: bool = Galaxy.system_has_drydock(sys_id)
			dry_dock_label.text = "Dry Dock: %s" % ("Yes" if has_drydock else "No")

	# refresh market panel for current system
	if is_instance_valid(market_panel) and market_panel.has_method("refresh_all"):
		market_panel.refresh_all()

	# refresh log UI
	_refresh_log()


func _refresh_log() -> void:
	log_list.clear()
	for msg in Log.messages:
		log_list.add_item(msg)

	var count: int = log_list.get_item_count()
	if count > 0:
		log_list.select(count - 1)
		log_list.ensure_current_is_visible()


func _format_population(pop: int) -> String:
	if pop >= 1_000_000:
		return "%.1f M" % (float(pop) / 1_000_000.0)
	elif pop >= 1_000:
		return "%.1f K" % (float(pop) / 1_000.0)
	return str(pop)


func _on_log_message_added() -> void:
	_refresh_log()


func _on_system_changed(new_system_id: String) -> void:
	_refresh_ui()


func _on_DockButton_pressed() -> void:
	var map_panel_scene: PackedScene = load("res://scenes/MapPanel.tscn")
	if map_panel_scene == null:
		push_error("Failed to load MapPanel.tscn")
		return

	var map_panel: Control = map_panel_scene.instantiate()
	add_child(map_panel)

	# Godot 4: anchors + offsets preset to fill parent
	map_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	map_panel.set_offsets_preset(Control.PRESET_FULL_RECT)

func _on_MenuButton_pressed() -> void:
	var menu_scene: PackedScene = load("res://scenes/MainMenuPanel.tscn")
	if menu_scene == null:
		push_error("Failed to load MainMenuPanel.tscn")
		return

	var menu_panel: Control = menu_scene.instantiate()
	add_child(menu_panel)

	menu_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_panel.set_offsets_preset(Control.PRESET_FULL_RECT)
