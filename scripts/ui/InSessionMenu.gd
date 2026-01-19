extends Control

signal resume_requested
signal quit_to_menu_requested
signal quit_to_desktop_requested

@onready var resume_button: Button = $CenterContainer/PanelContainer/VBoxContainer/ResumeButton
@onready var save_button: Button = $CenterContainer/PanelContainer/VBoxContainer/SaveButton
@onready var settings_button: Button = $CenterContainer/PanelContainer/VBoxContainer/SettingsButton
@onready var quit_menu_button: Button = $CenterContainer/PanelContainer/VBoxContainer/QuitMenuButton
@onready var quit_desktop_button: Button = $CenterContainer/PanelContainer/VBoxContainer/QuitDesktopButton
@onready var status_label: Label = $CenterContainer/PanelContainer/VBoxContainer/StatusLabel

func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	save_button.pressed.connect(_on_save_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_menu_button.pressed.connect(_on_quit_menu_pressed)
	quit_desktop_button.pressed.connect(_on_quit_desktop_pressed)

func set_status(text: String) -> void:
	status_label.text = text

func _on_resume_pressed() -> void:
	status_label.text = ""
	resume_requested.emit()

func _on_save_pressed() -> void:
	status_label.text = "Save not implemented."

func _on_settings_pressed() -> void:
	status_label.text = "Settings not implemented."

func _on_quit_menu_pressed() -> void:
	status_label.text = ""
	quit_to_menu_requested.emit()

func _on_quit_desktop_pressed() -> void:
	status_label.text = ""
	quit_to_desktop_requested.emit()
