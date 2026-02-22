extends RefCounted

const DEFAULT_LEVEL2_LOG_TOP_N: int = 3
const DEFAULT_LEVEL2_VERBOSE_LOG: bool = false


static func _ensure_sentence_end(text: String) -> String:
	var trimmed: String = text.strip_edges()
	if trimmed == "":
		return ""
	if trimmed.ends_with("."):
		return trimmed
	return "%s." % trimmed


static func _extract_reason_message(reason_variant) -> String:
	if reason_variant is Dictionary:
		var reason: Dictionary = reason_variant
		return String(reason.get("message", "")).strip_edges()
	return String(reason_variant).strip_edges()


static func _format_customs_summary(classification: String, reasons_variant) -> String:
	var summary: String = ""
	if reasons_variant is Array and reasons_variant.size() > 0:
		summary = _extract_reason_message(reasons_variant[0])
	if summary == "":
		if classification == "CLEAN":
			summary = "No irregularities detected"
		else:
			summary = "Inspection flagged issues"
	return _ensure_sentence_end(summary)


static func _format_customs_recommendation(report: Dictionary) -> String:
	var penalty_variant = report.get("recommended_penalty", {})
	if not (penalty_variant is Dictionary):
		return ""
	var penalty: Dictionary = penalty_variant
	var action: String = String(penalty.get("recommended_action", ""))
	if action == "":
		action = String(penalty.get("action", ""))
	if action != "":
		return _ensure_sentence_end("Recommended action: %s" % action)
	var suggested_amount: float = float(penalty.get("suggested_amount", 0.0))
	if suggested_amount > 0.0:
		return "Recommended fine: %.0f credits." % suggested_amount
	return ""


static func _normalize_customs_classification(raw_value: String) -> String:
	var classification_raw: String = raw_value.to_upper()
	match classification_raw:
		"CLEAN", "SUSPICIOUS", "INVALID":
			return classification_raw
		_:
			return "SUSPICIOUS"


static func _get_level2_display_severity_rank(severity_value: String) -> int:
	var severity: String = severity_value.to_lower()
	if severity == "invalid":
		return 0
	if severity == "suspicious":
		return 1
	return 2


static func _sort_level2_display_findings(a: Dictionary, b: Dictionary) -> bool:
	var rank_a: int = _get_level2_display_severity_rank(String(a.get("severity", "")))
	var rank_b: int = _get_level2_display_severity_rank(String(b.get("severity", "")))
	if rank_a != rank_b:
		return rank_a < rank_b
	var code_a: String = String(a.get("code", ""))
	var code_b: String = String(b.get("code", ""))
	if code_a != code_b:
		return code_a < code_b
	var message_a: String = String(a.get("message", ""))
	var message_b: String = String(b.get("message", ""))
	return message_a < message_b


static func _sort_display_findings_in_place(display_findings: Array) -> void:
	for i in range(display_findings.size()):
		for j in range(i + 1, display_findings.size()):
			var left: Dictionary = display_findings[i]
			var right: Dictionary = display_findings[j]
			if _sort_level2_display_findings(right, left):
				display_findings[i] = right
				display_findings[j] = left


static func _trim_for_customs_log(text: String, max_chars: int = 72) -> String:
	var trimmed: String = text.strip_edges()
	if trimmed.length() <= max_chars:
		return trimmed
	if max_chars <= 3:
		return trimmed.substr(0, max(0, max_chars))
	return "%s..." % trimmed.substr(0, max_chars - 3)


static func _build_level2_display_findings(level2: Dictionary) -> Array:
	var findings_variant = level2.get("findings", [])
	if not (findings_variant is Array):
		return []
	var findings: Array = findings_variant
	var reasons: Array = []
	var reasons_variant = level2.get("reasons", [])
	if reasons_variant is Array:
		reasons = reasons_variant

	var display_findings: Array = []
	for index in range(findings.size()):
		var finding_variant = findings[index]
		if not (finding_variant is Dictionary):
			continue
		var finding: Dictionary = finding_variant
		var code: String = String(finding.get("code", "")).strip_edges()
		if code == "":
			continue
		var severity: String = String(finding.get("severity", "")).to_lower()
		var message: String = String(finding.get("message", "")).strip_edges()
		if message == "" and index < reasons.size():
			message = _extract_reason_message(reasons[index])
		if message == "":
			message = "Issue flagged."
		display_findings.append({
			"code": code,
			"severity": severity,
			"message": message,
		})

	_sort_display_findings_in_place(display_findings)
	return display_findings


static func format_level2_log_snippet(
	report: Dictionary,
	level2_log_top_n: int = DEFAULT_LEVEL2_LOG_TOP_N,
	level2_verbose_log: bool = DEFAULT_LEVEL2_VERBOSE_LOG
) -> String:
	var invariant_summary: String = String(report.get("level2_invariant_summary", "")).strip_edges()
	if invariant_summary != "":
		return invariant_summary
	var level2_variant = report.get("level2_audit", null)
	if not (level2_variant is Dictionary):
		return ""
	var level2: Dictionary = level2_variant
	var classification_raw: String = String(level2.get("classification", ""))
	if classification_raw == "":
		return ""
	var classification: String = _normalize_customs_classification(classification_raw)
	var message: String = "Level-2: %s" % classification
	var display_findings: Array = _build_level2_display_findings(level2)
	if classification != "CLEAN" and not display_findings.is_empty():
		var visible_count: int = min(level2_log_top_n, display_findings.size())
		var parts: Array[String] = []
		for i in range(visible_count):
			var item: Dictionary = display_findings[i]
			var code: String = String(item.get("code", "")).strip_edges()
			var reason: String = _trim_for_customs_log(String(item.get("message", "")), 64)
			parts.append("%s: %s" % [code, reason])
		var details: String = ", ".join(parts)
		var remaining: int = display_findings.size() - visible_count
		if remaining > 0:
			details = "%s, +%d more" % [details, remaining]
		message = "%s [%s]" % [message, details]
	elif classification != "CLEAN":
		var summary: String = _format_customs_summary(classification, level2.get("reasons", []))
		message = "%s — %s" % [message, summary]
	if level2_verbose_log:
		var findings_variant = level2.get("findings", [])
		var total_finding_count: int = display_findings.size()
		if findings_variant is Array:
			total_finding_count = (findings_variant as Array).size()
		var top_findings: Array = []
		var top_count: int = min(level2_log_top_n, display_findings.size())
		for i in range(top_count):
			var item: Dictionary = display_findings[i]
			top_findings.append({
				"code": String(item.get("code", "")).strip_edges(),
				"severity": String(item.get("severity", "")).strip_edges(),
				"message": _trim_for_customs_log(String(item.get("message", "")), 64),
			})
		var verbose_payload := {
			"classification": String(level2.get("classification", "")).to_lower(),
			"total_finding_count": total_finding_count,
			"display_count": int(display_findings.size()),
			"top_findings": top_findings,
		}
		message = "%s [DEV:%s]" % [message, JSON.stringify(verbose_payload)]

	return message


static func build_level2_invariant_log_summary(
	report: Dictionary,
	level2_log_top_n: int = DEFAULT_LEVEL2_LOG_TOP_N
) -> String:
	var invariant_variant = report.get("invariant_violations", null)
	if invariant_variant == null:
		return "Level-2 invariants: unavailable."
	if not (invariant_variant is Array):
		return "Level-2 invariants: unavailable."
	var invariant_violations: Array = invariant_variant
	if invariant_violations.is_empty():
		return "Level-2 invariants: none found."

	var display_findings: Array = []
	for finding_variant in invariant_violations:
		if not (finding_variant is Dictionary):
			continue
		var finding: Dictionary = finding_variant
		var code: String = String(finding.get("code", "")).strip_edges()
		if code == "":
			code = "L2-UNKNOWN"
		var severity: String = String(finding.get("severity", "")).to_lower()
		var message: String = String(finding.get("message", "")).strip_edges()
		if message == "":
			message = "Issue flagged."
		display_findings.append({
			"code": code,
			"severity": severity,
			"message": message,
		})

	_sort_display_findings_in_place(display_findings)
	if display_findings.is_empty():
		return "Level-2 invariants: unavailable."

	var visible_count: int = min(level2_log_top_n, display_findings.size())
	var parts: Array[String] = []
	for i in range(visible_count):
		var item: Dictionary = display_findings[i]
		var code: String = String(item.get("code", "")).strip_edges()
		var reason: String = _trim_for_customs_log(String(item.get("message", "")), 64)
		parts.append("%s: %s" % [code, reason])
	var details: String = ", ".join(parts)
	var remaining: int = display_findings.size() - visible_count
	if remaining > 0:
		details = "%s, +%d more" % [details, remaining]
	return "Level-2 invariants: %d violation(s) [%s]" % [display_findings.size(), details]


static func format_customs_log_entry(
	report: Dictionary,
	level2_log_top_n: int = DEFAULT_LEVEL2_LOG_TOP_N,
	level2_verbose_log: bool = DEFAULT_LEVEL2_VERBOSE_LOG
) -> String:
	var classification_raw: String = String(report.get("classification", "")).to_upper()
	var classification: String = classification_raw
	match classification_raw:
		"CLEAN", "SUSPICIOUS", "INVALID":
			classification = classification_raw
		_:
			classification = "SUSPICIOUS"

	var summary: String = _format_customs_summary(classification, report.get("reasons", []))
	var recommendation: String = _format_customs_recommendation(report)
	var message: String = "CUSTOMS: %s — %s" % [classification, summary]
	if recommendation != "":
		message = "%s %s" % [message, recommendation]
	var level2_summary: String = format_level2_log_snippet(
		report,
		level2_log_top_n,
		level2_verbose_log
	)
	if level2_summary != "":
		message = "%s %s" % [message, level2_summary]
	return message
