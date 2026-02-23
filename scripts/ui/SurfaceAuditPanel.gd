extends Control
class_name SurfaceAuditPanel

@onready var status_value: Label = $MarginContainer/VBoxContainer/StatusValue
@onready var findings_text: RichTextLabel = $MarginContainer/VBoxContainer/FindingsText

var _reported_malformed_payload: bool = false


func _ready() -> void:
	findings_text.bbcode_enabled = false
	set_audit({})


func set_audit(audit_payload: Dictionary) -> void:
	if audit_payload.is_empty():
		status_value.text = "No audit available"
		findings_text.text = "No Level 1 surface audit payload was attached to this inspection."
		return

	var findings_variant = audit_payload.get("findings", null)
	if not (findings_variant is Array):
		_set_malformed_payload()
		return

	var classification: String = String(audit_payload.get("classification", "")).strip_edges().to_lower()
	match classification:
		"clean":
			status_value.text = "PASS"
		"invalid", "suspicious":
			status_value.text = "WARN"
		_:
			status_value.text = "WARN"

	var findings: Array = findings_variant
	if findings.is_empty():
		findings_text.text = "No Level 1 findings."
		return

	var lines: Array[String] = []
	for finding_variant in findings:
		if not (finding_variant is Dictionary):
			continue
		var finding: Dictionary = finding_variant
		var code: String = String(finding.get("code", finding.get("finding_id", "finding"))).strip_edges()
		if code == "":
			code = "finding"
		var message: String = String(finding.get("message", "")).strip_edges()
		if message == "":
			message = "No message provided."
		lines.append("- %s: %s" % [code, message])

	if lines.is_empty():
		findings_text.text = "No Level 1 findings."
		return

	findings_text.text = "\n".join(lines)


func _set_malformed_payload() -> void:
	status_value.text = "WARN"
	findings_text.text = "Level 1 audit payload is malformed."
	if _reported_malformed_payload:
		return
	_reported_malformed_payload = true
