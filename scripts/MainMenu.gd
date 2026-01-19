extends Control

@onready var new_game_button: Button = $CenterContainer/VBoxContainer/NewGameButton
@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel

var _is_starting: bool = false

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed() -> void:
	if _is_starting:
		return
	_is_starting = true
	new_game_button.disabled = true
	new_game_button.text = "Starting..."
	status_label.text = ""

	var scene_path: String = "res://scenes/MainGame.tscn"
	if not ResourceLoader.exists(scene_path):
		push_error("MainMenu: failed to load MainGame scene.")
		status_label.text = "Failed to load game."
		new_game_button.disabled = false
		new_game_button.text = "New Game"
		_is_starting = false
		return

	var result: int = get_tree().change_scene_to_file(scene_path)
	if result != OK:
		push_error("MainMenu: change_scene_to_file failed (%d)." % result)
		status_label.text = "Failed to start game."
		new_game_button.disabled = false
		new_game_button.text = "New Game"
		_is_starting = false

func _on_continue_pressed() -> void:
	# Placeholder for future save/load flow.
	status_label.text = "Continue not available yet."

func _on_quit_pressed() -> void:
	get_tree().quit()
