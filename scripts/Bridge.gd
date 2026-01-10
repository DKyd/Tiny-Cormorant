extends Control

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var system_label: Label = $MarginContainer/VBoxContainer/StatusRow/SystemLabel
@onready var location_label: Label = $MarginContainer/VBoxContainer/StatusRow/LocationLabel
@onready var security_label: Label = $MarginContainer/VBoxContainer/StatusRow/SecurityLabel
@onready var population_label: Label = $MarginContainer/VBoxContainer/StatusRow/PopulationLabel
@onready var docs_button: Button = $MarginContainer/VBoxContainer/StatusRow/DocsButton
@onready var to_port_button: Button = $MarginContainer/VBoxContainer/StatusRow/ToPortButton
@onready var map_host: Control = $MarginContainer/VBoxContainer/MainPanel/MapHost


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


func _load_map_panel() -> void:
	for child in map_host.get_children():
		child.queue_free()

	var packed: PackedScene = load("res://scenes/MapPanel.tscn")
	if packed == null:
		push_error("Bridge: failed to load MapPanel.tscn")
		return

	var panel: Control = packed.instantiate()
	map_host.add_child(panel)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)


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
	# map_panel already listens to system changes for travel, so no reload needed


func _on_location_changed(new_location_id: String) -> void:
	_refresh_status()
