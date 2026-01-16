extends Control

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var docs_list: ItemList = $MarginContainer/VBoxContainer/DocsList
@onready var inspector_title: Label = $MarginContainer/VBoxContainer/InspectorSection/InspectorTitle
@onready var inspector_doc_id: Label = $MarginContainer/VBoxContainer/InspectorSection/InspectorGrid/DocIdValue
@onready var inspector_doc_type: Label = $MarginContainer/VBoxContainer/InspectorSection/InspectorGrid/DocTypeValue
@onready var inspector_status: Label = $MarginContainer/VBoxContainer/InspectorSection/InspectorGrid/StatusValue
@onready var inspector_destroyed: Label = $MarginContainer/VBoxContainer/InspectorSection/InspectorGrid/DestroyedValue
@onready var inspector_declared_qty: Label = $MarginContainer/VBoxContainer/InspectorSection/InspectorGrid/DeclaredQtyValue
@onready var inspector_packed_tick: Label = $MarginContainer/VBoxContainer/InspectorSection/InspectorGrid/PackedTickValue
@onready var inspector_container: Label = $MarginContainer/VBoxContainer/InspectorSection/InspectorGrid/ContainerValue
@onready var inspector_provenance: Label = $MarginContainer/VBoxContainer/InspectorSection/InspectorGrid/ProvenanceValue
@onready var inspector_edit_events: Label = $MarginContainer/VBoxContainer/InspectorSection/InspectorGrid/EditEventsValue
@onready var inspector_authenticity: Label = $MarginContainer/VBoxContainer/InspectorSection/InspectorGrid/AuthenticityValue
@onready var inspector_evidence: Label = $MarginContainer/VBoxContainer/InspectorSection/InspectorGrid/EvidenceValue
@onready var declared_qty_spin: SpinBox = $MarginContainer/VBoxContainer/DeclaredQtyRow/DeclaredQtySpin
@onready var container_id_input: LineEdit = $MarginContainer/VBoxContainer/ContainerRow/ContainerIdInput
@onready var seal_id_input: LineEdit = $MarginContainer/VBoxContainer/ContainerRow/SealIdInput
@onready var seal_state_input: LineEdit = $MarginContainer/VBoxContainer/ContainerRow/SealStateInput
@onready var notes_input: LineEdit = $MarginContainer/VBoxContainer/ContainerRow/NotesInput
@onready var apply_qty_button: Button = $MarginContainer/VBoxContainer/ActionRow/ApplyQtyButton
@onready var apply_meta_button: Button = $MarginContainer/VBoxContainer/ActionRow/ApplyMetaButton
@onready var destroy_button: Button = $MarginContainer/VBoxContainer/ActionRow/DestroyButton
@onready var destroy_reason_input: LineEdit = $MarginContainer/VBoxContainer/DestroyRow/DestroyReasonInput

var _selected_doc_id: String = ""
var _selected_doc_destroyed: bool = false


func _ready() -> void:
	title_label.text = "Captain's Quarters"
	inspector_title.text = "Selected FreightDoc"

	docs_list.select_mode = ItemList.SELECT_SINGLE
	docs_list.mouse_filter = Control.MOUSE_FILTER_STOP

	declared_qty_spin.min_value = 0
	declared_qty_spin.max_value = 9999
	declared_qty_spin.step = 1

	_refresh_docs(true)
	if _selected_doc_id == "" and docs_list.item_count > 0:
		docs_list.select(0)
		var meta = docs_list.get_item_metadata(0)
		if meta != null:
			_selected_doc_id = str(meta)
	_render_selected_doc()
	_update_action_state()

	docs_list.item_selected.connect(_on_docs_list_item_selected)
	apply_qty_button.pressed.connect(_on_apply_qty_pressed)
	apply_meta_button.pressed.connect(_on_apply_meta_pressed)
	destroy_button.pressed.connect(_on_destroy_pressed)
	if not GameState.freight_doc_changed.is_connected(_on_freight_doc_changed):
		GameState.freight_doc_changed.connect(_on_freight_doc_changed)


func _exit_tree() -> void:
	if GameState.freight_doc_changed.is_connected(_on_freight_doc_changed):
		GameState.freight_doc_changed.disconnect(_on_freight_doc_changed)


func _refresh_docs(keep_selection: bool = true) -> void:
	docs_list.clear()
	var selected_id := _selected_doc_id if keep_selection else ""
	var selected_index := -1

	for doc_variant in GameState.freight_docs:
		var doc: Dictionary = doc_variant
		var doc_id: String = str(doc.get("doc_id", "FDOC-????"))
		var doc_type: String = str(doc.get("doc_type", "contract"))
		var status: String = str(doc.get("status", "unknown"))
		var destroyed: bool = bool(doc.get("is_destroyed", false))

		var label := "[%s] %s (%s)" % [doc_id, doc_type, status]
		if destroyed:
			label += " [DESTROYED]"

		var idx := docs_list.add_item(label)
		docs_list.set_item_metadata(idx, doc_id)
		if selected_id != "" and doc_id == selected_id:
			selected_index = idx

	if selected_index != -1:
		docs_list.select(selected_index)
	else:
		docs_list.deselect_all()
		if keep_selection and selected_id != "":
			_set_inspector_empty()


func _update_action_state() -> void:
	var has_selection := _selected_doc_id != ""
	var can_edit := has_selection and not _selected_doc_destroyed
	apply_qty_button.disabled = not can_edit
	apply_meta_button.disabled = not can_edit
	destroy_button.disabled = not can_edit


func _on_docs_list_item_selected(index: int) -> void:
	var meta = docs_list.get_item_metadata(index)
	if meta == null:
		return

	_selected_doc_id = str(meta)
	_render_selected_doc()
	_update_action_state()


func _render_selected_doc() -> void:
	if _selected_doc_id == "":
		_set_inspector_empty()
		_selected_doc_destroyed = false
		_update_action_state()
		return

	var doc: Dictionary = GameState.get_freight_doc(_selected_doc_id)
	if doc.is_empty():
		_selected_doc_destroyed = false
		_set_inspector_empty()
		_update_action_state()
		return

	_selected_doc_destroyed = bool(doc.get("is_destroyed", false))
	declared_qty_spin.value = int(doc.get("declared_quantity", 0))

	var container_meta: Dictionary = doc.get("container_meta", {})
	container_id_input.text = str(container_meta.get("container_id", ""))
	seal_id_input.text = str(container_meta.get("seal_id", ""))
	seal_state_input.text = str(container_meta.get("seal_state", ""))
	notes_input.text = str(container_meta.get("notes", ""))

	inspector_doc_id.text = str(doc.get("doc_id", "FDOC-????"))
	inspector_doc_type.text = str(doc.get("doc_type", "contract"))
	inspector_status.text = str(doc.get("status", "unknown"))
	inspector_destroyed.text = "Yes" if _selected_doc_destroyed else "No"
	inspector_declared_qty.text = str(doc.get("declared_quantity", 0))
	inspector_packed_tick.text = _format_packed_tick(container_meta.get("packed_tick", null))
	inspector_container.text = _format_container_meta(container_meta)
	inspector_provenance.text = _format_provenance(container_meta.get("provenance", null))
	inspector_edit_events.text = _format_edit_events(doc.get("edit_events", []))
	inspector_authenticity.text = str(GameState.get_doc_authenticity(_selected_doc_id))
	inspector_evidence.text = _format_evidence_flags(
		GameState.get_doc_evidence_flags(_selected_doc_id)
	)


func _set_inspector_empty() -> void:
	inspector_doc_id.text = "None"
	inspector_doc_type.text = "-"
	inspector_status.text = "-"
	inspector_destroyed.text = "-"
	inspector_declared_qty.text = "-"
	inspector_packed_tick.text = "-"
	inspector_container.text = "-"
	inspector_provenance.text = "None"
	inspector_edit_events.text = "-"
	inspector_authenticity.text = "-"
	inspector_evidence.text = "-"


func _format_packed_tick(packed_tick) -> String:
	if packed_tick == null:
		return "-"
	return str(packed_tick)


func _format_provenance(provenance_variant) -> String:
	if not (provenance_variant is Dictionary):
		return "None"

	var provenance: Dictionary = provenance_variant
	if provenance.is_empty():
		return "None"

	var source: String = str(provenance.get("source", ""))
	var system_id: String = str(provenance.get("system_id", ""))
	var location_id: String = str(provenance.get("location_id", ""))

	var parts: Array = []
	if source != "":
		parts.append(source)
	if system_id != "":
		parts.append("sys=%s" % system_id)
	if location_id != "":
		parts.append("loc=%s" % location_id)

	if parts.is_empty():
		return "None"
	return " ".join(parts)


func _format_evidence_flags(flags_variant) -> String:
	if not (flags_variant is Array):
		return "None"

	var flags: Array = flags_variant
	if flags.is_empty():
		return "None"

	var parts: Array = []
	for flag_variant in flags:
		var flag_text: String = str(flag_variant)
		if flag_text != "":
			parts.append(flag_text)

	if parts.is_empty():
		return "None"
	return ", ".join(parts)


func _format_container_meta(container_meta: Dictionary) -> String:
	if container_meta.is_empty():
		return "None"

	var parts: Array = []
	var container_id: String = str(container_meta.get("container_id", ""))
	var seal_id: String = str(container_meta.get("seal_id", ""))
	var seal_state: String = str(container_meta.get("seal_state", ""))
	var notes: String = str(container_meta.get("notes", ""))

	if container_id != "":
		parts.append("Container %s" % container_id)
	if seal_id != "":
		var seal_text := "Seal %s" % seal_id
		if seal_state != "":
			seal_text += " (%s)" % seal_state
		parts.append(seal_text)
	if notes != "":
		parts.append("Notes: %s" % notes)

	if parts.is_empty():
		return "None"
	return "; ".join(parts)


func _format_edit_events(events_variant) -> String:
	if not (events_variant is Array):
		return "None"

	var events: Array = events_variant
	if events.is_empty():
		return "None"

	var last_event: Dictionary = events[events.size() - 1]
	var event_type: String = str(last_event.get("event_type", "unknown"))
	var tick: String = str(last_event.get("tick", "?"))
	return "%d total (last: %s @ %s)" % [events.size(), event_type, tick]


func _on_apply_qty_pressed() -> void:
	if _selected_doc_id == "" or _selected_doc_destroyed:
		return

	GameState.modify_freight_doc(
		_selected_doc_id,
		{
			"declared_quantity": int(declared_qty_spin.value),
			"tool_used": "none",
			"quality": 0,
		},
		"captains_quarters"
	)


func _on_apply_meta_pressed() -> void:
	if _selected_doc_id == "" or _selected_doc_destroyed:
		return

	GameState.modify_freight_doc(
		_selected_doc_id,
		{
			"container_meta": {
				"container_id": container_id_input.text,
				"seal_id": seal_id_input.text,
				"seal_state": seal_state_input.text,
				"notes": notes_input.text,
			},
			"tool_used": "none",
			"quality": 0,
		},
		"captains_quarters"
	)


func _on_destroy_pressed() -> void:
	if _selected_doc_id == "" or _selected_doc_destroyed:
		return

	GameState.destroy_freight_doc(
		_selected_doc_id,
		destroy_reason_input.text,
		"captains_quarters"
	)


func _on_freight_doc_changed(doc_id: String, _change_kind: String) -> void:
	_refresh_docs(true)
	if doc_id == _selected_doc_id:
		_render_selected_doc()
	_update_action_state()
