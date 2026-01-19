extends PanelContainer

@onready var dev_toggle: CheckBox = %DevToggle
@onready var log_output: RichTextLabel = %LogOutput

const COLOR_SHIP := Color8(111, 214, 122)
const COLOR_CUSTOMS := Color8(243, 163, 74)
const COLOR_OTHER := Color8(176, 176, 176)

var _missing_log_output_warned: bool = false


func _ready() -> void:
	if log_output == null:
		_report_missing_log_output()
		return
	if dev_toggle != null:
		dev_toggle.toggled.connect(_on_dev_toggled)
	Log.message_added.connect(_on_log_message_added)
	_refresh_log()


func _refresh_log() -> void:
	if log_output == null:
		_report_missing_log_output()
		return
	log_output.clear()
	var count: int = Log.get_entry_count()
	var show_dev: bool = dev_toggle != null and dev_toggle.button_pressed
	for i in range(count):
		var text: String = Log.get_entry_text(i)
		var category: String = Log.get_entry_category(i)
		var prefix: String = ""
		if show_dev:
			var context: Dictionary = Log.get_entry_context(i)
			var tick: int = int(context.get("tick", -1))
			var system_id: String = String(context.get("system_id", ""))
			var location_id: String = String(context.get("location_id", ""))
			prefix = "[t=%d sys=%s loc=%s] " % [tick, system_id, location_id]

		log_output.push_color(_get_color_for_category(category))
		log_output.add_text("%s%s\n" % [prefix, text])
		log_output.pop()

	if log_output.get_line_count() > 0:
		log_output.scroll_to_line(log_output.get_line_count() - 1)


func _get_color_for_category(category: String) -> Color:
	match category.strip_edges().to_upper():
		"SHIP":
			return COLOR_SHIP
		"CUSTOMS":
			return COLOR_CUSTOMS
		_:
			return COLOR_OTHER


func _report_missing_log_output() -> void:
	if _missing_log_output_warned:
		return
	_missing_log_output_warned = true
	push_error("LogPanel: %LogOutput not found (Unique Name in Owner may be off).")


func _on_log_message_added() -> void:
	_refresh_log()


func _on_dev_toggled(_pressed: bool) -> void:
	_refresh_log()
