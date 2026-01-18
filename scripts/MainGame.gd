# res://scenes/MainGame.gd
extends Control

@onready var top_bar: HBoxContainer = $VBoxContainer/TopBar
@onready var game_title_label: Label = $VBoxContainer/TopBar/GameTitleLabel
@onready var system_label: Label = $VBoxContainer/TopBar/SystemLabel
@onready var bridge_button: Button = $VBoxContainer/TopBar/BridgeButton
@onready var port_button: Button = $VBoxContainer/TopBar/PortButton
@onready var quarters_button: Button = $VBoxContainer/TopBar/QuartersButton
@onready var money_label: Label = $VBoxContainer/TopBar/MoneyLabel

@onready var main_panel: PanelContainer = $VBoxContainer/ContentRow/MainPanel
@onready var main_view_container: Control = $VBoxContainer/ContentRow/MainPanel/MainViewContainer

# We’ll track what scene is currently loaded (optional, for debugging)
var current_view_path: String = ""
var _pending_port_open: bool = false


func _ready() -> void:
	game_title_label.text = "Tiny Cormorant"

	bridge_button.pressed.connect(_on_BridgeButton_pressed)
	port_button.pressed.connect(_on_PortButton_pressed)
	quarters_button.pressed.connect(_on_QuartersButton_pressed)

	GameState.system_changed.connect(_on_system_changed)
	GameState.ship_changed.connect(_on_ship_changed)
	GameState.location_changed.connect(_on_location_changed)

	_refresh_top_bar()

	# Default view: Bridge
	goto_bridge()


func _clear_main_view() -> void:
	for child in main_view_container.get_children():
		child.queue_free()


func _show_view(scene_path: String) -> void:
	if scene_path == "":
		return

	_clear_main_view()

	var packed: PackedScene = load(scene_path)
	if packed == null:
		push_error("Failed to load scene: %s" % scene_path)
		return

	var inst: Node = packed.instantiate()
	main_view_container.add_child(inst)

	if inst is Control:
		var c := inst as Control
		c.set_anchors_preset(Control.PRESET_FULL_RECT)

	current_view_path = scene_path


func _refresh_top_bar() -> void:
	# System name
	var sys_id: String = GameState.current_system_id
	if sys_id == "":
		system_label.text = "System: (unknown)"
	else:
		var system: Dictionary = Galaxy.get_system(sys_id)
		var sys_name: String = system.get("name", sys_id)
		system_label.text = "System: %s" % sys_name

	# Credits
	money_label.text = "Credits: %.0f" % GameState.player_money


# --- button handlers ---

func _on_BridgeButton_pressed() -> void:
	goto_bridge()


func _on_PortButton_pressed() -> void:
	goto_port()


func _on_QuartersButton_pressed() -> void:
	_show_view("res://scenes/CaptainsQuarters.tscn")


# --- GameState signal handlers ---

func _on_system_changed(new_system_id: String) -> void:
	_refresh_top_bar()


func _on_ship_changed() -> void:
	_refresh_top_bar()

func _on_location_changed(new_location_id: String) -> void:
	if not _pending_port_open:
		return

	if new_location_id == "":
		return

	_pending_port_open = false
	goto_port()

func goto_bridge() -> void:
	_show_view("res://scenes/Bridge.tscn")


func goto_port() -> void:
	if GameState.current_location_id == "":
		_pending_port_open = true
		Log.add_entry("Select a location to dock.")
		_show_view("res://scenes/MapPanel.tscn")
		return

	_pending_port_open = false
	_show_view("res://scenes/Port.tscn")
