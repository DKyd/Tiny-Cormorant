# res://ui/MapPanel.gd
extends Control

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var search_box: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SearchBox
@onready var search_clear_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SearchClearBtn
@onready var systems_list: ItemList = $PanelContainer/MarginContainer/VBoxContainer/SystemsList
@onready var set_course_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/SetCourseButton
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/CloseButton
@onready var info_label: Label = $PanelContainer/MarginContainer/VBoxContainer/InfoLabel

var all_system_entries: Array = [] # array of { id, name, type, security }
var contract_dest_ids: Array = []

func _ready() -> void:
	title_label.text = "Galaxy Map"
	close_button.text = "Dock"

	_build_system_entries()
	_rebuild_contract_destinations()
	_refresh_systems_list("")

	search_box.text_changed.connect(_on_search_text_changed)
	search_clear_button.pressed.connect(_on_search_clear_pressed)
	systems_list.item_selected.connect(_on_system_selected)
	set_course_button.pressed.connect(_on_set_course_pressed)
	close_button.pressed.connect(_on_close_pressed)


func _build_system_entries() -> void:
	all_system_entries.clear()
	var ids: Array = Galaxy.get_all_system_ids()
	for id_variant in ids:
		var sys_id: String = str(id_variant)
		var system: Dictionary = Galaxy.get_system(sys_id)
		if system.is_empty():
			continue
		var name: String = system.get("name", sys_id)
		var stype: String = system.get("system_type", "unknown")
		var sec: String = system.get("security_level", "medium")
		var has_drydock: bool = Galaxy.system_has_drydock(sys_id)

		all_system_entries.append({
			"id": sys_id,
			"name": name,
			"type": stype,
			"security": sec,
			"drydock": has_drydock
		})


func _refresh_systems_list(filter_text: String) -> void:
	systems_list.clear()
	filter_text = filter_text.to_lower()
	var current_id: String = GameState.current_system_id

	for entry_variant in all_system_entries:
		var entry: Dictionary = entry_variant
		var sys_id: String = entry["id"]
		var name: String = entry["name"]
		var stype: String = entry["type"]
		var sec: String = entry["security"]

		if filter_text != "":
			var haystack := (name + " " + sys_id).to_lower()
			if not haystack.contains(filter_text):
				continue

		#format system list entry
		var label := "%s (%s) - %s" % [name, stype, sec]
		if entry["drydock"]:
			label+= " [DRY DOCK]"

		var is_here: bool = (sys_id == current_id)
		var has_contract: bool = contract_dest_ids.has(sys_id)

		if has_contract and is_here:
			label += "  [HERE, CONTRACT]"
		elif has_contract:
			label += "  [CONTRACT]"
		elif is_here:
			label += "  [HERE]"

		var idx := systems_list.add_item(label)

		if is_here:
			systems_list.set_item_disabled(idx, true)

		systems_list.set_item_metadata(idx, sys_id)

	info_label.text = "Select a system and press Set Course."


func _on_search_text_changed(new_text: String) -> void:
	_refresh_systems_list(new_text)


func _on_search_clear_pressed() -> void:
	search_box.text = ""
	_refresh_systems_list("")


func _on_system_selected(index: int) -> void:
	if index < 0:
		return

	var sys_id: String = str(systems_list.get_item_metadata(index))
	var path: Array = Galaxy.find_path(GameState.current_system_id, sys_id)
	if path.is_empty() or path.size() < 2:
		info_label.text = "No route from here to that system."
		return

	var hops: int = path.size() - 1
	var cost: float = _estimate_route_cost(path)
	var engine_level: int = GameState.ship_engine_level

	info_label.text = "Route found: %d jumps, est cost %.0f cr (Engine L%d)." \
		% [hops, cost, engine_level]


func _on_set_course_pressed() -> void:
	var selected: PackedInt32Array = systems_list.get_selected_items()
	if selected.size() == 0:
		info_label.text = "No destination selected."
		return

	var idx: int = selected[0]
	var dest_id: String = str(systems_list.get_item_metadata(idx))
	if dest_id == GameState.current_system_id:
		info_label.text = "Already here."
		return

	var path: Array = Galaxy.find_path(GameState.current_system_id, dest_id)
	if path.is_empty() or path.size() < 2:
		info_label.text = "No route from here to that system."
		return

	var hops := path.size() - 1
	Log.add("Setting course to %s (%d jumps)." % [dest_id, hops])
	GameState.auto_travel(path)

	# After auto-travel, you can close the map
	info_label.text = "Arrived or stopped en route."
	queue_free()


func _on_close_pressed() -> void:
	queue_free()

func _rebuild_contract_destinations() -> void:
	contract_dest_ids.clear()

	for contract_variant in GameState.active_contracts:
		var c: Dictionary = contract_variant
		var dest_id: String = str(c.get("destination", ""))
		if dest_id == "":
			continue
		if not contract_dest_ids.has(dest_id):
			contract_dest_ids.append(dest_id)


func _count_contracts_to_system(sys_id: String) -> int:
	var count := 0
	for contract_variant in GameState.active_contracts:
		var c: Dictionary = contract_variant
		if str(c.get("destination", "")) == sys_id:
			count += 1
	return count

func _estimate_route_cost(path: Array) -> float:
	# path is an array of system IDs in order
	if path.size() < 2:
		return 0.0

	var total_cost: float = 0.0

	# For each hop, cost is based on the destination system of that hop
	for i in range(1, path.size()):
		var dest_id: String = str(path[i])
		total_cost += GameState.get_travel_cost(dest_id)

	return total_cost
