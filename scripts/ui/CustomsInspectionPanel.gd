extends Control

signal close_requested

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var inspection_id_value: Label = $MarginContainer/VBoxContainer/MetaGrid/InspectionIdValue
@onready var tick_value: Label = $MarginContainer/VBoxContainer/MetaGrid/TickValue
@onready var system_value: Label = $MarginContainer/VBoxContainer/MetaGrid/SystemValue
@onready var location_value: Label = $MarginContainer/VBoxContainer/MetaGrid/LocationValue
@onready var classification_value: Label = $MarginContainer/VBoxContainer/MetaGrid/ClassificationValue
@onready var reasons_text: RichTextLabel = $MarginContainer/VBoxContainer/ReasonsText
@onready var docs_considered_value: Label = $MarginContainer/VBoxContainer/DocSummaryGrid/DocsConsideredValue
@onready var destroyed_docs_value: Label = $MarginContainer/VBoxContainer/DocSummaryGrid/DestroyedDocsValue
@onready var min_authenticity_value: Label = $MarginContainer/VBoxContainer/DocSummaryGrid/MinAuthenticityValue
@onready var declared_qty_modified_value: Label = $MarginContainer/VBoxContainer/DocSummaryGrid/DeclaredQtyModifiedValue
@onready var container_meta_modified_value: Label = $MarginContainer/VBoxContainer/DocSummaryGrid/ContainerMetaModifiedValue
@onready var document_destroyed_value: Label = $MarginContainer/VBoxContainer/DocSummaryGrid/DocumentDestroyedValue
@onready var recommended_value: Label = $MarginContainer/VBoxContainer/RecommendedValue
@onready var close_button: Button = $MarginContainer/VBoxContainer/CloseButton


func _ready() -> void:
	title_label.text = "Customs Inspection"
	reasons_text.bbcode_enabled = false
	if close_button and not close_button.pressed.is_connected(_on_close_pressed):
		close_button.pressed.connect(_on_close_pressed)
	_set_empty_report()


func set_report(report: Dictionary) -> void:
	if report.is_empty():
		_set_empty_report()
		return

	inspection_id_value.text = str(report.get("inspection_id", "-"))
	tick_value.text = str(report.get("tick", "-"))
	system_value.text = str(report.get("system_id", "-"))
	location_value.text = str(report.get("location_id", "-"))
	classification_value.text = str(report.get("classification", "-"))

	reasons_text.text = _format_reasons(report.get("reasons", []))

	var doc_summary: Dictionary = report.get("doc_summary", {})
	docs_considered_value.text = str(doc_summary.get("num_docs_considered", 0))
	destroyed_docs_value.text = str(doc_summary.get("num_destroyed_docs", 0))
	min_authenticity_value.text = str(doc_summary.get("min_authenticity", 0))

	var evidence: Dictionary = doc_summary.get("evidence_flags", {})
	declared_qty_modified_value.text = str(evidence.get("declared_quantity_modified_count", 0))
	container_meta_modified_value.text = str(evidence.get("container_meta_modified_count", 0))
	document_destroyed_value.text = str(evidence.get("document_destroyed_count", 0))

	recommended_value.text = _format_recommended_penalty(report.get("recommended_penalty", {}))


func _set_empty_report() -> void:
	inspection_id_value.text = "-"
	tick_value.text = "-"
	system_value.text = "-"
	location_value.text = "-"
	classification_value.text = "-"
	reasons_text.text = "None"
	docs_considered_value.text = "0"
	destroyed_docs_value.text = "0"
	min_authenticity_value.text = "0"
	declared_qty_modified_value.text = "0"
	container_meta_modified_value.text = "0"
	document_destroyed_value.text = "0"
	recommended_value.text = "None"


func _format_reasons(reasons_variant) -> String:
	if not (reasons_variant is Array):
		return "None"

	var reasons: Array = reasons_variant
	if reasons.is_empty():
		return "None"

	var lines: Array = []
	for reason_variant in reasons:
		var reason: String = str(reason_variant)
		if reason != "":
			lines.append("- %s" % reason)

	if lines.is_empty():
		return "None"
	return "\n".join(lines)


func _format_recommended_penalty(penalty_variant) -> String:
	if not (penalty_variant is Dictionary):
		return "None"

	var penalty: Dictionary = penalty_variant
	if not bool(penalty.get("should_issue_fine", false)):
		return "None"

	return "Fine %.0f due at %s/%s (issuer: %s, due_tick: %s)" % [
		float(penalty.get("suggested_amount", 0.0)),
		str(penalty.get("payable_at_system_id", "")),
		str(penalty.get("payable_at_location_id", "")),
		str(penalty.get("issuer_org_id", "")),
		str(penalty.get("due_tick", 0)),
	]


func _on_close_pressed() -> void:
	emit_signal("close_requested")
