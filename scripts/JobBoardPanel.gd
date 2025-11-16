extends Control

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var info_label: Label = $PanelContainer/MarginContainer/VBoxContainer/InfoLabel
@onready var contracts_list: ItemList = $PanelContainer/MarginContainer/VBoxContainer/ContractsList
@onready var accept_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/AcceptButton
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CloseButton
@onready var hint_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HintLabel

var contracts: Array = []  # available contracts for this system


func _ready() -> void:
	title_label.text = "Job Board"

	_build_contracts_for_current_system()
	_refresh_list()

	contracts_list.item_selected.connect(_on_contract_selected)
	accept_button.pressed.connect(_on_accept_pressed)
	close_button.pressed.connect(_on_close_pressed)


func _build_contracts_for_current_system() -> void:
	var sys_id: String = GameState.current_system_id
	if sys_id == "":
		contracts = []
		info_label.text = "No system selected."
		return

	contracts = Contracts.generate_contracts_for_system(sys_id, 4)
	if contracts.is_empty():
		info_label.text = "No contracts available here."
	else:
		info_label.text = "Contracts available from this system."


func _refresh_list() -> void:
	contracts_list.clear()
	for i in range(contracts.size()):
		var c: Dictionary = contracts[i]
		var dest_name: String = c.get("destination_name", c.get("destination", "???"))
		var dest_id: String = c.get("destination", "")
		var jumps: int = int(c.get("jumps", 0))
		var reward: float = float(c.get("reward", 0.0))

		var line := "%s (%s)  -  %d jumps, %.0f cr" % [dest_name, dest_id, jumps, reward]
		contracts_list.add_item(line)
		contracts_list.set_item_metadata(i, i)  # store index into contracts array

	if contracts.size() == 0:
		accept_button.disabled = true
	else:
		accept_button.disabled = false


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


func _on_accept_pressed() -> void:
	var selected: PackedInt32Array = contracts_list.get_selected_items()
	if selected.size() == 0:
		info_label.text = "No contract selected."
		return

	var idx: int = selected[0]
	if idx < 0 or idx >= contracts.size():
		info_label.text = "Invalid contract."
		return

	var contract: Dictionary = contracts[idx]

	print("Accepting contract: ", contract)
	#prints to game log for added player info
	#Log.add("DEBUG: Accepting contract %s with %d cargo_lines." 
    #% [contract.get("id", "?"), contract.get("cargo_lines", []).size()])

	GameState.add_contract(contract)
	GameState.create_freight_doc_for_contract(contract)
	GameState.load_contract_cargo(contract)

	# remove it from local list so you can't take it twice
	contracts.remove_at(idx)
	_refresh_list()
	info_label.text = "Contract accepted."


func _on_close_pressed() -> void:
	queue_free()
