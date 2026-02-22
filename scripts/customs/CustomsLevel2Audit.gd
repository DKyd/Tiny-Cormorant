extends RefCounted
class_name CustomsLevel2Audit

const STATUS_PASS: String = "pass"
const STATUS_FAIL: String = "fail"
const STATUS_NOT_EVALUABLE: String = "not_evaluable"

const SEVERITY_INVALID: String = "invalid"
const SEVERITY_SUSPICIOUS: String = "suspicious"
const SEVERITY_NONE: String = "none"

const CustomsInvariants = preload("res://scripts/customs/CustomsInvariants.gd")


static func build_level2_audit(ctx: Dictionary) -> Dictionary:
	var safe_ctx: Dictionary = {}
	if ctx is Dictionary:
		safe_ctx = (ctx as Dictionary).duplicate(true)

	var invariants_variant = CustomsInvariants.evaluate(safe_ctx)
	var normalized_pairs: Array = []
	if invariants_variant is Array:
		var invariant_results: Array = invariants_variant
		for i in range(invariant_results.size()):
			var normalized: Dictionary = _normalize_invariant_result(invariant_results[i], i)
			normalized_pairs.append({
				"sort_key": String(normalized.get("invariant_id", "")),
				"index": i,
				"value": normalized,
			})

	_sort_pairs(normalized_pairs)

	var invariants: Array = []
	var findings: Array = []
	var has_failed: bool = false
	var has_invalid_failed: bool = false

	for pair_variant in normalized_pairs:
		if not (pair_variant is Dictionary):
			continue
		var pair: Dictionary = pair_variant
		var invariant_variant = pair.get("value", {})
		if not (invariant_variant is Dictionary):
			continue
		var invariant: Dictionary = invariant_variant
		invariants.append(invariant)
		var status: String = String(invariant.get("status", STATUS_NOT_EVALUABLE)).to_lower()
		if status != STATUS_FAIL:
			continue
		has_failed = true
		var severity: String = String(invariant.get("severity", SEVERITY_NONE)).to_lower()
		if severity == SEVERITY_INVALID:
			has_invalid_failed = true
		var finding := {
			"invariant_id": String(invariant.get("invariant_id", "")),
			"code": String(invariant.get("invariant_id", "")),
			"severity": severity,
			"status": status,
			"message": String(invariant.get("message", "")),
		}
		var details_variant = invariant.get("details", null)
		if details_variant is Dictionary and not (details_variant as Dictionary).is_empty():
			finding["details"] = (details_variant as Dictionary).duplicate(true)
		findings.append(finding)

	var classification: String = "clean"
	if has_invalid_failed:
		classification = "invalid"
	elif has_failed:
		classification = "suspicious"

	return {
		"classification": classification,
		"invariants": invariants,
		"findings": findings,
	}


static func _normalize_invariant_result(invariant_variant, index: int) -> Dictionary:
	var source: Dictionary = {}
	if invariant_variant is Dictionary:
		source = (invariant_variant as Dictionary)

	var invariant_id: String = String(source.get("invariant_id", source.get("id", source.get("code", "")))).strip_edges()
	if invariant_id == "":
		invariant_id = "L2INV-UNKNOWN-%03d" % index

	var status: String = String(source.get("status", STATUS_NOT_EVALUABLE)).to_lower()
	match status:
		STATUS_PASS, STATUS_FAIL, STATUS_NOT_EVALUABLE:
			pass
		_:
			status = STATUS_NOT_EVALUABLE

	var severity: String = String(source.get("severity", SEVERITY_NONE)).to_lower()
	match severity:
		SEVERITY_INVALID, SEVERITY_SUSPICIOUS, SEVERITY_NONE:
			pass
		_:
			severity = SEVERITY_NONE

	var message: String = String(source.get("summary", source.get("message", ""))).strip_edges()
	if message == "":
		message = "No summary provided."

	var normalized := {
		"invariant_id": invariant_id,
		"severity": severity,
		"status": status,
		"message": message,
	}
	var details_variant = source.get("details", null)
	if details_variant is Dictionary and not (details_variant as Dictionary).is_empty():
		normalized["details"] = (details_variant as Dictionary).duplicate(true)
	return normalized


static func _sort_pairs(pairs: Array) -> void:
	for i in range(pairs.size()):
		for j in range(i + 1, pairs.size()):
			var left_variant = pairs[i]
			var right_variant = pairs[j]
			if not (left_variant is Dictionary) or not (right_variant is Dictionary):
				continue
			var left: Dictionary = left_variant
			var right: Dictionary = right_variant
			var left_key: String = String(left.get("sort_key", ""))
			var right_key: String = String(right.get("sort_key", ""))
			var should_swap: bool = false
			if right_key < left_key:
				should_swap = true
			elif right_key == left_key and int(right.get("index", 0)) < int(left.get("index", 0)):
				should_swap = true
			if should_swap:
				pairs[i] = right
				pairs[j] = left

