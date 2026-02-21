# res://scenes/MainGame.gd
extends Control

@onready var top_bar: HBoxContainer = $VBoxContainer/TopBar
@onready var game_title_label: Label = $VBoxContainer/TopBar/GameTitleLabel
@onready var system_label: Label = $VBoxContainer/TopBar/SystemLabel
@onready var bridge_button: Button = $VBoxContainer/TopBar/BridgeButton
@onready var port_button: Button = $VBoxContainer/TopBar/PortButton
@onready var quarters_button: Button = $VBoxContainer/TopBar/QuartersButton

@onready var main_panel: PanelContainer = $VBoxContainer/ContentRow/MainPanel
@onready var main_view_container: Control = $VBoxContainer/ContentRow/MainPanel/MainViewContainer

# We'll track what scene is currently loaded (optional, for debugging)
var current_view_path: String = ""
var _pending_port_open: bool = false
const IN_SESSION_MENU_SCENE_PATH: String = "res://scenes/ui/InSessionMenu.tscn"
const MAP_PANEL_SCENE_PATH: String = "res://scenes/MapPanel.tscn"
const FEEDBACK_CAPTURE_ACTION: StringName = &"feedback_capture"
var _in_session_menu: Control
var _menu_open: bool = false


func _ready() -> void:
	game_title_label.text = "Tiny Cormorant"

	bridge_button.pressed.connect(_on_BridgeButton_pressed)
	port_button.pressed.connect(_on_PortButton_pressed)
	quarters_button.pressed.connect(_on_QuartersButton_pressed)

	GameState.system_changed.connect(_on_system_changed)
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

	if scene_path == MAP_PANEL_SCENE_PATH:
		_wire_map_panel(inst)

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


func _wire_map_panel(panel: Node) -> void:
	if panel == null:
		return

	var cb_sys := Callable(self, "_on_map_navigate_to_system_requested")
	var cb_loc := Callable(self, "_on_map_navigate_to_location_requested")
	var cb_close := Callable(self, "_on_map_close_requested")

	if panel.has_signal("navigate_to_system_requested") and not panel.is_connected("navigate_to_system_requested", cb_sys):
		panel.connect("navigate_to_system_requested", cb_sys)
	if panel.has_signal("navigate_to_location_requested") and not panel.is_connected("navigate_to_location_requested", cb_loc):
		panel.connect("navigate_to_location_requested", cb_loc)
	if panel.has_signal("close_requested") and not panel.is_connected("close_requested", cb_close):
		panel.connect("close_requested", cb_close)


func _on_map_navigate_to_system_requested(dest_system_id: String) -> void:
	if dest_system_id == "":
		Log.add_entry("Travel failed: invalid destination.", "SHIP")
		return

	if dest_system_id == GameState.current_system_id:
		Log.add_entry("Already in that system.", "SHIP")
		return

	var path: Array = Galaxy.find_path(GameState.current_system_id, dest_system_id)
	if path.is_empty() or path.size() < 2:
		Log.add_entry("No route from here to that system.", "SHIP")
		return

	var hops: int = path.size() - 1
	Log.add_entry("Setting course to %s (%d jumps)." % [dest_system_id, hops], "SHIP")
	GameState.auto_travel(path)
	_refresh_top_bar()


func _on_map_navigate_to_location_requested(dest_system_id: String, dest_location_id: String) -> void:
	if dest_location_id == "":
		Log.add_entry("Docking failed: invalid destination.", "SHIP")
		return

	var loc: Dictionary = Galaxy.get_location(dest_location_id)
	if loc.is_empty():
		Log.add_entry("Docking failed: unknown destination.", "SHIP")
		return

	var loc_system_id: String = String(loc.get("system_id", ""))
	if dest_system_id != "" and loc_system_id != "" and dest_system_id != loc_system_id:
		Log.add_entry("Docking failed: location is not in that system.", "SHIP")
		return

	var target_system_id := dest_system_id
	if target_system_id == "":
		target_system_id = loc_system_id

	if target_system_id == "":
		Log.add_entry("Docking failed: unknown destination.", "SHIP")
		return

	if target_system_id != GameState.current_system_id:
		var path: Array = Galaxy.find_path(GameState.current_system_id, target_system_id)
		if path.is_empty() or path.size() < 2:
			Log.add_entry("No route from here to that system.", "SHIP")
			return

		var hops: int = path.size() - 1
		Log.add_entry("Setting course to %s (%d jumps)." % [target_system_id, hops], "SHIP")
		GameState.auto_travel(path)
		_refresh_top_bar()
		if GameState.current_system_id != target_system_id:
			Log.add_entry("Auto-travel stopped before reaching destination.", "SHIP")
			return

	var loc_name: String = String(loc.get("name", dest_location_id))
	Log.add_entry("Docking at %s." % loc_name, "SHIP")
	GameState.set_current_location(dest_location_id)
	_refresh_top_bar()


func _on_map_close_requested() -> void:
	_pending_port_open = false
	goto_bridge()


func _input(event: InputEvent) -> void:
	# Ignore key repeat events
	if event is InputEventKey and event.echo:
		return

	var capture_pressed: bool = false

	# Preferred: InputMap action if it exists
	if InputMap.has_action(FEEDBACK_CAPTURE_ACTION):
		if event.is_action_pressed(FEEDBACK_CAPTURE_ACTION):
			capture_pressed = true

	# Fallback: raw numpad + key
	elif event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and key_event.keycode == KEY_KP_ADD:
			capture_pressed = true

	if capture_pressed:
		_try_feedback_capture()
		get_viewport().set_input_as_handled()


func _try_feedback_capture() -> void:
	var feedback_capture: Node = get_node_or_null("/root/FeedbackCapture")

	if feedback_capture != null and feedback_capture.has_method("capture"):
		feedback_capture.call("capture")
		Log.add_entry("DEV: Feedback captured (see user://feedback/).", "OTHER", true)
		return

	Log.add_entry(
		"DEV: Feedback capture unavailable: /root/FeedbackCapture autoload missing.",
		"OTHER",
		true
	)

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
		_show_view(MAP_PANEL_SCENE_PATH)
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
