extends Control

signal close_requested

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var inspection_id_value: Label = $MarginContainer/VBoxContainer/MetaGrid/InspectionIdValue
@onready var tick_value: Label = $MarginContainer/VBoxContainer/MetaGrid/TickValue
@onready var system_value: Label = $MarginContainer/VBoxContainer/MetaGrid/SystemValue
@onready var location_value: Label = $MarginContainer/VBoxContainer/MetaGrid/LocationValue
@onready var classification_value: Label = $MarginContainer/VBoxContainer/MetaGrid/ClassificationValue
@onready var reasons_text: RichTextLabel = $MarginContainer/VBoxContainer/ReasonsText
@onready var surface_audit_panel: SurfaceAuditPanel = $MarginContainer/VBoxContainer/SurfaceAuditPanel
@onready var level2_audit_status: Label = $MarginContainer/VBoxContainer/Level2AuditStatus
@onready var level2_audit_findings: RichTextLabel = $MarginContainer/VBoxContainer/Level2AuditFindings
@onready var level3_reconciliation_status: Label = $MarginContainer/VBoxContainer/Level3ReconciliationStatus
@onready var level3_reconciliation_findings: RichTextLabel = $MarginContainer/VBoxContainer/Level3ReconciliationFindings
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
	level2_audit_findings.bbcode_enabled = false
	level3_reconciliation_findings.bbcode_enabled = false
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
	if surface_audit_panel:
		surface_audit_panel.set_audit(report.get("level1_audit", {}))
	_set_level2_audit(report.get("level2_audit", null))
	_set_level3_reconciliation(report.get("level3_reconciliation", null))

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
	if surface_audit_panel:
		surface_audit_panel.set_audit({})
	_set_level2_audit(null)
	_set_level3_reconciliation(null)
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


func _set_level2_audit(level2_variant) -> void:
	if not (level2_variant is Dictionary):
		level2_audit_status.text = "No Level 2 documentary audit attached."
		level2_audit_findings.text = "This inspection did not include a Level 2 documentary audit payload."
		return

	var level2: Dictionary = level2_variant
	if level2.is_empty():
		level2_audit_status.text = "No Level 2 documentary audit attached."
		level2_audit_findings.text = "This inspection did not include a Level 2 documentary audit payload."
		return

	var classification_raw: String = String(level2.get("classification", "")).strip_edges().to_lower()
	if classification_raw == "":
		level2_audit_status.text = "Level 2 documentary audit unavailable."
		level2_audit_findings.text = "Level 2 payload was attached, but its outcome was missing or malformed."
		return

	level2_audit_status.text = "Outcome: %s" % _format_level2_classification(classification_raw)
	level2_audit_findings.text = _format_level2_findings(level2)


func _format_level2_classification(classification: String) -> String:
	match classification:
		"clean":
			return "Clean"
		"suspicious":
			return "Suspicious"
		"invalid":
			return "Invalid"
		_:
			return classification.capitalize()


func _format_level2_findings(level2: Dictionary) -> String:
	var findings_variant = level2.get("findings", null)
	if findings_variant == null:
		return "No Level 2 findings payload was attached."
	if not (findings_variant is Array):
		return "Level 2 findings were present but malformed."

	var findings: Array = findings_variant
	if findings.is_empty():
		return "No Level 2 documentary findings were reported."

	var lines: Array[String] = []
	for finding_variant in findings:
		if not (finding_variant is Dictionary):
			lines.append("- Finding payload was malformed.")
			continue
		var finding: Dictionary = finding_variant
		lines.append(_format_level2_finding(finding))

	if lines.is_empty():
		return "No Level 2 documentary findings were reported."
	return "\n".join(lines)


func _format_level2_finding(finding: Dictionary) -> String:
	var code: String = String(finding.get("invariant_id", finding.get("code", ""))).strip_edges()
	if code == "":
		code = "L2-UNKNOWN"

	var severity: String = String(finding.get("severity", "")).strip_edges().to_lower()
	var status: String = String(finding.get("status", "")).strip_edges().to_lower()
	var message: String = String(finding.get("message", finding.get("summary", ""))).strip_edges()
	if message == "":
		message = "No finding summary provided."

	var prefix: String = "- %s" % code
	var tags: Array[String] = []
	if severity != "":
		tags.append(severity.capitalize())
	if status != "":
		tags.append(status.replace("_", " ").capitalize())
	if not tags.is_empty():
		prefix = "%s (%s)" % [prefix, ", ".join(tags)]

	var detail_suffix: String = _format_level2_finding_details(finding.get("details", null))
	if detail_suffix != "":
		return "%s: %s %s" % [prefix, message, detail_suffix]
	return "%s: %s" % [prefix, message]


func _format_level2_finding_details(details_variant) -> String:
	if not (details_variant is Dictionary):
		return ""

	var details: Dictionary = details_variant
	if details.is_empty():
		return ""

	var parts: Array[String] = []
	var reason: String = String(details.get("reason", "")).strip_edges()
	if reason != "":
		parts.append("Reason: %s." % reason.replace("_", " "))

	var missing_inputs_variant = details.get("missing_inputs", null)
	if missing_inputs_variant is Array and not (missing_inputs_variant as Array).is_empty():
		var missing_parts: Array[String] = []
		for item_variant in missing_inputs_variant:
			var item: String = String(item_variant).strip_edges()
			if item != "":
				missing_parts.append(item)
		if not missing_parts.is_empty():
			parts.append("Missing inputs: %s." % ", ".join(missing_parts))

	if parts.is_empty():
		return ""
	return "[%s]" % " ".join(parts)


func _set_level3_reconciliation(level3_variant) -> void:
	if not (level3_variant is Dictionary):
		level3_reconciliation_status.text = "No Level 3 reconciliation attached."
		level3_reconciliation_findings.text = "This inspection did not include a Level 3 reconciliation payload."
		return

	var level3: Dictionary = level3_variant
	if level3.is_empty():
		level3_reconciliation_status.text = "No Level 3 reconciliation attached."
		level3_reconciliation_findings.text = "This inspection did not include a Level 3 reconciliation payload."
		return

	var classification_raw: String = String(level3.get("classification", "")).strip_edges().to_lower()
	if classification_raw == "":
		level3_reconciliation_status.text = "Level 3 reconciliation unavailable."
		level3_reconciliation_findings.text = "Level 3 payload was attached, but its outcome was missing or malformed."
		return

	level3_reconciliation_status.text = "Outcome: %s" % _format_level3_classification(classification_raw)
	level3_reconciliation_findings.text = _format_level3_reconciliation_details(level3, classification_raw)


func _format_level3_classification(classification: String) -> String:
	match classification:
		"clean":
			return "Clean"
		"suspicious":
			return "Suspicious"
		"not_evaluable":
			return "Not evaluable"
		_:
			return classification.replace("_", " ").capitalize()


func _format_level3_reconciliation_details(level3: Dictionary, classification: String) -> String:
	var lines: Array[String] = []
	var summary: String = String(level3.get("summary", "")).strip_edges()
	if summary != "":
		lines.append(summary)
	else:
		lines.append(_get_level3_fallback_summary(classification))

	_append_level3_findings(lines, level3.get("findings", null), classification)
	_append_level3_not_evaluable(lines, level3.get("not_evaluable", null), classification)

	if lines.is_empty():
		return _get_level3_fallback_summary(classification)
	return "\n".join(lines)


func _get_level3_fallback_summary(classification: String) -> String:
	match classification:
		"clean":
			return "Declared cargo and runtime cargo are within reconciliation tolerance."
		"suspicious":
			return "Reconciliation found report-only mismatches."
		"not_evaluable":
			return "Reconciliation could not fully evaluate the available paperwork and cargo snapshot."
		_:
			return "Level 3 reconciliation payload was attached, but its outcome is not recognized."


func _append_level3_findings(lines: Array[String], findings_variant, classification: String) -> void:
	if findings_variant == null:
		if classification == "suspicious":
			lines.append("Level 3 reported mismatches, but no findings payload was attached.")
		return
	if not (findings_variant is Array):
		lines.append("Level 3 findings were present but malformed.")
		return

	var findings: Array = findings_variant
	var appended_count: int = 0
	for finding_variant in findings:
		if appended_count >= 3:
			break
		if not (finding_variant is Dictionary):
			lines.append("- Finding payload was malformed.")
			appended_count += 1
			continue
		var finding: Dictionary = finding_variant
		lines.append(_format_level3_finding(finding))
		appended_count += 1

	if findings.size() > appended_count:
		lines.append("Additional Level 3 items omitted from this view.")


func _format_level3_finding(finding: Dictionary) -> String:
	var code: String = String(finding.get("code", finding.get("check_id", ""))).strip_edges()
	if code == "":
		code = "L3-UNKNOWN"

	var message: String = String(finding.get("message", finding.get("summary", ""))).strip_edges()
	if message == "":
		message = "No finding summary provided."

	var detail_suffix: String = _format_level3_details_suffix(finding.get("details", null))
	if detail_suffix != "":
		return "- %s: %s %s" % [code, message, detail_suffix]
	return "- %s: %s" % [code, message]


func _append_level3_not_evaluable(lines: Array[String], not_evaluable_variant, classification: String) -> void:
	if not_evaluable_variant == null:
		if classification == "not_evaluable":
			lines.append("Level 3 was not evaluable, but no not-evaluable details were attached.")
		return
	if not (not_evaluable_variant is Array):
		lines.append("Level 3 not-evaluable details were present but malformed.")
		return

	var not_evaluable: Array = not_evaluable_variant
	var appended_count: int = 0
	for entry_variant in not_evaluable:
		if appended_count >= 3:
			break
		if not (entry_variant is Dictionary):
			lines.append("- Not evaluable: malformed entry.")
			appended_count += 1
			continue
		var entry: Dictionary = entry_variant
		lines.append(_format_level3_not_evaluable_entry(entry))
		appended_count += 1

	if not_evaluable.size() > appended_count:
		lines.append("Additional Level 3 items omitted from this view.")


func _format_level3_not_evaluable_entry(entry: Dictionary) -> String:
	var reason: String = String(entry.get("reason", "")).strip_edges()
	if reason == "":
		reason = "unspecified"

	var detail_parts: Array[String] = []
	var commodity_id: String = String(entry.get("commodity_id", "")).strip_edges()
	if commodity_id != "":
		detail_parts.append("Commodity: %s." % commodity_id)
	var doc_id: String = String(entry.get("doc_id", "")).strip_edges()
	if doc_id != "":
		detail_parts.append("Doc: %s." % doc_id)
	var path: String = String(entry.get("path", "")).strip_edges()
	if path != "":
		detail_parts.append("Path: %s." % path)

	if not detail_parts.is_empty():
		return "- Not evaluable: %s [%s]" % [reason.replace("_", " "), " ".join(detail_parts)]
	return "- Not evaluable: %s" % reason.replace("_", " ")


func _format_level3_details_suffix(details_variant) -> String:
	if not (details_variant is Dictionary):
		return ""

	var details: Dictionary = details_variant
	var parts: Array[String] = []
	var reason: String = String(details.get("reason", "")).strip_edges()
	if reason != "":
		parts.append("Reason: %s." % reason.replace("_", " "))

	var commodity_id: String = String(details.get("commodity_id", "")).strip_edges()
	if commodity_id != "":
		parts.append("Commodity: %s." % commodity_id)

	var doc_id: String = String(details.get("doc_id", "")).strip_edges()
	if doc_id != "":
		parts.append("Doc: %s." % doc_id)

	if parts.is_empty():
		return ""
	return "[%s]" % " ".join(parts)


func _on_close_pressed() -> void:
	emit_signal("close_requested")
