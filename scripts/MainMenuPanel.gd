# res://scenes/MainMenuPanel.gd
extends Control

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var info_label: Label = $PanelContainer/MarginContainer/VBoxContainer/InfoLabel
@onready var save_button: Button = $PanelContainer/MarginContainer/VBoxContainer/SaveButton
@onready var load_button: Button = $PanelContainer/MarginContainer/VBoxContainer/LoadButton
@onready var settings_button: Button = $PanelContainer/MarginContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $PanelContainer/MarginContainer/VBoxContainer/QuitButton
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/CloseButton


func _ready() -> void:
	title_label.text = "Main Menu"
	info_label.text = "Manage your game here."

	save_button.pressed.connect(_on_SaveButton_pressed)
	load_button.pressed.connect(_on_LoadButton_pressed)
	settings_button.pressed.connect(_on_SettingsButton_pressed)
	quit_button.pressed.connect(_on_QuitButton_pressed)
	close_button.pressed.connect(_on_CloseButton_pressed)


func _on_SaveButton_pressed() -> void:
	GameState.save_game()
	info_label.text = "Game saved."


func _on_LoadButton_pressed() -> void:
	GameState.load_game()
	info_label.text = "Game loaded."


func _on_SettingsButton_pressed() -> void:
	info_label.text = "Settings panel not implemented yet."


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_CloseButton_pressed() -> void:
	queue_free()
