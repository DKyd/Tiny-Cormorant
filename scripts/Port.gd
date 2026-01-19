extends Control

@onready var title_label: Label = $MarginContainer/VBoxContainer/HeaderRow/TitleLabel
@onready var system_info_label: Label = $MarginContainer/VBoxContainer/HeaderRow/SystemInfoLabel
@onready var to_bridge_button: Button = $MarginContainer/VBoxContainer/HeaderRow/ToBridgeButton

@onready var market_button: Button = $MarginContainer/VBoxContainer/FacilitiesRow/MarketButton
@onready var contracts_button: Button = $MarginContainer/VBoxContainer/FacilitiesRow/ContractsButton
@onready var ship_button: Button = $MarginContainer/VBoxContainer/FacilitiesRow/ShipButton
@onready var cantina_button: Button = $MarginContainer/VBoxContainer/FacilitiesRow/CantinaButton
@onready var docs_button: Button = $MarginContainer/VBoxContainer/FacilitiesRow/DocsButton
@onready var customs_button: Button = $MarginContainer/VBoxContainer/FacilitiesRow/CustomsButton

@onready var facility_host: Control = $MarginContainer/VBoxContainer/FacilityPanel/FacilityHost


func _ready() -> void:
	print("Port: _ready called")

	title_label.text = "Port"

	_refresh_header()
	_refresh_facility_buttons()

	# Debug prints to confirm the buttons are not null
	print("Port: market_button =", market_button)
	print("Port: facility_host =", facility_host)

	if market_button:
		market_button.pressed.connect(_on_MarketButton_pressed)
	else:
		push_error("Port: market_button is null")

	to_bridge_button.pressed.connect(_on_ToBridgeButton_pressed)
	contracts_button.pressed.connect(_on_ContractsButton_pressed)
	ship_button.pressed.connect(_on_ShipButton_pressed)
	cantina_button.pressed.connect(_on_CantinaButton_pressed)
	docs_button.pressed.connect(_on_DocsButton_pressed)

	if customs_button and not customs_button.pressed.is_connected(_on_customs_pressed):
		customs_button.pressed.connect(_on_customs_pressed)


	GameState.system_changed.connect(_on_system_changed)
	GameState.location_changed.connect(_on_location_changed)

	# Default view: show Market only if available at current location
	if _location_has_space("market"):
		_show_market()
	else:
		_clear_facility_host()


# ---------------------------------------------------
# INFO / HEADER
# ---------------------------------------------------

func _refresh_header() -> void:
	var sys_id: String = GameState.current_system_id
	var loc: Dictionary = GameState.get_current_location()

	if sys_id == "":
		system_info_label.text = "(unknown system)"
		return

	var system: Dictionary = Galaxy.get_system(sys_id)
	var sys_name: String = system.get("name", sys_id)
	var sys_type: String = system.get("system_type", "unknown")
	var sec: String = system.get("security_level", "medium")

	var loc_name: String = ""
	var loc_type: String = ""
	if not loc.is_empty():
		loc_name = loc.get("name", "")
		loc_type = loc.get("type", "")

	if loc_name != "":
		system_info_label.text = "%s / %s  [%s, %s]" % [
			sys_name,
			loc_name,
			sys_type.capitalize(),
			sec.capitalize()
		]
	else:
		system_info_label.text = "%s  [%s, %s]" % [
			sys_name,
			sys_type.capitalize(),
			sec.capitalize()
		]


func _location_has_space(space_name: String) -> bool:
	var loc: Dictionary = GameState.get_current_location()
	if loc.is_empty():
		return false
	var spaces: Array = loc.get("spaces", []) as Array
	return space_name in spaces


func _refresh_facility_buttons() -> void:
	# Enable/disable buttons based on location spaces.
	# This is where "location type" starts to matter.

	var has_market := _location_has_space("market")
	var has_gov := _location_has_space("gov_office")
	var has_dry_dock := _location_has_space("dry_dock")
	var has_cantina := _location_has_space("cantina") or _location_has_space("back_room")

	# Market: only if location has "market"
	market_button.disabled = not has_market

	# Contracts: for now, assume regular contracts board lives with market
	# Later we can add separate Gov vs Smuggler boards.
	contracts_button.disabled = not has_market

	# Ship: only if location has dry dock
	ship_button.disabled = not has_dry_dock

	# Cantina: only if location has a cantina space
	cantina_button.disabled = not has_cantina

	# Docs: always accessible (ship’s paperwork travels with the ship)
	docs_button.disabled = false
	customs_button.disabled = GameState.current_location_id == ""

	# You can also add visual hints later, like changing button text color
	# or tooltips based on which spaces exist.


# ---------------------------------------------------
# FACILITY HOST MANAGEMENT
# ---------------------------------------------------

func _clear_facility_host() -> void:
	for child in facility_host.get_children():
		child.queue_free()


func _show_market() -> void:
	if market_button.disabled:
		Log.add_entry("No market facilities at this location.")
		return

	print("Port: _show_market called")
	_clear_facility_host()

	var packed: PackedScene = load("res://scenes/MarketPanel.tscn")
	if packed == null:
		push_error("Port: failed to load MarketPanel.tscn")
		return

	var panel := packed.instantiate()
	print("Port: instantiated MarketPanel =", panel)

	facility_host.add_child(panel)
	if panel is Control:
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)


func _show_contracts() -> void:
	if contracts_button.disabled:
		Log.add_entry("No public contract boards at this location.")
		return

	print("Port: _show_contracts called")
	_clear_facility_host()

	# Use the existing job board scene for now
	var packed: PackedScene = load("res://scenes/JobBoardPanel.tscn")
	if packed == null:
		push_error("Port: failed to load JobBoardPanel.tscn")
		return

	var panel := packed.instantiate()
	facility_host.add_child(panel)
	if panel is Control:
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)


func _show_ship() -> void:
	if ship_button.disabled:
		Log.add_entry("No dry dock facilities at this location.")
		return

	print("Port: _show_ship called")
	_clear_facility_host()

	var packed: PackedScene = load("res://scenes/ShipPanel.tscn")
	if packed == null:
		push_error("Port: failed to load ShipPanel.tscn")
		return

	var panel := packed.instantiate()
	facility_host.add_child(panel)
	if panel is Control:
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)


func _show_docs() -> void:
	print("Port: _show_docs called")
	_clear_facility_host()

	var packed: PackedScene = load("res://scenes/FreightDocsPanel.tscn")
	if packed == null:
		push_error("Port: failed to load FreightDocsPanel.tscn")
		return

	var panel := packed.instantiate()
	facility_host.add_child(panel)
	if panel is Control:
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)


func _show_cantina() -> void:
	if cantina_button.disabled:
		Log.add_entry("No cantina at this location.")
		return

	_clear_facility_host()

	var packed: PackedScene = load("res://scenes/ui/CantinaPanel.tscn")
	if packed == null:
		push_error("Port: failed to load CantinaPanel.tscn")
		return

	var panel := packed.instantiate()
	if panel.has_signal("back_room_requested"):
		panel.connect("back_room_requested", Callable(self, "_show_black_market"))
	if panel.has_signal("close_requested"):
		panel.connect("close_requested", Callable(self, "_clear_facility_host"))

	facility_host.add_child(panel)
	if panel is Control:
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)


func _show_black_market() -> void:
	_clear_facility_host()

	var packed: PackedScene = load("res://scenes/ui/BlackMarketPanel.tscn")
	if packed == null:
		push_error("Port: failed to load BlackMarketPanel.tscn")
		return

	var panel := packed.instantiate()
	if panel.has_signal("close_requested"):
		panel.connect("close_requested", Callable(self, "_clear_facility_host"))
	facility_host.add_child(panel)
	if panel is Control:
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)


# ---------------------------------------------------
# BUTTON HANDLERS
# ---------------------------------------------------

func _on_MarketButton_pressed() -> void:
	print("Port: Market button pressed")
	_show_market()


func _on_ContractsButton_pressed() -> void:
	print("Port: Contracts button pressed")
	_show_contracts()


func _on_ShipButton_pressed() -> void:
	print("Port: Ship button pressed")
	_show_ship()


func _on_DocsButton_pressed() -> void:
	print("Port: Docs button pressed")
	_show_docs()

func _on_CantinaButton_pressed() -> void:
	_show_cantina()


func _on_ToBridgeButton_pressed() -> void:
	var root := get_tree().current_scene
	if root != null and root.has_method("goto_bridge"):
		root.call_deferred("goto_bridge")


# ---------------------------------------------------
# SIGNAL HANDLERS
# ---------------------------------------------------

func _on_system_changed(new_system_id: String) -> void:
	_refresh_header()
	_refresh_facility_buttons()


func _on_location_changed(new_location_id: String) -> void:
	_refresh_header()
	_refresh_facility_buttons()

	# Optional: if you want Port to auto-switch away from a facility
	# that no longer exists at the new location, you can:
	# _clear_facility_host()
	# if _location_has_space("market"):
	#     _show_market()

func _on_customs_pressed() -> void:
	if GameState.current_location_id == "":
		Log.add_entry("Customs inspection unavailable: you must be docked.", "CUSTOMS")
		return

	var report: Dictionary = GameState.run_customs_inspection({
		"system_id": GameState.current_system_id,
		"location_id": GameState.current_location_id,
	})

	Log.add_entry("Customs inspection requested: %s." % str(report.get("classification", "unknown")), "CUSTOMS")
	_show_customs_inspection(report)


func _show_customs_inspection(report: Dictionary) -> void:
	_clear_facility_host()

	var packed: PackedScene = load("res://scenes/ui/CustomsInspectionPanel.tscn")
	if packed == null:
		push_error("Port: failed to load CustomsInspectionPanel.tscn")
		return

	var panel := packed.instantiate()

	if panel.has_signal("close_requested"):
		panel.connect("close_requested", func():
			if is_instance_valid(panel):
				panel.queue_free()
		)

	facility_host.add_child(panel)
	if panel is Control:
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)

	# IMPORTANT: call after add_child so @onready vars exist
	if panel.has_method("set_report"):
		panel.call_deferred("set_report", report)
