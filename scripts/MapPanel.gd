# res://scripts/MapPanel.gd
extends Control

signal navigate_to_system_requested(dest_system_id: String)
signal navigate_to_location_requested(dest_system_id: String, dest_location_id: String)
signal close_requested()

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var search_box: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SearchBox
@onready var search_clear_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SearchClearBtn
@onready var systems_tree: Tree = $PanelContainer/MarginContainer/VBoxContainer/SystemTree
@onready var set_course_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/SetCourseButton
@onready var dock_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/DockButton
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/CloseButton
@onready var info_label: Label = $PanelContainer/MarginContainer/VBoxContainer/InfoLabel

var all_system_entries: Array = [] # array of { id, name, type, security, drydock }
var contract_dest_ids: Array = []   # system-level destinations for now
var _did_empty_retry: bool = false


func _ready() -> void:
	title_label.text = "Galaxy Map"
	set_course_button.text = "Set Course"
	dock_button.text = "Dock"
	close_button.text = "Close"

	search_box.text = ""
	_refresh_all()

	search_box.text_changed.connect(_on_search_text_changed)
	search_clear_button.pressed.connect(_on_search_clear_pressed)

	systems_tree.item_selected.connect(_on_tree_item_selected)
	systems_tree.item_activated.connect(_on_tree_item_activated)

	set_course_button.pressed.connect(_on_set_course_pressed)
	dock_button.pressed.connect(_on_set_course_pressed)
	close_button.pressed.connect(_on_close_pressed)

	GameState.system_changed.connect(_on_system_changed)
	visibility_changed.connect(_on_visibility_changed)

	systems_tree.hide_root = true
	systems_tree.columns = 1

	systems_tree.set_column_expand(0, true)
	systems_tree.set_column_custom_minimum_width(0, 600)

	systems_tree.z_index = 10
	systems_tree.z_as_relative = true

	systems_tree.custom_minimum_size = Vector2(0, 600)
	systems_tree.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL

	systems_tree.add_theme_font_size_override("font_size", 16)

	systems_tree.add_theme_constant_override("item_margin", 22)
	systems_tree.add_theme_constant_override("h_separation", 4)


func _refresh_all() -> void:
	_build_system_entries()
	_rebuild_contract_destinations()
	if is_visible_in_tree() and all_system_entries.is_empty():
		if not _did_empty_retry:
			_did_empty_retry = true
			call_deferred("_refresh_all")
		return

	_did_empty_retry = false
	_refresh_systems_list(search_box.text.strip_edges())


func request_refresh() -> void:
	call_deferred("_refresh_all")


func _build_system_entries() -> void:
	all_system_entries.clear()

	var ids: Array = Galaxy.get_all_system_ids()

	for id_variant in ids:
		var sys_id: String = String(id_variant)
		# NEW (fix)
		var system: Dictionary = Galaxy.get_system(sys_id)

		var name: String = sys_id
		var stype: String = "unknown"
		var sec: String = "medium"

		if not system.is_empty():
			name = String(system.get("name", sys_id))
			stype = String(system.get("system_type", "unknown"))
			sec = String(system.get("security_level", "medium"))


		var has_drydock: bool = Galaxy.system_has_drydock(sys_id)

		all_system_entries.append({
			"id": sys_id,
			"name": name,
			"type": stype,
			"security": sec,
			"drydock": has_drydock,
		})



func _refresh_systems_list(filter_text: String) -> void:
	systems_tree.clear()

	var root: TreeItem = systems_tree.create_item()  # hidden root (set Hide Root = true)

	filter_text = filter_text.strip_edges().to_lower()
	var current_id: String = GameState.current_system_id
	var total_rows: int = 0
	var system_items: Dictionary = {}
	var system_contract_counts: Dictionary = {}
	var system_is_current: Dictionary = {}

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
		var active_dest_to_sys: int = _count_active_destinations_to_system(sys_id)
		var has_doc_dest: bool = _system_has_docs(sys_id)

		# ------------------------
		# Build system row
		# ------------------------
		var label: String = "%s (%s) - %s" % [name, stype, sec]

		var is_here: bool = (sys_id == current_id)

		if contracts_to_sys > 0 and is_here:
			label += "  [HERE, CONTRACT]"
		elif contracts_to_sys > 0:
			label += "  [CONTRACT]"
		elif is_here:
			label += "  [HERE]"

		if active_dest_to_sys > 0:
			label += "  [Dest: %d]" % active_dest_to_sys

		if has_doc_dest:
			label += "  [DOC DEST]"

		# Add system item
		var sys_item: TreeItem = systems_tree.create_item(root)
		sys_item.set_text(0, label)
		sys_item.set_metadata(0, {
			"kind": "system",
			"system_id": sys_id,
		})

		system_items[sys_id] = sys_item
		system_contract_counts[sys_id] = contracts_to_sys
		system_is_current[sys_id] = is_here

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
			var display_spaces: Array = _get_display_spaces(spaces)

			var spaces_str: String = ""
			if display_spaces.size() > 0:
				spaces_str = " [" + ", ".join(display_spaces) + "]"

			var loc_label: String = "%s (%s)%s" % [loc_name, loc_type, spaces_str]

			# child markers
			var markers: Array = []

			if GameState.current_location_id == loc_id:
				markers.append("HERE")

			var loc_contracts: int = _count_contracts_to_location(loc_id)
			if loc_contracts > 0:
				markers.append("Contracts: %d" % loc_contracts)

			var loc_destinations: int = _count_active_destinations_to_location(loc_id)
			if loc_destinations > 0:
				markers.append("Dest: %d" % loc_destinations)

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

	info_label.text = "Select a system or location and press Set Course."

	for sys_id in system_items.keys():
		var sys_item: TreeItem = system_items[sys_id]
		var is_current: bool = bool(system_is_current.get(sys_id, false))
		var contract_count: int = int(system_contract_counts.get(sys_id, 0))
		sys_item.collapsed = not (is_current or contract_count > 0)

	var root_item := systems_tree.get_root()
	var child_count := 0
	if root_item != null:
		child_count = root_item.get_child_count()

	systems_tree.queue_redraw()

	systems_tree.select_mode = Tree.SELECT_ROW
	systems_tree.grab_focus()
	systems_tree.set_selected(systems_tree.get_root().get_first_child(), 0)

	
	#systems_tree.queue_sort()



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

	info_label.text = "Course requested."
	emit_signal("navigate_to_system_requested", dest_id)


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
	
	info_label.text = "Docking requested."
	emit_signal("navigate_to_location_requested", dest_sys, dest_loc)
	return

func _on_close_pressed() -> void:
	emit_signal("close_requested")


func _on_system_changed(new_system_id: String) -> void:
	call_deferred("_refresh_all")

func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		return
	call_deferred("_refresh_all")



func _rebuild_contract_destinations() -> void:
	contract_dest_ids = GameState.get_active_contract_destination_system_ids()


func _count_contracts_to_system(sys_id: String) -> int:
	var count: int = 0
	var locs: Array = Galaxy.get_locations_for_system(sys_id)
	for loc_variant in locs:
		var loc: Dictionary = loc_variant
		var loc_id: String = String(loc.get("id", ""))
		if loc_id == "":
			continue
		count += Contracts.get_contract_count_for_location(loc_id)
	return count


func _count_contracts_to_location(loc_id: String) -> int:
	return Contracts.get_contract_count_for_location(loc_id)

func _count_active_destinations_to_system(sys_id: String) -> int:
	return GameState.count_active_contract_destinations_to_system(sys_id)

func _count_active_destinations_to_location(loc_id: String) -> int:
	return GameState.count_active_contract_destinations_to_location(loc_id)


func _system_has_docs(sys_id: String) -> bool:
	for doc_variant in GameState.freight_docs:
		var doc: Dictionary = doc_variant
		var dest_id: String = String(doc.get("destination_system_id", ""))
		if dest_id == sys_id and String(doc.get("status", "active")) == "active":
			return true
	return false


func _get_display_spaces(spaces: Array) -> Array:
	var display: Array = spaces.duplicate()
	if display.has("back_room"):
		if not display.has("cantina"):
			display.append("cantina")
		display.erase("back_room")
	display.sort()
	return display


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
