extends Control

@onready var title_label: Label = $MarginContainer/VBoxContainer/HeaderRow/TitleLabel
@onready var system_info_label: Label = $MarginContainer/VBoxContainer/HeaderRow/SystemInfoLabel
@onready var to_bridge_button: Button = $MarginContainer/VBoxContainer/HeaderRow/ToBridgeButton

@onready var market_button: Button = $MarginContainer/VBoxContainer/FacilitiesRow/MarketButton
@onready var contracts_button: Button = $MarginContainer/VBoxContainer/FacilitiesRow/ContractsButton
@onready var ship_button: Button = $MarginContainer/VBoxContainer/FacilitiesRow/ShipButton
@onready var docs_button: Button = $MarginContainer/VBoxContainer/FacilitiesRow/DocsButton

@onready var facility_host: Control = $MarginContainer/VBoxContainer/FacilityPanel/FacilityHost


func _ready() -> void:
	print("Port: _ready called")

	title_label.text = "Port"
	_refresh_system_info()

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
	docs_button.pressed.connect(_on_DocsButton_pressed)

	GameState.system_changed.connect(_on_system_changed)

	# Default view: Market
	_show_market()


func _refresh_system_info() -> void:
	var sys_id: String = GameState.current_system_id
	if sys_id == "":
		system_info_label.text = "(unknown system)"
		return

	var system: Dictionary = Galaxy.get_system(sys_id)
	var name: String = system.get("name", sys_id)
	var stype: String = system.get("system_type", "unknown")
	var sec: String = system.get("security_level", "medium")

	system_info_label.text = "%s  [%s, %s]" % [name, stype.capitalize(), sec.capitalize()]


func _clear_facility_host() -> void:
	for child in facility_host.get_children():
		child.queue_free()


func _show_market() -> void:
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


# ---- Button handlers ----

func _on_MarketButton_pressed() -> void:
	print("Port: Market button pressed")
	_show_market()


func _on_ContractsButton_pressed() -> void:
	print("Port: Contracts button pressed (stub)")


func _on_ShipButton_pressed() -> void:
	print("Port: Ship button pressed (stub)")


func _on_DocsButton_pressed() -> void:
	print("Port: Docs button pressed (stub)")


func _on_ToBridgeButton_pressed() -> void:
	var root := get_tree().current_scene
	if root != null and root.has_method("goto_bridge"):
		root.call_deferred("goto_bridge")


func _on_system_changed(new_system_id: String) -> void:
	_refresh_system_info()
