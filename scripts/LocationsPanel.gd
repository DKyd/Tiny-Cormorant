extends Control

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var locations_list: ItemList = $PanelContainer/MarginContainer/VBoxContainer/LocationsList
@onready var description_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DescriptionLabel
@onready var dock_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/DockButton
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CloseButton

func _ready() -> void:
	# Basic UI setup
	title_label.text = "Locations in System"
	dock_button.text = "Dock Here"
	close_button.text = "Close"

	_refresh_list()
	_update_title_and_description()

	locations_list.item_selected.connect(_on_LocationsList_item_selected)
	dock_button.pressed.connect(_on_DockButton_pressed)
	close_button.pressed.connect(_on_CloseButton_pressed)


func _refresh_list() -> void:
	locations_list.clear()

	var sys_id: String = GameState.current_system_id
	if sys_id == "":
		description_label.text = "No current system."
		return

	var system: Dictionary = Galaxy.get_system(sys_id)
	var system_name: String = system.get("name", sys_id)

	# Show system name in title
	title_label.text = "Locations in %s" % system_name

	var locs: Array = Galaxy.get_locations_for_system(sys_id)
	if locs.is_empty():
		description_label.text = "No visitable locations in this system."
		return

	for i in range(locs.size()):
		var loc: Dictionary = locs[i]
		var loc_id: String = loc.get("id", "")
		var loc_name: String = loc.get("name", loc_id)
		var loc_type: String = loc.get("type", "unknown")
		var spaces: Array = loc.get("spaces", []) as Array

		var spaces_str := ""
		if spaces.size() > 0:
			spaces_str = " [" + ", ".join(spaces) + "]"

		var label := "%s (%s)%s" % [loc_name, loc_type, spaces_str]

		var idx := locations_list.add_item(label)
		locations_list.set_item_metadata(idx, loc_id)

	# Auto-select the current location if it belongs to this system
	if GameState.current_location_id != "":
		var current_loc_id: String = GameState.current_location_id
		for row in range(locations_list.item_count):
			var meta = locations_list.get_item_metadata(row)
			if meta == current_loc_id:
				locations_list.select(row)
				_show_location_description(current_loc_id)
				break


func _update_title_and_description() -> void:
	var sys_id: String = GameState.current_system_id
	if sys_id == "":
		title_label.text = "Locations"
		description_label.text = ""
		return

	var system: Dictionary = Galaxy.get_system(sys_id)
	var system_name: String = system.get("name", sys_id)
	title_label.text = "Locations in %s" % system_name

	# If we have a current location, show its description
	if GameState.current_location_id != "":
		_show_location_description(GameState.current_location_id)
	else:
		description_label.text = "Select a location to view details."


func _show_location_description(loc_id: String) -> void:
	var loc: Dictionary = Galaxy.get_location(loc_id)
	if loc.is_empty():
		description_label.text = "Unknown location."
		return

	var desc: String = loc.get("description", "")
	if desc == "":
		desc = "No description available."

	var name: String = loc.get("name", loc_id)
	var loc_type: String = loc.get("type", "unknown")
	var spaces: Array = loc.get("spaces", []) as Array

	var spaces_str := ""
	if spaces.size() > 0:
		spaces_str = "Spaces: " + ", ".join(spaces)
	else:
		spaces_str = "No services listed."

	description_label.text = "%s (%s)\n\n%s\n\n%s" \
		% [name, loc_type, desc, spaces_str]


func _on_LocationsList_item_selected(index: int) -> void:
	var meta = locations_list.get_item_metadata(index)
	if meta == null:
		return

	var loc_id: String = String(meta)
	_show_location_description(loc_id)


func _on_DockButton_pressed() -> void:
	var idx := locations_list.get_selected_items()
	if idx.is_empty():
		Log.add_entry("No location selected to dock at.")
		return

	var row: int = int(idx[0])
	var meta = locations_list.get_item_metadata(row)
	if meta == null:
		return

	var loc_id: String = String(meta)
	GameState.set_current_location(loc_id)
	queue_free()


func _on_CloseButton_pressed() -> void:
	queue_free()

