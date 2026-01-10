# res://ui/MapPanel.gd
extends Control

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var search_box: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SearchBox
@onready var search_clear_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SearchClearBtn
@onready var systems_tree: Tree = $PanelContainer/MarginContainer/VBoxContainer/SystemTree
@onready var set_course_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/SetCourseButton
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/CloseButton
@onready var info_label: Label = $PanelContainer/MarginContainer/VBoxContainer/InfoLabel

var all_system_entries: Array = [] # array of { id, name, type, security, drydock }
var contract_dest_ids: Array = []   # system-level destinations for now


func _ready() -> void:
	title_label.text = "Galaxy Map"
	close_button.text = "Dock"

	print("MapPanel: _ready. current_system_id =", GameState.current_system_id)
	print("MapPanel: Galaxy.systems size =", Galaxy.systems.size())

	_build_system_entries()
	_rebuild_contract_destinations()
	_refresh_systems_list("")

	search_box.text_changed.connect(_on_search_text_changed)
	search_clear_button.pressed.connect(_on_search_clear_pressed)

	systems_tree.item_selected.connect(_on_tree_item_selected)
	systems_tree.item_activated.connect(_on_tree_item_activated)

	set_course_button.pressed.connect(_on_set_course_pressed)
	close_button.pressed.connect(_on_close_pressed)

	systems_tree.hide_root = true
	systems_tree.columns = 1
	systems_tree.custom_minimum_size = Vector2(0, 300)
	systems_tree.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL
	print("MapPanel: systems_tree size after setup =", systems_tree.size)


func _build_system_entries() -> void:
	all_system_entries.clear()

	var ids: Array = Galaxy.get_all_system_ids()
	print("MapPanel: _build_system_entries. Galaxy.get_all_system_ids() size =", ids.size())

	for id_variant in ids:
		var sys_id: String = String(id_variant)
		var system: Dictionary = Galaxy.get_system(sys_id)
		if system.is_empty():
			continue

		var name: String = String(system.get("name", sys_id))
		var stype: String = String(system.get("system_type", "unknown"))
		var sec: String = String(system.get("security_level", "medium"))
		var has_drydock: bool = Galaxy.system_has_drydock(sys_id)

		all_system_entries.append({
			"id": sys_id,
			"name": name,
			"type": stype,
			"security": sec,
			"drydock": has_drydock
		})

	print("MapPanel: all_system_entries size =", all_system_entries.size())


func _refresh_systems_list(filter_text: String) -> void:
	print("MapPanel: _refresh_systems_list. filter =", filter_text)
	systems_tree.clear()

	var root: TreeItem = systems_tree.create_item()  # hidden root (set Hide Root = true)

	filter_text = filter_text.to_lower()
	var current_id: String = GameState.current_system_id
	var total_rows: int = 0

	for entry_variant in all_system_entries:
		var entry: Dictionary = entry_variant
		var sys_id: String = String(entry["id"])
		var name: String = String(entry["name"])
		var stype: String = String(entry["type"])
		var sec: String = String(entry["security"])

		# Filter
		if filter_text != "":
			var haystack: String = (name + " " + sys_id).to_lower()
			if not haystack.contains(filter_text):
				continue

		# Contract & Doc markers (system-level)
		var contracts_to_sys: int = _count_contracts_to_system(sys_id)
		var has_doc_dest: bool = _system_has_docs(sys_id)

		# ------------------------
		# Build system row
		# ------------------------
		var label: String = "%s (%s) - %s" % [name, stype, sec]

		if entry["drydock"]:
			label += " [DRY DOCK]"

		var is_here: bool = (sys_id == current_id)

		if contracts_to_sys > 0 and is_here:
			label += "  [HERE, CONTRACT]"
		elif contracts_to_sys > 0:
			label += "  [CONTRACT]"
		elif is_here:
			label += "  [HERE]"

		if has_doc_dest:
			label += "  [DOC DEST]"

		# Add system item
		var sys_item: TreeItem = systems_tree.create_item(root)
		sys_item.set_text(0, label)
		sys_item.set_metadata(0, {
			"kind": "system",
			"system_id": sys_id,
		})

		sys_item.collapsed = true

		total_rows += 1

		# ------------------------
		# Add child locations
		# ------------------------
		var locs: Array = Galaxy.get_locations_for_system(sys_id)
		for loc_variant in locs:
			var loc: Dictionary = loc_variant

			var loc_id: String = String(loc.get("id", ""))
			var loc_name: String = String(loc.get("name", loc_id))
			var loc_type: String = String(loc.get("type", "unknown"))
			var spaces: Array = loc.get("spaces", [])

			var spaces_str: String = ""
			if spaces.size() > 0:
				spaces_str = " [" + ", ".join(spaces) + "]"

			var loc_label: String = "%s (%s)%s" % [loc_name, loc_type, spaces_str]

			# child markers
			var markers: Array = []

			if GameState.current_location_id == loc_id:
				markers.append("HERE")

			var loc_contracts: int = _count_contracts_to_location(loc_id)
			if loc_contracts > 0:
				markers.append("CONTRACT")

			if has_doc_dest:
				markers.append("DOC")


			if markers.size() > 0:
				loc_label += "  [" + ", ".join(markers) + "]"

			# Add location tree item
			var child: TreeItem = systems_tree.create_item(sys_item)
			child.set_text(0, loc_label)
			child.set_metadata(0, {
				"kind": "location",
				"system_id": sys_id,
				"location_id": loc_id,
			})

			total_rows += 1

	print("MapPanel: _refresh_systems_list created rows =", total_rows)
	info_label.text = "Select a system or location and press Set Course."


func _on_search_text_changed(new_text: String) -> void:
	_refresh_systems_list(new_text)


func _on_search_clear_pressed() -> void:
	search_box.text = ""
	_refresh_systems_list("")


func _get_selected_meta() -> Dictionary:
	var item: TreeItem = systems_tree.get_selected()
	if item == null:
		return {}
	var meta = item.get_metadata(0)
	if meta == null:
		return {}
	return meta


func _on_tree_item_selected() -> void:
	var meta: Dictionary = _get_selected_meta()
	if meta.is_empty():
		info_label.text = "No selection."
		return

	var kind: String = String(meta.get("kind", ""))
	if kind == "system":
		var sys_id: String = String(meta.get("system_id", ""))
		_show_route_info_to_system(sys_id)
	elif kind == "location":
		var sys_id: String = String(meta.get("system_id", ""))
		_show_route_info_to_system(sys_id)
	else:
		info_label.text = "Unknown selection."


func _on_tree_item_activated() -> void:
	# Double-click or Enter behaves like pressing Set Course
	_on_set_course_pressed()


func _show_route_info_to_system(sys_id: String) -> void:
	if sys_id == "":
		info_label.text = "Invalid destination."
		return

	if sys_id == GameState.current_system_id:
		info_label.text = "Destination is in the current system."
		return

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
	var meta: Dictionary = _get_selected_meta()
	if meta.is_empty():
		info_label.text = "No destination selected."
		return

	var kind: String = String(meta.get("kind", ""))
	if kind == "system":
		var dest_sys: String = String(meta.get("system_id", ""))
		_set_course_to_system(dest_sys)
	elif kind == "location":
		var dest_sys: String = String(meta.get("system_id", ""))
		var dest_loc: String = String(meta.get("location_id", ""))
		_set_course_to_location(dest_sys, dest_loc)
	else:
		info_label.text = "Unknown selection."


func _set_course_to_system(dest_id: String) -> void:
	if dest_id == "":
		info_label.text = "Invalid destination."
		return

	if dest_id == GameState.current_system_id:
		info_label.text = "Already here."
		return

	var path: Array = Galaxy.find_path(GameState.current_system_id, dest_id)
	if path.is_empty() or path.size() < 2:
		info_label.text = "No route from here to that system."
		return

	var hops: int = path.size() - 1
	Log.add_entry("Setting course to %s (%d jumps)." % [dest_id, hops])
	GameState.auto_travel(path)

	info_label.text = "Arrived or stopped en route."
	queue_free()


func _set_course_to_location(dest_sys: String, dest_loc: String) -> void:
	if dest_sys == "":
		info_label.text = "Invalid destination system."
		return
	if dest_loc == "":
		info_label.text = "Invalid destination location."
		return

	var loc: Dictionary = Galaxy.get_location(dest_loc)
	if loc.is_empty():
		info_label.text = "Unknown destination location."
		return

	var loc_system_id: String = String(loc.get("system_id", ""))
	if loc_system_id != "" and loc_system_id != dest_sys:
		info_label.text = "Location is not in that system."
		return

	#  Intersystem movment- if dest_sys != current_sys then we need to travel between systems
	if dest_sys != GameState.current_system_id:
		var path: Array = Galaxy.find_path(GameState.current_system_id, dest_sys)
		if path.is_empty() or path.size() < 2:
			info_label.text = "No route from here to that system."
			return
	
		var hops: int = path.size() - 1
		Log.add_entry("Setting course to %s (%d jumps)." % [dest_sys, hops])
		GameState.auto_travel(path)
		if GameState.current_system_id != dest_sys:
			info_label.text = "Could not reach destination system."
			return
	GameState.set_current_location(dest_loc)

	var loc_name: String = String(loc.get("name", dest_loc))
	info_label.text = "Docked at %s." % loc_name

	queue_free() #for now let's close map after dock 
	return

func _on_close_pressed() -> void:
	queue_free()


func _rebuild_contract_destinations() -> void:
	contract_dest_ids.clear()

	for contract_variant in GameState.active_contracts:
		var c: Dictionary = contract_variant
		var dest_id: String = String(c.get("destination", ""))
		if dest_id == "":
			continue
		if not contract_dest_ids.has(dest_id):
			contract_dest_ids.append(dest_id)


func _count_contracts_to_system(sys_id: String) -> int:
	var count: int = 0
	for contract_variant in GameState.active_contracts:
		var c: Dictionary = contract_variant
		var dest: String = String(c.get("destination", ""))
		if dest == sys_id:
			count += 1
	return count


func _count_contracts_to_location(loc_id: String) -> int:
	var count: int = 0
	for contract_variant in GameState.active_contracts:
		var c: Dictionary = contract_variant
		var dest_loc: String = String(c.get("destination_location_id", ""))
		if dest_loc == loc_id:
			count += 1
	return count


func _system_has_docs(sys_id: String) -> bool:
	for doc_variant in GameState.freight_docs:
		var doc: Dictionary = doc_variant
		var dest_id: String = String(doc.get("destination_system_id", ""))
		if dest_id == sys_id and String(doc.get("status", "active")) == "active":
			return true
	return false


func _estimate_route_cost(path: Array) -> float:
	# path is an array of system IDs in order
	if path.size() < 2:
		return 0.0

	var total_cost: float = 0.0

	# For each hop, cost is based on the destination system of that hop
	for i in range(1, path.size()):
		var dest_id: String = String(path[i])
		total_cost += GameState.get_travel_cost(dest_id)

	return total_cost




