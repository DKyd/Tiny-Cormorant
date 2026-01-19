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
const IN_SESSION_MENU_SCENE_PATH: String = "res://scenes/ui/InSessionMenu.tscn"
var _in_session_menu: Control
var _menu_open: bool = false


func _ready() -> void:
	game_title_label.text = "Tiny Cormorant"

	bridge_button.pressed.connect(_on_BridgeButton_pressed)
	port_button.pressed.connect(_on_PortButton_pressed)
	quarters_button.pressed.connect(_on_QuartersButton_pressed)

	GameState.system_changed.connect(_on_system_changed)
	GameState.ship_changed.connect(_on_ship_changed)
	GameState.location_changed.connect(_on_location_changed)

	_refresh_top_bar()
	_ensure_in_session_menu()

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


func _ensure_in_session_menu() -> void:
	if _in_session_menu != null:
		return

	var packed: PackedScene = load(IN_SESSION_MENU_SCENE_PATH)
	if packed == null:
		push_error("MainGame: failed to load InSessionMenu scene.")
		return

	var inst: Node = packed.instantiate()
	add_child(inst)

	if inst is Control:
		var c := inst as Control
		c.set_anchors_preset(Control.PRESET_FULL_RECT)
		c.visible = false
		_in_session_menu = c

	if _in_session_menu == null:
		return

	if _in_session_menu.has_signal("resume_requested"):
		_in_session_menu.connect("resume_requested", Callable(self, "_on_menu_resume_requested"))
	if _in_session_menu.has_signal("quit_to_menu_requested"):
		_in_session_menu.connect("quit_to_menu_requested", Callable(self, "_on_menu_quit_to_menu_requested"))
	if _in_session_menu.has_signal("quit_to_desktop_requested"):
		_in_session_menu.connect("quit_to_desktop_requested", Callable(self, "_on_menu_quit_to_desktop_requested"))


func _set_in_session_menu_visible(show: bool) -> void:
	if _in_session_menu == null:
		return
	_in_session_menu.visible = show
	_menu_open = show


func _set_menu_status(text: String) -> void:
	if _in_session_menu == null:
		return
	if _in_session_menu.has_method("set_status"):
		_in_session_menu.call("set_status", text)


func _consume_input() -> void:
	get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_ESCAPE:
			_ensure_in_session_menu()
			if _menu_open:
				_set_in_session_menu_visible(false)
			else:
				_set_in_session_menu_visible(true)
			_consume_input()
			return

	if _menu_open:
		_consume_input()


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


func _on_menu_resume_requested() -> void:
	_set_in_session_menu_visible(false)


func _on_menu_quit_to_menu_requested() -> void:
	var result: int = get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	if result != OK:
		push_error("MainGame: failed to return to MainMenu (%d)." % result)
		_set_menu_status("Failed to return to Main Menu.")


func _on_menu_quit_to_desktop_requested() -> void:
	get_tree().quit()
