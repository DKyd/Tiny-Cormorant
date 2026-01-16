extends Control

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var system_label: Label = $MarginContainer/VBoxContainer/StatusRow/SystemLabel
@onready var location_label: Label = $MarginContainer/VBoxContainer/StatusRow/LocationLabel
@onready var security_label: Label = $MarginContainer/VBoxContainer/StatusRow/SecurityLabel
@onready var population_label: Label = $MarginContainer/VBoxContainer/StatusRow/PopulationLabel
@onready var docs_button: Button = $MarginContainer/VBoxContainer/StatusRow/DocsButton
@onready var to_port_button: Button = $MarginContainer/VBoxContainer/StatusRow/ToPortButton
@onready var map_host: Control = $MarginContainer/VBoxContainer/MainPanel/MapHost

const WAIT_TICKS: int = 3

var _map_panel: Node = null

func _ready() -> void:
	title_label.text = "Bridge"

	_refresh_status()
	_load_map_panel()

	docs_button.pressed.connect(_on_DocsButton_pressed)
	to_port_button.pressed.connect(_on_ToPortButton_pressed)

	GameState.system_changed.connect(_on_system_changed)
	GameState.location_changed.connect(_on_location_changed)


func _refresh_status() -> void:
	var sys_id: String = GameState.current_system_id
	if sys_id == "":
		system_label.text = "System: (unknown)"
		location_label.text = "Location: (unknown)"
		security_label.text = "Security: -"
		population_label.text = "Pop: -"
		_update_port_button_state()
		return

	var system: Dictionary = Galaxy.get_system(sys_id)
	var name: String = system.get("name", sys_id)
	var sec: String = system.get("security_level", "medium")
	var pop: int = int(system.get("population", 0))
	var loc: Dictionary = GameState.get_current_location()
	var loc_name: String = ""
	if not loc.is_empty():
		loc_name = String(loc.get("name", ""))

	system_label.text = "System: %s" % name
	if loc_name == "":
		location_label.text = "Location: (unknown)"
	else:
		location_label.text = "Location: %s" % loc_name
	security_label.text = "Security: %s" % sec.capitalize()
	if pop > 0:
		population_label.text = "Pop: %d" % pop
	else:
		population_label.text = "Pop: -"
	_update_port_button_state()

func _update_port_button_state() -> void:
	var has_port_access := false
	if GameState.current_location_id != "":
		var loc: Dictionary = GameState.get_current_location()
		if not loc.is_empty():
			var spaces: Array = loc.get("spaces", [])
			# TODO: Use a dedicated port-access flag when one exists.
			has_port_access = spaces.size() > 0
	to_port_button.disabled = not has_port_access


func _load_map_panel() -> void:
	for child in map_host.get_children():
		child.queue_free()

	var packed: PackedScene = load("res://scenes/MapPanel.tscn")
	if packed == null:
		push_error("Bridge: failed to load MapPanel.tscn")
		return

	var panel: Control = packed.instantiate()
	_map_panel = panel
	map_host.add_child(panel)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_wire_map_panel(panel)

func _ensure_map_panel() -> void:
	if not is_instance_valid(_map_panel) or _map_panel.get_parent() != map_host:
		_load_map_panel()

func _wire_map_panel(panel: Node) -> void:
	if panel == null:
		return
	if panel.has_signal("navigate_to_system_requested"):
		panel.connect("navigate_to_system_requested", Callable(self, "_on_map_navigate_to_system_requested"))
	if panel.has_signal("navigate_to_location_requested"):
		panel.connect("navigate_to_location_requested", Callable(self, "_on_map_navigate_to_location_requested"))
	if panel.has_signal("close_requested"):
		panel.connect("close_requested", Callable(self, "_on_map_close_requested"))

func _on_DocsButton_pressed() -> void:
	var packed: PackedScene = load("res://scenes/FreightDocsPanel.tscn")
	if packed == null:
		push_error("Bridge: failed to load FreightDocsPanel.tscn")
		return

	var panel: Control = packed.instantiate()
	var root: Node = get_tree().current_scene
	if root == null:
		root = get_tree().root
	root.add_child(panel)
	if panel is Control:
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)


func _on_ToPortButton_pressed() -> void:
	var root := get_tree().current_scene
	if root != null and root.has_method("goto_port"):
		root.call_deferred("goto_port")


func _on_system_changed(new_system_id: String) -> void:
	_refresh_status()
	_ensure_map_panel()

	if _map_panel != null and is_instance_valid(_map_panel) and _map_panel.has_method("request_refresh"):
		_map_panel.call_deferred("request_refresh")
	else:
		# Fallback: if the reference is missing or method not found, reload the panel
		_load_map_panel()


func _on_location_changed(new_location_id: String) -> void:
	_refresh_status()

func _on_map_navigate_to_system_requested(dest_system_id: String) -> void:
	if dest_system_id == "":
		Log.add_entry("Travel failed: invalid destination.")
		return

	if dest_system_id == GameState.current_system_id:
		Log.add_entry("Already in that system.")
		return

	var path: Array = Galaxy.find_path(GameState.current_system_id, dest_system_id)
	if path.is_empty() or path.size() < 2:
		Log.add_entry("No route from here to that system.")
		return

	var hops: int = path.size() - 1
	Log.add_entry("Setting course to %s (%d jumps)." % [dest_system_id, hops])
	GameState.auto_travel(path)
	_refresh_status()
	_ensure_map_panel()
	if _map_panel != null and is_instance_valid(_map_panel) and _map_panel.has_method("request_refresh"):
		_map_panel.call_deferred("request_refresh")

func _on_map_navigate_to_location_requested(dest_system_id: String, dest_location_id: String) -> void:
	if dest_location_id == "":
		Log.add_entry("Docking failed: invalid destination.")
		return

	var loc: Dictionary = Galaxy.get_location(dest_location_id)
	if loc.is_empty():
		Log.add_entry("Docking failed: unknown destination.")
		return

	var loc_system_id: String = String(loc.get("system_id", ""))
	if dest_system_id != "" and loc_system_id != "" and dest_system_id != loc_system_id:
		Log.add_entry("Docking failed: location is not in that system.")
		return

	var target_system_id := dest_system_id
	if target_system_id == "":
		target_system_id = loc_system_id

	if target_system_id == "":
		Log.add_entry("Docking failed: unknown destination.")
		return

	if target_system_id != GameState.current_system_id:
		var path: Array = Galaxy.find_path(GameState.current_system_id, target_system_id)
		if path.is_empty() or path.size() < 2:
			Log.add_entry("No route from here to that system.")
			return

		var hops: int = path.size() - 1
		Log.add_entry("Setting course to %s (%d jumps)." % [target_system_id, hops])
		GameState.auto_travel(path)
		_refresh_status()
		_ensure_map_panel()
		if _map_panel != null and is_instance_valid(_map_panel) and _map_panel.has_method("request_refresh"):
			_map_panel.call_deferred("request_refresh")
		if GameState.current_system_id != target_system_id:
			Log.add_entry("Auto-travel stopped before reaching destination.")
			return

	var loc_name: String = String(loc.get("name", dest_location_id))
	Log.add_entry("Docking at %s." % loc_name)
	GameState.set_current_location(dest_location_id)
	_refresh_status()
	_ensure_map_panel()
	if _map_panel != null and is_instance_valid(_map_panel) and _map_panel.has_method("request_refresh"):
		_map_panel.call_deferred("request_refresh")

func _on_map_close_requested() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode != KEY_W:
			return

		if GameState.current_location_id == "":
			Log.add_entry("You must be docked to wait.")
			return

		Log.add_entry("Waited dockside (%d ticks)." % WAIT_TICKS)
		for _i in range(WAIT_TICKS):
			GameState.advance_time("Waited dockside")
