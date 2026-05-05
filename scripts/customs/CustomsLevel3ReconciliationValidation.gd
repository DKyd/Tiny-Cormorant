extends SceneTree
class_name CustomsLevel3ReconciliationValidation

const CustomsLevel3Reconciliation = preload("res://scripts/customs/CustomsLevel3Reconciliation.gd")


func _init() -> void:
	var result: Dictionary = run_validation()
	print(JSON.stringify(result, "\t"))
	quit(0 if bool(result.get("ok", false)) else 1)


static func run_validation() -> Dictionary:
	var cases: Array = _build_cases()
	var case_results: Array = []
	var failures: Array = []
	var deterministic: bool = true
	var passed_count: int = 0

	for case in cases:
		var case_result: Dictionary = _run_case(case)
		case_results.append(case_result)
		if bool(case_result.get("ok", false)):
			passed_count += 1
		if not bool(case_result.get("deterministic", false)):
			deterministic = false
		for failure in case_result.get("failures", []):
			failures.append(failure)

	return {
		"ok": failures.is_empty() and deterministic,
		"case_count": cases.size(),
		"passed_count": passed_count,
		"deterministic": deterministic,
		"cases": case_results,
		"failures": failures,
	}


static func _run_case(case: Dictionary) -> Dictionary:
	var name: String = String(case.get("name", "unnamed_case"))
	var ctx: Dictionary = (case.get("ctx", {}) as Dictionary).duplicate(true)
	var report_a: Dictionary = CustomsLevel3Reconciliation.build_level3_reconciliation_report(ctx)
	var report_b: Dictionary = CustomsLevel3Reconciliation.build_level3_reconciliation_report(ctx)
	var signature_a: String = var_to_str(_canonicalize(report_a))
	var signature_b: String = var_to_str(_canonicalize(report_b))
	var deterministic: bool = signature_a == signature_b
	var failures: Array = []

	if not deterministic:
		failures.append(_failure(name, "determinism", "Repeated helper calls produced different reports."))

	_expect_report_field(case, report_a, "classification", failures)
	_expect_report_field(case, report_a, "status", failures)
	_expect_checks(case, report_a, failures)
	_expect_not_evaluable_reasons(case, report_a, failures)
	_expect_finding_reasons(case, report_a, failures)

	return {
		"name": name,
		"ok": failures.is_empty() and deterministic,
		"deterministic": deterministic,
		"classification": String(report_a.get("classification", "")),
		"status": String(report_a.get("status", "")),
		"check_statuses": _check_statuses(report_a),
		"not_evaluable_reasons": _not_evaluable_reasons(report_a),
		"finding_reasons": _finding_reasons(report_a),
		"failures": failures,
	}


static func _build_cases() -> Array:
	return [
		{
			"name": "clean",
			"ctx": _base_context(5, 5, "standard_freight_crate"),
			"expected_classification": "clean",
			"expected_status": "pass",
			"expected_checks": {
				"L3REC-001": "pass",
				"L3REC-002": "pass",
				"L3REC-003": "pass",
				"L3REC-004": "pass",
				"L3REC-005": "pass",
				"L3REC-006": "pass",
			},
			"expected_not_evaluable": [],
			"expected_findings": [],
		},
		{
			"name": "mismatch",
			"ctx": _base_context(5, 8, "standard_freight_crate"),
			"expected_classification": "suspicious",
			"expected_status": "fail",
			"expected_checks": {
				"L3REC-004": "fail",
				"L3REC-005": "fail",
			},
			"expected_findings": [
				"quantity_mismatch",
				"mass_delta_exceeds_tolerance",
			],
		},
		{
			"name": "missing_docs",
			"ctx": {
				"cargo": {"ore_iron": 5},
				"action": "validation",
				"system_id": "VAL",
				"location_id": "VAL-PORT",
				"tick": 133,
			},
			"expected_checks": {
				"L3REC-001": "not_evaluable",
				"L3REC-004": "not_evaluable",
				"L3REC-005": "not_evaluable",
				"L3REC-006": "not_evaluable",
			},
			"expected_not_evaluable": [
				"missing_docs_snapshot",
				"missing_quantity_comparison_inputs",
			],
		},
		{
			"name": "missing_cargo",
			"ctx": _base_context_without_cargo(5, "standard_freight_crate"),
			"expected_checks": {
				"L3REC-002": "not_evaluable",
				"L3REC-004": "not_evaluable",
				"L3REC-005": "not_evaluable",
			},
			"expected_not_evaluable": [
				"missing_runtime_cargo_snapshot",
				"missing_quantity_comparison_inputs",
			],
		},
		{
			"name": "unknown_commodity_mass",
			"ctx": _context_for_commodity("validation_unknown_commodity", 2, 2, "standard_freight_crate"),
			"expected_checks": {
				"L3REC-004": "pass",
				"L3REC-005": "not_evaluable",
			},
			"expected_not_evaluable": ["unknown_commodity_mass"],
		},
		{
			"name": "missing_tolerance_policy",
			"ctx": _base_context(5, 5, "standard_freight_crate", "validation_missing_policy"),
			"expected_checks": {
				"L3REC-003": "not_evaluable",
				"L3REC-005": "not_evaluable",
			},
			"expected_not_evaluable": [
				"malformed_tolerance_policy",
				"missing_tolerance_policy",
			],
		},
		{
			"name": "missing_container_class",
			"ctx": _base_context(5, 5, ""),
			"expected_checks": {
				"L3REC-004": "pass",
				"L3REC-005": "pass",
				"L3REC-006": "not_evaluable",
			},
			"expected_not_evaluable": ["missing_container_class_id"],
		},
	]


static func _base_context(declared_qty: int, runtime_qty: int, container_class_id: String, tolerance_policy_id: String = "") -> Dictionary:
	var ctx: Dictionary = _base_context_without_cargo(declared_qty, container_class_id, tolerance_policy_id)
	ctx["cargo"] = {"ore_iron": runtime_qty}
	return ctx


static func _base_context_without_cargo(declared_qty: int, container_class_id: String, tolerance_policy_id: String = "") -> Dictionary:
	return _context_for_commodity_without_cargo("ore_iron", declared_qty, container_class_id, tolerance_policy_id)


static func _context_for_commodity(commodity_id: String, declared_qty: int, runtime_qty: int, container_class_id: String, tolerance_policy_id: String = "") -> Dictionary:
	var ctx: Dictionary = _context_for_commodity_without_cargo(commodity_id, declared_qty, container_class_id, tolerance_policy_id)
	ctx["cargo"] = {commodity_id: runtime_qty}
	return ctx


static func _context_for_commodity_without_cargo(commodity_id: String, declared_qty: int, container_class_id: String, tolerance_policy_id: String = "") -> Dictionary:
	var container_meta: Dictionary = {"container_id": "VAL-CONT-001"}
	if container_class_id != "":
		container_meta["container_class_id"] = container_class_id

	var ctx: Dictionary = {
		"docs": {
			"VAL-DOC-001": {
				"doc_id": "VAL-DOC-001",
				"doc_type": "declaration",
				"cargo_lines": [
					{
						"commodity_id": commodity_id,
						"declared_qty": declared_qty,
					},
				],
				"container_meta": container_meta,
			},
		},
		"action": "validation",
		"system_id": "VAL",
		"location_id": "VAL-PORT",
		"tick": 133,
	}
	if tolerance_policy_id != "":
		ctx["tolerance_policy_id"] = tolerance_policy_id
	return ctx


static func _expect_report_field(case: Dictionary, report: Dictionary, field_name: String, failures: Array) -> void:
	var expected_key: String = "expected_%s" % field_name
	if not case.has(expected_key):
		return
	var name: String = String(case.get("name", "unnamed_case"))
	var expected: String = String(case.get(expected_key, ""))
	var actual: String = String(report.get(field_name, ""))
	if actual != expected:
		failures.append(_failure(name, field_name, "Expected %s, got %s." % [expected, actual]))


static func _expect_checks(case: Dictionary, report: Dictionary, failures: Array) -> void:
	var expected_variant = case.get("expected_checks", {})
	if not (expected_variant is Dictionary):
		return
	var expected_checks: Dictionary = expected_variant
	var actual_checks: Dictionary = _check_statuses(report)
	var check_ids: Array = expected_checks.keys()
	check_ids.sort()
	var name: String = String(case.get("name", "unnamed_case"))
	for check_id_variant in check_ids:
		var check_id: String = String(check_id_variant)
		var expected: String = String(expected_checks[check_id_variant])
		var actual: String = String(actual_checks.get(check_id, ""))
		if actual != expected:
			failures.append(_failure(name, check_id, "Expected check status %s, got %s." % [expected, actual]))


static func _expect_not_evaluable_reasons(case: Dictionary, report: Dictionary, failures: Array) -> void:
	var expected: Array = case.get("expected_not_evaluable", [])
	if expected.is_empty():
		if not _not_evaluable_reasons(report).is_empty():
			failures.append(_failure(String(case.get("name", "unnamed_case")), "not_evaluable", "Expected no not-evaluable reasons."))
		return
	_expect_reasons_present(case, "not_evaluable", expected, _not_evaluable_reasons(report), failures)


static func _expect_finding_reasons(case: Dictionary, report: Dictionary, failures: Array) -> void:
	var expected: Array = case.get("expected_findings", [])
	if expected.is_empty():
		var actual: Array = _finding_reasons(report)
		actual.erase("not_evaluable_inputs")
		if not actual.is_empty():
			failures.append(_failure(String(case.get("name", "unnamed_case")), "findings", "Expected no evaluable findings."))
		return
	_expect_reasons_present(case, "findings", expected, _finding_reasons(report), failures)


static func _expect_reasons_present(case: Dictionary, field_name: String, expected: Array, actual: Array, failures: Array) -> void:
	var name: String = String(case.get("name", "unnamed_case"))
	for reason_variant in expected:
		var reason: String = String(reason_variant)
		if not actual.has(reason):
			failures.append(_failure(name, field_name, "Missing expected reason %s." % reason))


static func _check_statuses(report: Dictionary) -> Dictionary:
	var statuses: Dictionary = {}
	for check_variant in report.get("checks", []):
		if not (check_variant is Dictionary):
			continue
		var check: Dictionary = check_variant
		statuses[String(check.get("check_id", ""))] = String(check.get("status", ""))
	return statuses


static func _not_evaluable_reasons(report: Dictionary) -> Array:
	var reasons: Array = []
	for entry_variant in report.get("not_evaluable", []):
		if not (entry_variant is Dictionary):
			continue
		var reason: String = String((entry_variant as Dictionary).get("reason", ""))
		if reason != "" and not reasons.has(reason):
			reasons.append(reason)
	reasons.sort()
	return reasons


static func _finding_reasons(report: Dictionary) -> Array:
	var reasons: Array = []
	for entry_variant in report.get("findings", []):
		if not (entry_variant is Dictionary):
			continue
		var reason: String = String((entry_variant as Dictionary).get("reason", ""))
		if reason != "" and not reasons.has(reason):
			reasons.append(reason)
	reasons.sort()
	return reasons


static func _failure(case_name: String, assertion: String, message: String) -> Dictionary:
	return {
		"case": case_name,
		"assertion": assertion,
		"message": message,
	}


static func _canonicalize(value):
	if value is Dictionary:
		var result: Dictionary = {}
		var keys: Array = (value as Dictionary).keys()
		keys.sort()
		for key in keys:
			result[key] = _canonicalize((value as Dictionary)[key])
		return result
	if value is Array:
		var result_array: Array = []
		for item in value:
			result_array.append(_canonicalize(item))
		return result_array
	return value
