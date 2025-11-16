# res://scenes/ContractsPanel.gd
extends Control

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var info_label: Label = $PanelContainer/MarginContainer/VBoxContainer/InfoLabel
@onready var contracts_list: ItemList = $PanelContainer/MarginContainer/VBoxContainer/ContractList
@onready var abandon_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/AbandonButton
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CloseButton
@onready var hint_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HintLabel

# Local snapshot of active contracts at open time
var contracts: Array = []


func _ready() -> void:
	title_label.text = "Active Contracts"

	_refresh_from_gamestate()

	contracts_list.item_selected.connect(_on_contract_selected)
	abandon_button.pressed.connect(_on_abandon_pressed)
	close_button.pressed.connect(_on_close_pressed)


func _refresh_from_gamestate() -> void:
	contracts = GameState.active_contracts.duplicate(true)
	_refresh_list()


func _refresh_list() -> void:
	contracts_list.clear()

	if contracts.is_empty():
		info_label.text = "No active contracts."
		abandon_button.disabled = true
		return

	abandon_button.disabled = false

	for i in range(contracts.size()):
		var c: Dictionary = contracts[i]
		var dest_name: String = c.get("destination_name", c.get("destination", "???"))
		var dest_id: String = c.get("destination", "")
		var jumps: int = int(c.get("jumps", 0))
		var reward: float = float(c.get("reward", 0.0))

		var line := "%s (%s)  -  %d jumps, %.0f cr" % [dest_name, dest_id, jumps, reward]
		contracts_list.add_item(line)
		# store contract id as metadata
		contracts_list.set_item_metadata(i, c.get("id", ""))

	info_label.text = "You have %d active contract(s)." % contracts.size()


func _on_contract_selected(index: int) -> void:
	if index < 0 or index >= contracts.size():
		info_label.text = "Select a contract to see details."
		return

	var c: Dictionary = contracts[index]
	var dest_name: String = c.get("destination_name", c.get("destination", "???"))
	var dest_id: String = c.get("destination", "")
	var jumps: int = int(c.get("jumps", 0))
	var reward: float = float(c.get("reward", 0.0))

	info_label.text = "To %s (%s): %d jumps, reward %.0f cr." % [dest_name, dest_id, jumps, reward]


func _on_abandon_pressed() -> void:
	var selected: PackedInt32Array = contracts_list.get_selected_items()
	if selected.size() == 0:
		info_label.text = "No contract selected."
		return

	var idx: int = selected[0]
	if idx < 0 or idx >= contracts.size():
		info_label.text = "Invalid contract."
		return

	var c: Dictionary = contracts[idx]
	var contract_id: String = c.get("id", "")
	if contract_id == "":
		info_label.text = "Invalid contract data."
		return

	GameState.abandon_contract(contract_id)
	_refresh_from_gamestate()
	info_label.text = "Contract abandoned."


func _on_close_pressed() -> void:
	queue_free()
