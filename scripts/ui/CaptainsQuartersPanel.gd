extends Control

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var docs_list: ItemList = $MarginContainer/VBoxContainer/DocsList
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

	docs_list.select_mode = ItemList.SELECT_SINGLE
	docs_list.mouse_filter = Control.MOUSE_FILTER_STOP

	declared_qty_spin.min_value = 0
	declared_qty_spin.max_value = 9999
	declared_qty_spin.step = 1

	_refresh_docs()
	_update_action_state()

	docs_list.item_selected.connect(_on_docs_list_item_selected)
	apply_qty_button.pressed.connect(_on_apply_qty_pressed)
	apply_meta_button.pressed.connect(_on_apply_meta_pressed)
	destroy_button.pressed.connect(_on_destroy_pressed)


func _refresh_docs() -> void:
	docs_list.clear()

	for doc_variant in GameState.freight_docs:
		var doc: Dictionary = doc_variant
		var doc_id: String = String(doc.get("doc_id", "FDOC-????"))
		var doc_type: String = String(doc.get("doc_type", "contract"))
		var status: String = String(doc.get("status", "unknown"))
		var destroyed: bool = bool(doc.get("is_destroyed", false))

		var label := "[%s] %s (%s)" % [doc_id, doc_type, status]
		if destroyed:
			label += " [DESTROYED]"

		var idx := docs_list.add_item(label)
		docs_list.set_item_metadata(idx, doc_id)


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

	_selected_doc_id = String(meta)
	var doc: Dictionary = GameState.get_freight_doc(_selected_doc_id)
	if doc.is_empty():
		_selected_doc_destroyed = false
		_update_action_state()
		return

	_selected_doc_destroyed = bool(doc.get("is_destroyed", false))
	declared_qty_spin.value = int(doc.get("declared_quantity", 0))

	var container_meta: Dictionary = doc.get("container_meta", {})
	container_id_input.text = String(container_meta.get("container_id", ""))
	seal_id_input.text = String(container_meta.get("seal_id", ""))
	seal_state_input.text = String(container_meta.get("seal_state", ""))
	notes_input.text = String(container_meta.get("notes", ""))

	_update_action_state()


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

	_refresh_docs()
	_update_action_state()


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

	_refresh_docs()
	_update_action_state()


func _on_destroy_pressed() -> void:
	if _selected_doc_id == "" or _selected_doc_destroyed:
		return

	GameState.destroy_freight_doc(
		_selected_doc_id,
		destroy_reason_input.text,
		"captains_quarters"
	)

	_refresh_docs()
	_update_action_state()

