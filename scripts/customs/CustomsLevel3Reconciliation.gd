class_name CustomsLevel3Reconciliation

const CommodityDB = preload("res://data/CommodityDB.gd")
const CustomsReconciliationDB = preload("res://data/CustomsReconciliationDB.gd")

const SCHEMA_VERSION: int = 1
const LEVEL: int = 3
const KIND: String = "read_only_reconciliation"

const CLASSIFICATION_CLEAN: String = "clean"
const CLASSIFICATION_SUSPICIOUS: String = "suspicious"
const CLASSIFICATION_NOT_EVALUABLE: String = "not_evaluable"

const STATUS_PASS: String = "pass"
const STATUS_FAIL: String = "fail"
const STATUS_NOT_EVALUABLE: String = "not_evaluable"

const SEVERITY_NONE: String = "none"
const SEVERITY_SUSPICIOUS: String = "suspicious"

const CHECK_DOCS: String = "L3REC-001"
const CHECK_CARGO: String = "L3REC-002"
const CHECK_TOLERANCE: String = "L3REC-003"
const CHECK_QUANTITY: String = "L3REC-004"
const CHECK_MASS: String = "L3REC-005"
const CHECK_CONTAINER_TARE: String = "L3REC-006"

const FINDING_QUANTITY_MISMATCH: String = "L3F-001"
const FINDING_MASS_MISMATCH: String = "L3F-002"
const FINDING_NOT_EVALUABLE: String = "L3F-003"

const DECLARATION_DOC_TYPES: Array[String] = [
	"contract",
	"declaration",
	"freight_doc",
	"freight_docs",
	"freightdoc",
	"purchase_order",
]


static func build_level3_reconciliation_report(ctx: Dictionary) -> Dictionary:
	var context: Dictionary = {}
	if ctx is Dictionary:
		context = ctx.duplicate(true)

	var checks: Array = []
	var findings: Array = []
	var not_evaluable: Array = []

	var docs_result: Dictionary = _extract_docs_by_id(context.get("docs", null))
	_append_not_evaluable_entries(not_evaluable, docs_result.get("not_evaluable", []))
	checks.append(_check(
		CHECK_DOCS,
		STATUS_PASS if bool(docs_result.get("ok", false)) else STATUS_NOT_EVALUABLE,
		SEVERITY_NONE,
		"Level-3 docs snapshot available." if bool(docs_result.get("ok", false)) else "Level-3 docs snapshot not evaluable.",
		docs_result.get("details", {})
	))

	var cargo_result: Dictionary = _extract_runtime_cargo(context.get("cargo", null))
	_append_not_evaluable_entries(not_evaluable, cargo_result.get("not_evaluable", []))
	checks.append(_check(
		CHECK_CARGO,
		STATUS_PASS if bool(cargo_result.get("ok", false)) else STATUS_NOT_EVALUABLE,
		SEVERITY_NONE,
		"Level-3 runtime cargo snapshot available." if bool(cargo_result.get("ok", false)) else "Level-3 runtime cargo snapshot not evaluable.",
		cargo_result.get("details", {})
	))

	var tolerance_result: Dictionary = _resolve_tolerance_policy(context)
	if not bool(tolerance_result.get("ok", false)):
		_append_not_evaluable_entries(not_evaluable, [tolerance_result.get("not_evaluable", {})])
	checks.append(_check(
		CHECK_TOLERANCE,
		STATUS_PASS if bool(tolerance_result.get("ok", false)) else STATUS_NOT_EVALUABLE,
		SEVERITY_NONE,
		"Level-3 tolerance policy available." if bool(tolerance_result.get("ok", false)) else "Level-3 tolerance policy not evaluable.",
		tolerance_result.get("details", {})
	))

	var declared_result: Dictionary = _collect_declared_quantities(docs_result.get("docs_by_id", {}))
	_append_not_evaluable_entries(not_evaluable, declared_result.get("not_evaluable", []))

	var declared_qty_by_commodity: Dictionary = declared_result.get("declared_qty_by_commodity", {})
	var runtime_qty_by_commodity: Dictionary = cargo_result.get("runtime_qty_by_commodity", {})
	var policy: Dictionary = tolerance_result.get("policy", {})

	var quantity_result: Dictionary = _compare_quantities(
		declared_qty_by_commodity,
		runtime_qty_by_commodity,
		bool(docs_result.get("ok", false)),
		bool(cargo_result.get("ok", false)),
		bool(declared_result.get("ok", false))
	)
	_append_not_evaluable_entries(not_evaluable, quantity_result.get("not_evaluable", []))
	_append_findings(findings, quantity_result.get("findings", []))
	checks.append(_check(
		CHECK_QUANTITY,
		String(quantity_result.get("status", STATUS_NOT_EVALUABLE)),
		String(quantity_result.get("severity", SEVERITY_NONE)),
		String(quantity_result.get("message", "")),
		quantity_result.get("details", {})
	))

	var mass_result: Dictionary = _compare_masses(
		declared_qty_by_commodity,
		runtime_qty_by_commodity,
		policy,
		bool(tolerance_result.get("ok", false)),
		bool(quantity_result.get("has_comparable_data", false))
	)
	_append_not_evaluable_entries(not_evaluable, mass_result.get("not_evaluable", []))
	_append_findings(findings, mass_result.get("findings", []))
	checks.append(_check(
		CHECK_MASS,
		String(mass_result.get("status", STATUS_NOT_EVALUABLE)),
		String(mass_result.get("severity", SEVERITY_NONE)),
		String(mass_result.get("message", "")),
		mass_result.get("details", {})
	))

	var container_result: Dictionary = _evaluate_container_tare(
		docs_result.get("docs_by_id", {}),
		context,
		bool(docs_result.get("ok", false))
	)
	_append_not_evaluable_entries(not_evaluable, container_result.get("not_evaluable", []))
	checks.append(_check(
		CHECK_CONTAINER_TARE,
		String(container_result.get("status", STATUS_NOT_EVALUABLE)),
		SEVERITY_NONE,
		String(container_result.get("message", "")),
		container_result.get("details", {})
	))

	_sort_checks(checks)
	_sort_findings(findings)
	_sort_not_evaluable(not_evaluable)
	_append_not_evaluable_findings(findings, not_evaluable)
	_sort_findings(findings)

	var status: String = _derive_status(checks)
	var classification: String = _derive_classification(status, findings)
	var summary: String = _build_summary(classification, checks, findings, not_evaluable)

	return {
		"schema_version": SCHEMA_VERSION,
		"level": LEVEL,
		"kind": KIND,
		"classification": classification,
		"status": status,
		"policy_id": String(tolerance_result.get("policy_id", "")),
		"summary": summary,
		"checks": checks,
		"findings": findings,
		"totals": mass_result.get("totals", _empty_totals(declared_qty_by_commodity, runtime_qty_by_commodity)),
		"not_evaluable": not_evaluable,
		"context_echo": _build_context_echo(context),
	}


static func _extract_docs_by_id(docs_variant) -> Dictionary:
	if not (docs_variant is Dictionary):
		return {
			"ok": false,
			"docs_by_id": {},
			"details": _not_evaluable_details("missing_docs_snapshot", ["docs"]),
			"not_evaluable": [_not_evaluable_entry("missing_docs_snapshot", "docs")],
		}

	var source_docs: Dictionary = docs_variant
	var docs_by_id: Dictionary = {}
	var doc_ids: Array = source_docs.keys()
	doc_ids.sort()
	for doc_id_variant in doc_ids:
		var doc_id: String = String(doc_id_variant).strip_edges()
		if doc_id == "":
			continue
		var doc_variant = source_docs[doc_id_variant]
		if not (doc_variant is Dictionary):
			continue
		var doc: Dictionary = (doc_variant as Dictionary).duplicate(true)
		var normalized_doc_id: String = String(doc.get("doc_id", doc_id)).strip_edges()
		if normalized_doc_id == "":
			normalized_doc_id = doc_id
		doc["doc_id"] = normalized_doc_id
		docs_by_id[normalized_doc_id] = doc

	if docs_by_id.is_empty():
		return {
			"ok": false,
			"docs_by_id": {},
			"details": _not_evaluable_details("missing_docs_snapshot", ["docs"]),
			"not_evaluable": [_not_evaluable_entry("missing_docs_snapshot", "docs")],
		}

	return {
		"ok": true,
		"docs_by_id": docs_by_id,
		"details": {"doc_count": docs_by_id.size()},
		"not_evaluable": [],
	}


static func _extract_runtime_cargo(cargo_variant) -> Dictionary:
	if not (cargo_variant is Dictionary):
		return {
			"ok": false,
			"runtime_qty_by_commodity": {},
			"details": _not_evaluable_details("missing_runtime_cargo_snapshot", ["cargo"]),
			"not_evaluable": [_not_evaluable_entry("missing_runtime_cargo_snapshot", "cargo")],
		}

	var source_cargo: Dictionary = cargo_variant
	var runtime_qty_by_commodity: Dictionary = {}
	var not_evaluable: Array = []
	var commodity_ids: Array = source_cargo.keys()
	commodity_ids.sort()
	for commodity_id_variant in commodity_ids:
		var commodity_id: String = String(commodity_id_variant).strip_edges()
		if commodity_id == "":
			continue
		var qty_variant = source_cargo[commodity_id_variant]
		if not (qty_variant is int or qty_variant is float):
			not_evaluable.append(_not_evaluable_entry(
				"malformed_runtime_quantity",
				"cargo.%s" % commodity_id,
				commodity_id
			))
			continue
		var qty: int = int(qty_variant)
		if qty < 0:
			not_evaluable.append(_not_evaluable_entry(
				"malformed_runtime_quantity",
				"cargo.%s" % commodity_id,
				commodity_id,
				"",
				{"quantity": qty}
			))
			continue
		if qty == 0:
			continue
		runtime_qty_by_commodity[commodity_id] = int(runtime_qty_by_commodity.get(commodity_id, 0)) + qty

	return {
		"ok": true,
		"runtime_qty_by_commodity": runtime_qty_by_commodity,
		"details": {
			"commodity_count": runtime_qty_by_commodity.size(),
			"malformed_entry_count": not_evaluable.size(),
		},
		"not_evaluable": not_evaluable,
	}


static func _resolve_tolerance_policy(context: Dictionary) -> Dictionary:
	var requested_policy_id: String = String(context.get("tolerance_policy_id", "")).strip_edges()
	var policy_id: String = requested_policy_id
	if policy_id == "":
		policy_id = CustomsReconciliationDB.DEFAULT_TOLERANCE_POLICY_ID

	var policy: Dictionary = CustomsReconciliationDB.get_tolerance_policy(policy_id)
	if policy.is_empty():
		var reason: String = "missing_tolerance_policy" if requested_policy_id == "" else "malformed_tolerance_policy"
		return {
			"ok": false,
			"policy": {},
			"policy_id": policy_id,
			"details": _not_evaluable_details(reason, ["tolerance_policy_id"]),
			"not_evaluable": _not_evaluable_entry(reason, "tolerance_policy_id", "", "", {"policy_id": policy_id}),
		}

	var absolute_tolerance: float = _get_non_negative_float(policy, "absolute_mass_tolerance", -1.0)
	var relative_tolerance: float = _get_non_negative_float(policy, "relative_mass_tolerance", -1.0)
	var rounding_decimals: int = _get_non_negative_int(policy, "rounding_decimals", -1)
	if absolute_tolerance < 0.0 or relative_tolerance < 0.0 or rounding_decimals < 0:
		return {
			"ok": false,
			"policy": {},
			"policy_id": policy_id,
			"details": _not_evaluable_details("malformed_tolerance_policy", ["tolerance_policy"]),
			"not_evaluable": _not_evaluable_entry("malformed_tolerance_policy", "tolerance_policy", "", "", {"policy_id": policy_id}),
		}

	return {
		"ok": true,
		"policy": policy,
		"policy_id": String(policy.get("policy_id", policy_id)),
		"details": {
			"policy_id": String(policy.get("policy_id", policy_id)),
			"absolute_mass_tolerance": absolute_tolerance,
			"relative_mass_tolerance": relative_tolerance,
			"rounding_decimals": rounding_decimals,
		},
	}


static func _collect_declared_quantities(docs_by_id: Dictionary) -> Dictionary:
	var declared_qty_by_commodity: Dictionary = {}
	var not_evaluable: Array = []
	var declaration_doc_count: int = 0
	var usable_line_count: int = 0

	var doc_ids: Array = docs_by_id.keys()
	doc_ids.sort()
	for doc_id_variant in doc_ids:
		var doc_id: String = String(doc_id_variant)
		var doc_variant = docs_by_id[doc_id]
		if not (doc_variant is Dictionary):
			continue
		var doc: Dictionary = doc_variant
		var doc_type: String = String(doc.get("doc_type", "")).strip_edges().to_lower()
		if not DECLARATION_DOC_TYPES.has(doc_type):
			continue
		declaration_doc_count += 1

		var cargo_lines_variant = doc.get("cargo_lines", null)
		if cargo_lines_variant is Array:
			var cargo_lines: Array = cargo_lines_variant
			if cargo_lines.is_empty():
				not_evaluable.append(_not_evaluable_entry(
					"missing_declaration_quantities",
					"docs.%s.cargo_lines" % doc_id,
					"",
					doc_id
				))
				continue
			for line_index in range(cargo_lines.size()):
				var line_variant = cargo_lines[line_index]
				if not (line_variant is Dictionary):
					not_evaluable.append(_not_evaluable_entry(
						"malformed_declaration_line",
						"docs.%s.cargo_lines[%d]" % [doc_id, line_index],
						"",
						doc_id
					))
					continue
				var line: Dictionary = line_variant
				var commodity_id: String = String(line.get("commodity_id", "")).strip_edges()
				var path: String = "docs.%s.cargo_lines[%d]" % [doc_id, line_index]
				if commodity_id == "":
					not_evaluable.append(_not_evaluable_entry("unknown_commodity_id", path, "", doc_id))
					continue
				var qty_variant = line.get("declared_qty", line.get("quantity", null))
				if not (qty_variant is int or qty_variant is float):
					not_evaluable.append(_not_evaluable_entry("missing_declaration_quantities", path, commodity_id, doc_id))
					continue
				var qty: int = int(qty_variant)
				if qty <= 0:
					not_evaluable.append(_not_evaluable_entry(
						"missing_declaration_quantities",
						path,
						commodity_id,
						doc_id,
						{"quantity": qty}
					))
					continue
				declared_qty_by_commodity[commodity_id] = int(declared_qty_by_commodity.get(commodity_id, 0)) + qty
				usable_line_count += 1
			continue

		var commodity_id: String = String(doc.get("commodity_id", "")).strip_edges()
		var qty_variant = doc.get("quantity", null)
		if commodity_id == "" or not (qty_variant is int or qty_variant is float) or int(qty_variant) <= 0:
			not_evaluable.append(_not_evaluable_entry(
				"missing_declaration_quantities",
				"docs.%s" % doc_id,
				commodity_id,
				doc_id
			))
			continue
		declared_qty_by_commodity[commodity_id] = int(declared_qty_by_commodity.get(commodity_id, 0)) + int(qty_variant)
		usable_line_count += 1

	if declaration_doc_count <= 0:
		not_evaluable.append(_not_evaluable_entry("missing_declaration_docs", "docs"))
		return {
			"ok": false,
			"declared_qty_by_commodity": declared_qty_by_commodity,
			"not_evaluable": not_evaluable,
		}

	if declared_qty_by_commodity.is_empty():
		not_evaluable.append(_not_evaluable_entry("missing_declaration_quantities", "docs"))
		return {
			"ok": false,
			"declared_qty_by_commodity": declared_qty_by_commodity,
			"not_evaluable": not_evaluable,
		}

	return {
		"ok": true,
		"declared_qty_by_commodity": declared_qty_by_commodity,
		"not_evaluable": not_evaluable,
		"details": {
			"declaration_doc_count": declaration_doc_count,
			"usable_line_count": usable_line_count,
		},
	}


static func _compare_quantities(
	declared_qty_by_commodity: Dictionary,
	runtime_qty_by_commodity: Dictionary,
	has_docs: bool,
	has_cargo: bool,
	has_declared_quantities: bool
) -> Dictionary:
	var not_evaluable: Array = []
	if not has_docs:
		not_evaluable.append(_not_evaluable_entry("missing_docs_snapshot", "docs"))
	if not has_cargo:
		not_evaluable.append(_not_evaluable_entry("missing_runtime_cargo_snapshot", "cargo"))
	if has_docs and not has_declared_quantities:
		not_evaluable.append(_not_evaluable_entry("missing_declaration_quantities", "docs"))
	if not not_evaluable.is_empty():
		return {
			"status": STATUS_NOT_EVALUABLE,
			"severity": SEVERITY_NONE,
			"message": "Level-3 quantity reconciliation not evaluable.",
			"details": _not_evaluable_details("missing_quantity_comparison_inputs"),
			"findings": [],
			"not_evaluable": not_evaluable,
			"has_comparable_data": false,
		}

	var findings: Array = []
	var commodity_ids: Array = _sorted_union_keys(declared_qty_by_commodity, runtime_qty_by_commodity)
	for commodity_id_variant in commodity_ids:
		var commodity_id: String = String(commodity_id_variant)
		var declared_qty: int = int(declared_qty_by_commodity.get(commodity_id, 0))
		var runtime_qty: int = int(runtime_qty_by_commodity.get(commodity_id, 0))
		if declared_qty == runtime_qty:
			continue
		findings.append(_finding(
			FINDING_QUANTITY_MISMATCH,
			STATUS_FAIL,
			SEVERITY_SUSPICIOUS,
			"quantity_mismatch",
			"Declared quantity does not match runtime cargo quantity.",
			{
				"commodity_id": commodity_id,
				"declared_qty": declared_qty,
				"runtime_qty": runtime_qty,
				"delta_qty": runtime_qty - declared_qty,
			}
		))

	if findings.is_empty():
		return {
			"status": STATUS_PASS,
			"severity": SEVERITY_NONE,
			"message": "Level-3 quantity totals match.",
			"details": {"commodity_count": commodity_ids.size()},
			"findings": [],
			"not_evaluable": [],
			"has_comparable_data": true,
		}

	return {
		"status": STATUS_FAIL,
		"severity": SEVERITY_SUSPICIOUS,
		"message": "Level-3 quantity mismatch detected.",
		"details": {
			"commodity_count": commodity_ids.size(),
			"mismatch_count": findings.size(),
		},
		"findings": findings,
		"not_evaluable": [],
		"has_comparable_data": true,
	}


static func _compare_masses(
	declared_qty_by_commodity: Dictionary,
	runtime_qty_by_commodity: Dictionary,
	policy: Dictionary,
	has_policy: bool,
	has_comparable_quantity_data: bool
) -> Dictionary:
	var empty_totals: Dictionary = _empty_totals(declared_qty_by_commodity, runtime_qty_by_commodity)
	if not has_policy:
		return {
			"status": STATUS_NOT_EVALUABLE,
			"severity": SEVERITY_NONE,
			"message": "Level-3 mass reconciliation not evaluable.",
			"details": _not_evaluable_details("missing_tolerance_policy", ["tolerance_policy"]),
			"findings": [],
			"not_evaluable": [_not_evaluable_entry("missing_tolerance_policy", "tolerance_policy")],
			"totals": empty_totals,
		}
	if not has_comparable_quantity_data:
		return {
			"status": STATUS_NOT_EVALUABLE,
			"severity": SEVERITY_NONE,
			"message": "Level-3 mass reconciliation not evaluable.",
			"details": _not_evaluable_details("missing_quantity_comparison_inputs"),
			"findings": [],
			"not_evaluable": [_not_evaluable_entry("missing_quantity_comparison_inputs", "docs|cargo")],
			"totals": empty_totals,
		}

	var declared_mass_by_commodity: Dictionary = {}
	var runtime_mass_by_commodity: Dictionary = {}
	var not_evaluable: Array = []
	var findings: Array = []

	var declared_mass_total: float = 0.0
	var runtime_mass_total: float = 0.0
	var commodity_ids: Array = _sorted_union_keys(declared_qty_by_commodity, runtime_qty_by_commodity)
	for commodity_id_variant in commodity_ids:
		var commodity_id: String = String(commodity_id_variant)
		var mass_per_unit: float = CommodityDB.get_customs_mass_per_unit(commodity_id, -1.0)
		if mass_per_unit < 0.0:
			not_evaluable.append(_not_evaluable_entry("unknown_commodity_mass", "commodity.%s.customs_mass_per_unit" % commodity_id, commodity_id))
			continue
		var declared_mass: float = float(int(declared_qty_by_commodity.get(commodity_id, 0))) * mass_per_unit
		var runtime_mass: float = float(int(runtime_qty_by_commodity.get(commodity_id, 0))) * mass_per_unit
		declared_mass_by_commodity[commodity_id] = declared_mass
		runtime_mass_by_commodity[commodity_id] = runtime_mass
		declared_mass_total += declared_mass
		runtime_mass_total += runtime_mass

	var absolute_tolerance: float = _get_non_negative_float(policy, "absolute_mass_tolerance", 0.0)
	var relative_tolerance: float = _get_non_negative_float(policy, "relative_mass_tolerance", 0.0)
	var rounding_decimals: int = _get_non_negative_int(policy, "rounding_decimals", 2)
	var delta_mass_total: float = runtime_mass_total - declared_mass_total
	var allowed_delta_mass: float = max(absolute_tolerance, declared_mass_total * relative_tolerance)
	var rounded_declared_total: float = _round_to_decimals(declared_mass_total, rounding_decimals)
	var rounded_runtime_total: float = _round_to_decimals(runtime_mass_total, rounding_decimals)
	var rounded_delta_total: float = _round_to_decimals(delta_mass_total, rounding_decimals)
	var rounded_allowed_delta: float = _round_to_decimals(allowed_delta_mass, rounding_decimals)

	var totals := {
		"declared_qty_by_commodity": declared_qty_by_commodity.duplicate(true),
		"runtime_qty_by_commodity": runtime_qty_by_commodity.duplicate(true),
		"declared_mass_by_commodity": declared_mass_by_commodity,
		"runtime_mass_by_commodity": runtime_mass_by_commodity,
		"declared_mass_total": rounded_declared_total,
		"runtime_mass_total": rounded_runtime_total,
		"delta_mass_total": rounded_delta_total,
		"allowed_delta_mass": rounded_allowed_delta,
	}

	if not not_evaluable.is_empty():
		return {
			"status": STATUS_NOT_EVALUABLE,
			"severity": SEVERITY_NONE,
			"message": "Level-3 mass reconciliation not evaluable for all commodities.",
			"details": {
				"reason": "unknown_commodity_mass",
				"not_evaluable_count": not_evaluable.size(),
			},
			"findings": [],
			"not_evaluable": not_evaluable,
			"totals": totals,
		}

	if abs(delta_mass_total) <= allowed_delta_mass:
		return {
			"status": STATUS_PASS,
			"severity": SEVERITY_NONE,
			"message": "Level-3 mass totals are within tolerance.",
			"details": {
				"delta_mass_total": rounded_delta_total,
				"allowed_delta_mass": rounded_allowed_delta,
				"rounding_decimals": rounding_decimals,
			},
			"findings": [],
			"not_evaluable": [],
			"totals": totals,
		}

	findings.append(_finding(
		FINDING_MASS_MISMATCH,
		STATUS_FAIL,
		SEVERITY_SUSPICIOUS,
		"mass_delta_exceeds_tolerance",
		"Declared mass does not match runtime cargo mass within tolerance.",
		{
			"declared_mass_total": rounded_declared_total,
			"runtime_mass_total": rounded_runtime_total,
			"delta_mass_total": rounded_delta_total,
			"allowed_delta_mass": rounded_allowed_delta,
			"rounding_decimals": rounding_decimals,
		}
	))

	return {
		"status": STATUS_FAIL,
		"severity": SEVERITY_SUSPICIOUS,
		"message": "Level-3 mass mismatch detected.",
		"details": {
			"delta_mass_total": rounded_delta_total,
			"allowed_delta_mass": rounded_allowed_delta,
			"rounding_decimals": rounding_decimals,
		},
		"findings": findings,
		"not_evaluable": [],
		"totals": totals,
	}


static func _evaluate_container_tare(docs_by_id: Dictionary, context: Dictionary, has_docs: bool) -> Dictionary:
	if not has_docs:
		return {
			"status": STATUS_NOT_EVALUABLE,
			"message": "Level-3 container tare reconciliation not evaluable.",
			"details": _not_evaluable_details("missing_docs_snapshot", ["docs"]),
			"not_evaluable": [_not_evaluable_entry("missing_docs_snapshot", "docs")],
		}

	var not_evaluable: Array = []
	var checked_count: int = 0
	var class_by_doc_id: Dictionary = {}
	var class_by_doc_variant = context.get("container_class_by_doc_id", {})
	if class_by_doc_variant is Dictionary:
		class_by_doc_id = (class_by_doc_variant as Dictionary).duplicate(true)

	var doc_ids: Array = docs_by_id.keys()
	doc_ids.sort()
	for doc_id_variant in doc_ids:
		var doc_id: String = String(doc_id_variant)
		var doc_variant = docs_by_id[doc_id]
		if not (doc_variant is Dictionary):
			continue
		var doc: Dictionary = doc_variant
		var doc_type: String = String(doc.get("doc_type", "")).strip_edges().to_lower()
		if not DECLARATION_DOC_TYPES.has(doc_type):
			continue

		var container_meta_variant = doc.get("container_meta", null)
		if not (container_meta_variant is Dictionary):
			not_evaluable.append(_not_evaluable_entry("missing_container_meta", "docs.%s.container_meta" % doc_id, "", doc_id))
			continue
		var container_meta: Dictionary = container_meta_variant
		var container_id: String = String(container_meta.get("container_id", "")).strip_edges()
		if container_id == "":
			not_evaluable.append(_not_evaluable_entry("missing_container_meta", "docs.%s.container_meta.container_id" % doc_id, "", doc_id))
			continue

		var class_id: String = String(container_meta.get("container_class_id", "")).strip_edges()
		if class_id == "" and class_by_doc_id.has(doc_id):
			class_id = String(class_by_doc_id.get(doc_id, "")).strip_edges()
		if class_id == "":
			not_evaluable.append(_not_evaluable_entry("missing_container_class_id", "docs.%s.container_meta.container_class_id" % doc_id, "", doc_id))
			continue

		var tare_mass: float = CustomsReconciliationDB.get_container_tare_mass(class_id, -1.0)
		if tare_mass < 0.0:
			not_evaluable.append(_not_evaluable_entry("unknown_container_class", "container_class.%s" % class_id, "", doc_id, {"container_class_id": class_id}))
			continue
		checked_count += 1

	if checked_count > 0 and not_evaluable.is_empty():
		return {
			"status": STATUS_PASS,
			"message": "Level-3 container tare primitives are available.",
			"details": {"checked_container_count": checked_count},
			"not_evaluable": [],
		}

	return {
		"status": STATUS_NOT_EVALUABLE,
		"message": "Level-3 container tare reconciliation not evaluable.",
		"details": {
			"reason": "container_tare_not_supported_without_container_class",
			"checked_container_count": checked_count,
			"not_evaluable_count": not_evaluable.size(),
		},
		"not_evaluable": not_evaluable,
	}


static func _check(check_id: String, status: String, severity: String, message: String, details: Dictionary = {}) -> Dictionary:
	return {
		"check_id": check_id,
		"status": _normalize_status(status),
		"severity": _normalize_severity(severity),
		"message": message,
		"details": details.duplicate(true),
	}


static func _finding(
	code: String,
	status: String,
	severity: String,
	reason: String,
	message: String,
	details: Dictionary = {}
) -> Dictionary:
	return {
		"code": code,
		"status": _normalize_status(status),
		"severity": _normalize_severity(severity),
		"reason": reason,
		"message": message,
		"details": details.duplicate(true),
	}


static func _not_evaluable_entry(
	reason: String,
	path: String,
	commodity_id: String = "",
	doc_id: String = "",
	extra_details: Dictionary = {}
) -> Dictionary:
	var entry := {
		"reason": reason,
		"path": path,
	}
	if commodity_id != "":
		entry["commodity_id"] = commodity_id
	if doc_id != "":
		entry["doc_id"] = doc_id
	for key_variant in extra_details.keys():
		var key: String = String(key_variant)
		if key == "":
			continue
		entry[key] = extra_details[key_variant]
	return entry


static func _append_not_evaluable_entries(target: Array, entries_variant) -> void:
	if not (entries_variant is Array):
		return
	var entries: Array = entries_variant
	for entry_variant in entries:
		if entry_variant is Dictionary:
			target.append((entry_variant as Dictionary).duplicate(true))


static func _append_findings(target: Array, findings_variant) -> void:
	if not (findings_variant is Array):
		return
	var source_findings: Array = findings_variant
	for finding_variant in source_findings:
		if finding_variant is Dictionary:
			target.append((finding_variant as Dictionary).duplicate(true))


static func _append_not_evaluable_findings(findings: Array, not_evaluable: Array) -> void:
	if not_evaluable.is_empty():
		return
	findings.append(_finding(
		FINDING_NOT_EVALUABLE,
		STATUS_NOT_EVALUABLE,
		SEVERITY_NONE,
		"not_evaluable_inputs",
		"One or more Level-3 reconciliation inputs were not evaluable.",
		{"not_evaluable_count": not_evaluable.size()}
	))


static func _not_evaluable_details(reason: String, missing_inputs: Array = []) -> Dictionary:
	var normalized_missing: Array = []
	for input_variant in missing_inputs:
		var input_name: String = String(input_variant).strip_edges()
		if input_name != "":
			normalized_missing.append(input_name)
	normalized_missing.sort()
	var details := {"reason": reason}
	if not normalized_missing.is_empty():
		details["missing_inputs"] = normalized_missing
	return details


static func _empty_totals(declared_qty_by_commodity: Dictionary = {}, runtime_qty_by_commodity: Dictionary = {}) -> Dictionary:
	return {
		"declared_qty_by_commodity": declared_qty_by_commodity.duplicate(true),
		"runtime_qty_by_commodity": runtime_qty_by_commodity.duplicate(true),
		"declared_mass_by_commodity": {},
		"runtime_mass_by_commodity": {},
		"declared_mass_total": 0.0,
		"runtime_mass_total": 0.0,
		"delta_mass_total": 0.0,
		"allowed_delta_mass": 0.0,
	}


static func _build_context_echo(context: Dictionary) -> Dictionary:
	return {
		"action": String(context.get("action", "")),
		"system_id": String(context.get("system_id", "")),
		"location_id": String(context.get("location_id", "")),
		"tick": int(context.get("tick", 0)),
	}


static func _derive_status(checks: Array) -> String:
	var has_fail: bool = false
	var has_pass: bool = false
	var has_not_evaluable: bool = false
	for check_variant in checks:
		if not (check_variant is Dictionary):
			continue
		var status: String = String((check_variant as Dictionary).get("status", STATUS_NOT_EVALUABLE))
		if status == STATUS_FAIL:
			has_fail = true
		elif status == STATUS_PASS:
			has_pass = true
		elif status == STATUS_NOT_EVALUABLE:
			has_not_evaluable = true
	if has_fail:
		return STATUS_FAIL
	if has_pass and not has_not_evaluable:
		return STATUS_PASS
	if has_pass:
		return STATUS_PASS
	return STATUS_NOT_EVALUABLE


static func _derive_classification(status: String, findings: Array) -> String:
	for finding_variant in findings:
		if not (finding_variant is Dictionary):
			continue
		var finding: Dictionary = finding_variant
		if String(finding.get("severity", "")) == SEVERITY_SUSPICIOUS:
			return CLASSIFICATION_SUSPICIOUS
	if status == STATUS_NOT_EVALUABLE:
		return CLASSIFICATION_NOT_EVALUABLE
	return CLASSIFICATION_CLEAN


static func _build_summary(classification: String, checks: Array, findings: Array, not_evaluable: Array) -> String:
	if classification == CLASSIFICATION_SUSPICIOUS:
		return "Level-3 reconciliation found %d report-only finding(s)." % findings.size()
	if classification == CLASSIFICATION_NOT_EVALUABLE:
		return "Level-3 reconciliation not evaluable: %d input issue(s)." % not_evaluable.size()
	return "Level-3 reconciliation clean across %d check(s)." % checks.size()


static func _normalize_status(status: String) -> String:
	match status:
		STATUS_PASS, STATUS_FAIL, STATUS_NOT_EVALUABLE:
			return status
		_:
			return STATUS_NOT_EVALUABLE


static func _normalize_severity(severity: String) -> String:
	match severity:
		SEVERITY_NONE, SEVERITY_SUSPICIOUS:
			return severity
		_:
			return SEVERITY_NONE


static func _sorted_union_keys(left: Dictionary, right: Dictionary) -> Array:
	var seen: Dictionary = {}
	for key_variant in left.keys():
		var key: String = String(key_variant).strip_edges()
		if key != "":
			seen[key] = true
	for key_variant in right.keys():
		var key: String = String(key_variant).strip_edges()
		if key != "":
			seen[key] = true
	var keys: Array = seen.keys()
	keys.sort()
	return keys


static func _get_non_negative_float(record: Dictionary, field_name: String, fallback: float) -> float:
	var value_variant = record.get(field_name, null)
	if not (value_variant is int or value_variant is float):
		return fallback
	var value: float = float(value_variant)
	if value < 0.0:
		return fallback
	return value


static func _get_non_negative_int(record: Dictionary, field_name: String, fallback: int) -> int:
	var value_variant = record.get(field_name, null)
	if not (value_variant is int or value_variant is float):
		return fallback
	var value: int = int(value_variant)
	if value < 0:
		return fallback
	return value


static func _round_to_decimals(value: float, decimals: int) -> float:
	var multiplier: float = pow(10.0, float(max(decimals, 0)))
	return round(value * multiplier) / multiplier


static func _sort_checks(checks: Array) -> void:
	for i in range(checks.size()):
		for j in range(i + 1, checks.size()):
			var left: Dictionary = checks[i]
			var right: Dictionary = checks[j]
			if String(right.get("check_id", "")) < String(left.get("check_id", "")):
				checks[i] = right
				checks[j] = left


static func _sort_findings(findings: Array) -> void:
	for i in range(findings.size()):
		for j in range(i + 1, findings.size()):
			var left: Dictionary = findings[i]
			var right: Dictionary = findings[j]
			if _finding_sort_key(right) < _finding_sort_key(left):
				findings[i] = right
				findings[j] = left


static func _sort_not_evaluable(entries: Array) -> void:
	for i in range(entries.size()):
		for j in range(i + 1, entries.size()):
			var left: Dictionary = entries[i]
			var right: Dictionary = entries[j]
			if _not_evaluable_sort_key(right) < _not_evaluable_sort_key(left):
				entries[i] = right
				entries[j] = left


static func _finding_sort_key(finding: Dictionary) -> String:
	var details: Dictionary = {}
	var details_variant = finding.get("details", {})
	if details_variant is Dictionary:
		details = details_variant
	return "%s|%s|%s|%s|%s" % [
		_severity_sort_prefix(String(finding.get("severity", ""))),
		String(finding.get("code", "")),
		String(details.get("commodity_id", "")),
		String(details.get("doc_id", "")),
		String(finding.get("reason", "")),
	]


static func _not_evaluable_sort_key(entry: Dictionary) -> String:
	return "%s|%s|%s|%s" % [
		String(entry.get("reason", "")),
		String(entry.get("commodity_id", "")),
		String(entry.get("doc_id", "")),
		String(entry.get("path", "")),
	]


static func _severity_sort_prefix(severity: String) -> String:
	if severity == SEVERITY_SUSPICIOUS:
		return "0"
	return "1"
