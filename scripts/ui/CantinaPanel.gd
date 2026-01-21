extends Control

signal back_room_requested
signal close_requested

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var info_label: Label = $MarginContainer/VBoxContainer/InfoLabel
@onready var back_room_button: Button = $MarginContainer/VBoxContainer/BackRoomButton
@onready var close_button: Button = $MarginContainer/VBoxContainer/CloseButton


func _ready() -> void:
	title_label.text = "Cantina"
	info_label.text = "A dim, noisy cantina. The back room is off-limits to most."
	var has_black_market := GameState.location_has_black_market(GameState.current_location_id)
	if not has_black_market:
		back_room_button.disabled = true
		back_room_button.visible = false

	back_room_button.pressed.connect(_on_BackRoomButton_pressed)
	close_button.pressed.connect(_on_CloseButton_pressed)


func _on_BackRoomButton_pressed() -> void:
	emit_signal("back_room_requested")


func _on_CloseButton_pressed() -> void:
	emit_signal("close_requested")
