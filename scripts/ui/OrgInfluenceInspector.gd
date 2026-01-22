extends PopupPanel

@onready var content_label: Label = $MarginContainer/VBoxContainer/ContentLabel
@onready var close_button: Button = $MarginContainer/VBoxContainer/CloseButton


func _ready() -> void:
	_refresh()
	close_button.pressed.connect(_on_close_pressed)


func _on_close_pressed() -> void:
	queue_free()


func _refresh() -> void:
	var location: Dictionary = GameState.get_current_location()
	var location_id: String = String(location.get("id", ""))
	if location_id == "":
		content_label.text = "No current location."
		return

	var influences: Array = GameState.get_location_effective_influences(location_id)
	if influences.is_empty():
		content_label.text = "No influence data."
		return

	var lines: Array = []
	for influence_variant in influences:
		if not (influence_variant is Dictionary):
			continue
		var influence: Dictionary = influence_variant
		var org_id: String = String(influence.get("org_id", ""))
		var weight: float = float(influence.get("weight", 0.0))
		var org_name: String = _get_org_display_name(org_id)
		var bucket: String = _bucket_influence(weight)
		lines.append("%s: %.2f (%s)" % [org_name, weight, bucket])

	if lines.is_empty():
		content_label.text = "No influence data."
		return

	content_label.text = "\n".join(lines)


func _get_org_display_name(org_id: String) -> String:
	match org_id:
		"government":
			return "Government"
		"cartel":
			return "Cartel"
		_:
			if org_id == "":
				return "Unknown"
			return org_id.capitalize()


func _bucket_influence(weight: float) -> String:
	if weight >= 0.6:
		return "Dominant"
	if weight >= 0.2:
		return "Present"
	return "Trace"
