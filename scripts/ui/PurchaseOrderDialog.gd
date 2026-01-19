extends Window

signal confirmed(commodity_id: String, qty: int)
signal cancelled

@onready var commodity_label: Label = $MarginContainer/VBoxContainer/CommodityLabel
@onready var unit_price_label: Label = $MarginContainer/VBoxContainer/UnitPriceLabel
@onready var credits_label: Label = $MarginContainer/VBoxContainer/CreditsLabel
@onready var cargo_label: Label = $MarginContainer/VBoxContainer/CargoLabel
@onready var qty_spin: SpinBox = $MarginContainer/VBoxContainer/QtyRow/QtySpin
@onready var total_label: Label = $MarginContainer/VBoxContainer/TotalLabel
@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel
@onready var confirm_button: Button = $MarginContainer/VBoxContainer/ButtonsRow/ConfirmButton
@onready var cancel_button: Button = $MarginContainer/VBoxContainer/ButtonsRow/CancelButton

var _commodity_id: String = ""
var _unit_price: float = 0.0

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	close_requested.connect(_on_cancel_pressed)
	qty_spin.value_changed.connect(_on_qty_changed)
	qty_spin.min_value = 1
	qty_spin.max_value = 999
	qty_spin.step = 1

func setup(
	commodity_id: String,
	commodity_name: String,
	unit_price: float,
	credits: float,
	cargo_weight: float,
	cargo_capacity: float
) -> void:
	_commodity_id = commodity_id
	_unit_price = unit_price
	commodity_label.text = "Commodity: %s" % commodity_name
	unit_price_label.text = "Unit Price: %.0f cr" % unit_price
	credits_label.text = "Credits: %.0f" % credits
	cargo_label.text = "Cargo: %.1f / %.1f" % [cargo_weight, cargo_capacity]
	qty_spin.value = 1
	status_label.text = ""
	_refresh_total()

func set_status(text: String) -> void:
	status_label.text = text

func _refresh_total() -> void:
	var qty: int = int(qty_spin.value)
	var total_cost: float = _unit_price * float(qty)
	total_label.text = "Total: %.0f cr" % total_cost

func _on_qty_changed(_value: float) -> void:
	_refresh_total()

func _on_confirm_pressed() -> void:
	var qty: int = int(qty_spin.value)
	confirmed.emit(_commodity_id, qty)

func _on_cancel_pressed() -> void:
	cancelled.emit()
	hide()
