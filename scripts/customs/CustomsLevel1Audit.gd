extends RefCounted
class_name CustomsLevel1Audit

const STATUS_PASS: String = "pass"
const STATUS_FAIL: String = "fail"
const STATUS_NOT_EVALUABLE: String = "not_evaluable"

const SEVERITY_INVALID: String = "invalid"
const SEVERITY_SUSPICIOUS: String = "suspicious"
const SEVERITY_NONE: String = "none"

const CHECK_DOCS_AVAILABLE: String = "L1CHK-001"
const CHECK_DECLARATION_DOCS: String = "L1CHK-002"
const CHECK_DECLARATION_FIELDS: String = "L1CHK-003"
const CHECK_BILL_OF_SALE_FIELDS: String = "L1CHK-004"
const CHECK_CONTAINER_META: String = "L1CHK-005"
const CHECK_CARGO_SNAPSHOT: String = "L1CHK-006"

const FINDING_MISSING_DOCS: String = "L1F-001"
const FINDING_MISSING_DECLARATION_DOCS: String = "L1F-002"
const FINDING_DECLARATION_FIELD_ISSUE: String = "L1F-003"
const FINDING_BILL_OF_SALE_FIELD_ISSUE: String = "L1F-004"
const FINDING_CONTAINER_META_ISSUE: String = "L1F-005"
const FINDING_MISSING_CARGO_SNAPSHOT: String = "L1F-006"


static func build_level1_audit(ctx: Dictionary) -> Dictionary:
	var context: Dictionary = {}
	if ctx is Dictionary:
		context = (ctx as Dictionary).duplicate(true)

	var checks: Array = []
	var findings: Array = []
	var docs_by_id: Dictionary = _extract_docs_by_id(context.get("docs", {}))
	var cargo_snapshot: Dictionary = _extract_cargo_snapshot(context.get("cargo", null))

	if docs_by_id.is_empty():
		checks.append(_check(
			CHECK_DOCS_AVAILABLE,
			STATUS_NOT_EVALUABLE,
			SEVERITY_NONE,
			"Level-1 docs snapshot unavailable.",
			{"reason": "missing_docs_snapshot"}
		))
		findings.append(_finding(
			FINDING_MISSING_DOCS,
			SEVERITY_INVALID,
			"missing_docs_snapshot",
			"Level-1 audit cannot validate paperwork: docs snapshot missing."
		))
	else:
		checks.append(_check(
			CHECK_DOCS_AVAILABLE,
			STATUS_PASS,
			SEVERITY_NONE,
			"Level-1 docs snapshot available.",
			{"doc_count": docs_by_id.size()}
		))

	var declaration_docs: Array = _collect_docs_by_kind(docs_by_id, ["declaration", "purchase_order", "contract", "freightdoc", "freight_doc", "freight_docs"])
	if declaration_docs.is_empty():
		if docs_by_id.is_empty():
			checks.append(_check(
				CHECK_DECLARATION_DOCS,
				STATUS_NOT_EVALUABLE,
				SEVERITY_NONE,
				"Declaration-doc presence not evaluable: docs snapshot unavailable.",
				{"reason": "missing_docs_snapshot"}
			))
		else:
			checks.append(_check(
				CHECK_DECLARATION_DOCS,
				STATUS_FAIL,
				SEVERITY_INVALID,
				"No declaration-like documents found for Level-1 checks.",
				{"reason": "missing_declaration_docs"}
			))
			findings.append(_finding(
				FINDING_MISSING_DECLARATION_DOCS,
				SEVERITY_INVALID,
				"missing_declaration_docs",
				"Required declaration-like document is missing."
			))
	else:
		checks.append(_check(
			CHECK_DECLARATION_DOCS,
			STATUS_PASS,
			SEVERITY_NONE,
			"Declaration-like documents available.",
			{"doc_count": declaration_docs.size()}
		))

	var declaration_field_issues: Array = _collect_declaration_field_issues(declaration_docs)
	if declaration_field_issues.is_empty():
		checks.append(_check(
			CHECK_DECLARATION_FIELDS,
			STATUS_PASS,
			SEVERITY_NONE,
			"Declaration-like required fields are present."
		))
	else:
		checks.append(_check(
			CHECK_DECLARATION_FIELDS,
			STATUS_FAIL,
			SEVERITY_INVALID,
			"Declaration-like required-field issues detected.",
			{"issue_count": declaration_field_issues.size()}
		))
		for issue_variant in declaration_field_issues:
			if not (issue_variant is Dictionary):
				continue
			var issue: Dictionary = issue_variant
			findings.append(_finding(
				FINDING_DECLARATION_FIELD_ISSUE,
				SEVERITY_INVALID,
				String(issue.get("code", "missing_required_field")),
				String(issue.get("message", "Declaration-like required field missing.")),
				issue
			))

	var bill_docs: Array = _collect_docs_by_kind(docs_by_id, ["bill_of_sale"])
	var bill_of_sale_field_issues: Array = _collect_bill_of_sale_field_issues(bill_docs)
	if bill_docs.is_empty():
		checks.append(_check(
			CHECK_BILL_OF_SALE_FIELDS,
			STATUS_NOT_EVALUABLE,
			SEVERITY_NONE,
			"Bill-of-sale checks not evaluable: no bill-of-sale docs present.",
			{"reason": "missing_bill_of_sale_docs"}
		))
	elif bill_of_sale_field_issues.is_empty():
		checks.append(_check(
			CHECK_BILL_OF_SALE_FIELDS,
			STATUS_PASS,
			SEVERITY_NONE,
			"Bill-of-sale required fields are present."
		))
	else:
		checks.append(_check(
			CHECK_BILL_OF_SALE_FIELDS,
			STATUS_FAIL,
			SEVERITY_SUSPICIOUS,
			"Bill-of-sale required-field issues detected.",
			{"issue_count": bill_of_sale_field_issues.size()}
		))
		for issue_variant in bill_of_sale_field_issues:
			if not (issue_variant is Dictionary):
				continue
			var issue: Dictionary = issue_variant
			findings.append(_finding(
				FINDING_BILL_OF_SALE_FIELD_ISSUE,
				SEVERITY_SUSPICIOUS,
				String(issue.get("code", "missing_required_field")),
				String(issue.get("message", "Bill-of-sale required field missing.")),
				issue
			))

	var container_meta_issues: Array = _collect_container_meta_issues(docs_by_id)
	if container_meta_issues.is_empty():
		checks.append(_check(
			CHECK_CONTAINER_META,
			STATUS_PASS,
			SEVERITY_NONE,
			"Container metadata fields are coherent where present."
		))
	else:
		checks.append(_check(
			CHECK_CONTAINER_META,
			STATUS_FAIL,
			SEVERITY_SUSPICIOUS,
			"Container metadata field issues detected.",
			{"issue_count": container_meta_issues.size()}
		))
		for issue_variant in container_meta_issues:
			if not (issue_variant is Dictionary):
				continue
			var issue: Dictionary = issue_variant
			findings.append(_finding(
				FINDING_CONTAINER_META_ISSUE,
				SEVERITY_SUSPICIOUS,
				String(issue.get("code", "container_meta_issue")),
				String(issue.get("message", "Container metadata issue.")),
				issue
			))

	if cargo_snapshot.is_empty():
		checks.append(_check(
			CHECK_CARGO_SNAPSHOT,
			STATUS_NOT_EVALUABLE,
			SEVERITY_NONE,
			"Cargo snapshot unavailable for Level-1 context.",
			{"reason": "missing_cargo_snapshot"}
		))
		findings.append(_finding(
			FINDING_MISSING_CARGO_SNAPSHOT,
			SEVERITY_SUSPICIOUS,
			"missing_cargo_snapshot",
			"Cargo snapshot missing; Level-1 surface cross-check context is incomplete."
		))
	else:
		checks.append(_check(
			CHECK_CARGO_SNAPSHOT,
			STATUS_PASS,
			SEVERITY_NONE,
			"Cargo snapshot available.",
			{"commodity_count": cargo_snapshot.size()}
		))

	_sort_checks_in_place(checks)
	_sort_findings_in_place(findings)

	return {
		"classification": _derive_classification(findings),
		"checks": checks,
		"findings": findings,
	}


static func _extract_docs_by_id(docs_variant) -> Dictionary:
	var docs_by_id: Dictionary = {}
	if not (docs_variant is Dictionary):
		return docs_by_id
	var source_docs: Dictionary = docs_variant
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
		if String(doc.get("doc_id", "")).strip_edges() == "":
			doc["doc_id"] = doc_id
		docs_by_id[String(doc.get("doc_id", doc_id))] = doc
	return docs_by_id


static func _extract_cargo_snapshot(cargo_variant) -> Dictionary:
	var cargo_snapshot: Dictionary = {}
	if not (cargo_variant is Dictionary):
		return cargo_snapshot
	var source_cargo: Dictionary = cargo_variant
	var commodity_ids: Array = source_cargo.keys()
	commodity_ids.sort()
	for commodity_id_variant in commodity_ids:
		var commodity_id: String = String(commodity_id_variant).strip_edges()
		if commodity_id == "":
			continue
		cargo_snapshot[commodity_id] = max(0, int(source_cargo[commodity_id_variant]))
	return cargo_snapshot


static func _collect_docs_by_kind(docs_by_id: Dictionary, kinds: Array) -> Array:
	var normalized_kinds: Dictionary = {}
	for kind_variant in kinds:
		var kind: String = String(kind_variant).strip_edges().to_lower()
		if kind != "":
			normalized_kinds[kind] = true

	var docs: Array = []
	var doc_ids: Array = docs_by_id.keys()
	doc_ids.sort()
	for doc_id_variant in doc_ids:
		var doc_id: String = String(doc_id_variant)
		var doc_variant = docs_by_id.get(doc_id_variant, {})
		if not (doc_variant is Dictionary):
			continue
		var doc: Dictionary = doc_variant
		var doc_type: String = String(doc.get("doc_type", "")).strip_edges().to_lower()
		var is_declaration_like: bool = normalized_kinds.has(doc_type)
		if not is_declaration_like and normalized_kinds.has("contract") and doc_id.begins_with("FDOC-"):
			is_declaration_like = true
		if not is_declaration_like:
			continue
		docs.append({
			"doc_id": doc_id,
			"doc": doc,
		})
	return docs


static func _collect_declaration_field_issues(declaration_docs: Array) -> Array:
	var issues: Array = []
	for entry_variant in declaration_docs:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		var doc_id: String = String(entry.get("doc_id", "")).strip_edges()
		var doc_variant = entry.get("doc", {})
		if not (doc_variant is Dictionary):
			continue
		var doc: Dictionary = doc_variant
		if doc_id == "":
			issues.append(_issue("missing_doc_id", "Declaration-like doc has blank doc_id.", {"doc_id": doc_id}))
		var cargo_lines_variant = doc.get("cargo_lines", null)
		if not (cargo_lines_variant is Array):
			issues.append(_issue("missing_cargo_lines", "Declaration-like doc is missing cargo_lines array.", {"doc_id": doc_id}))
			continue
		var cargo_lines: Array = cargo_lines_variant
		if cargo_lines.is_empty():
			issues.append(_issue("empty_cargo_lines", "Declaration-like doc has empty cargo_lines.", {"doc_id": doc_id}))
			continue
		for i in range(cargo_lines.size()):
			var line_variant = cargo_lines[i]
			if not (line_variant is Dictionary):
				issues.append(_issue(
					"malformed_cargo_line",
					"Declaration-like doc has malformed cargo line.",
					{"doc_id": doc_id, "line_index": i}
				))
				continue
			var line: Dictionary = line_variant
			var commodity_id: String = String(line.get("commodity_id", "")).strip_edges()
			if commodity_id == "":
				issues.append(_issue(
					"missing_commodity_id",
					"Declaration-like cargo line missing commodity_id.",
					{"doc_id": doc_id, "line_index": i}
				))
			var qty: int = int(line.get("declared_qty", line.get("quantity", 0)))
			if qty <= 0:
				issues.append(_issue(
					"invalid_quantity",
					"Declaration-like cargo line has non-positive quantity.",
					{"doc_id": doc_id, "line_index": i, "quantity": qty}
				))
	return issues


static func _collect_bill_of_sale_field_issues(bill_docs: Array) -> Array:
	var issues: Array = []
	for entry_variant in bill_docs:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		var doc_id: String = String(entry.get("doc_id", "")).strip_edges()
		var doc_variant = entry.get("doc", {})
		if not (doc_variant is Dictionary):
			continue
		var doc: Dictionary = doc_variant
		if doc_id == "":
			issues.append(_issue("missing_doc_id", "Bill-of-sale doc has blank doc_id.", {"doc_id": doc_id}))
		var cargo_lines_variant = doc.get("cargo_lines", null)
		if not (cargo_lines_variant is Array):
			issues.append(_issue("missing_cargo_lines", "Bill-of-sale doc is missing cargo_lines array.", {"doc_id": doc_id}))
			continue
		var cargo_lines: Array = cargo_lines_variant
		if cargo_lines.is_empty():
			issues.append(_issue("empty_cargo_lines", "Bill-of-sale doc has empty cargo_lines.", {"doc_id": doc_id}))
			continue
		for i in range(cargo_lines.size()):
			var line_variant = cargo_lines[i]
			if not (line_variant is Dictionary):
				issues.append(_issue(
					"malformed_cargo_line",
					"Bill-of-sale doc has malformed cargo line.",
					{"doc_id": doc_id, "line_index": i}
				))
				continue
			var line: Dictionary = line_variant
			var commodity_id: String = String(line.get("commodity_id", "")).strip_edges()
			if commodity_id == "":
				issues.append(_issue(
					"missing_commodity_id",
					"Bill-of-sale cargo line missing commodity_id.",
					{"doc_id": doc_id, "line_index": i}
				))
			var qty: int = int(line.get("quantity", line.get("declared_qty", 0)))
			if qty <= 0:
				issues.append(_issue(
					"invalid_quantity",
					"Bill-of-sale cargo line has non-positive quantity.",
					{"doc_id": doc_id, "line_index": i, "quantity": qty}
				))
	return issues


static func _collect_container_meta_issues(docs_by_id: Dictionary) -> Array:
	var issues: Array = []
	var doc_ids: Array = docs_by_id.keys()
	doc_ids.sort()
	for doc_id_variant in doc_ids:
		var doc_id: String = String(doc_id_variant)
		var doc_variant = docs_by_id.get(doc_id_variant, {})
		if not (doc_variant is Dictionary):
			continue
		var doc: Dictionary = doc_variant
		var container_meta_variant = doc.get("container_meta", null)
		if container_meta_variant == null:
			continue
		if not (container_meta_variant is Dictionary):
			issues.append(_issue(
				"malformed_container_meta",
				"container_meta is malformed.",
				{"doc_id": doc_id}
			))
			continue
		var container_meta: Dictionary = container_meta_variant
		var container_id: String = String(container_meta.get("container_id", "")).strip_edges()
		var seal_state: String = String(container_meta.get("seal_state", "")).strip_edges()
		var seal_id: String = String(container_meta.get("seal_id", "")).strip_edges()
		if container_id == "":
			issues.append(_issue("missing_container_id", "container_meta.container_id is missing.", {"doc_id": doc_id}))
		if seal_state == "":
			issues.append(_issue("missing_seal_state", "container_meta.seal_state is missing.", {"doc_id": doc_id}))
		if seal_state == "sealed" and seal_id == "":
			issues.append(_issue("sealed_without_seal_id", "Sealed container is missing seal_id.", {"doc_id": doc_id}))
	return issues


static func _check(
	check_id: String,
	status: String,
	severity: String,
	summary: String,
	details: Dictionary = {}
) -> Dictionary:
	return {
		"check_id": check_id,
		"status": status,
		"severity": severity,
		"summary": summary,
		"details": details.duplicate(true),
	}


static func _finding(
	finding_id: String,
	severity: String,
	code: String,
	message: String,
	details: Dictionary = {}
) -> Dictionary:
	return {
		"finding_id": finding_id,
		"severity": severity,
		"code": code,
		"message": message,
		"details": details.duplicate(true),
	}


static func _issue(code: String, message: String, details: Dictionary = {}) -> Dictionary:
	var payload: Dictionary = details.duplicate(true)
	payload["code"] = code
	payload["message"] = message
	return payload


static func _severity_rank(severity: String) -> int:
	var normalized: String = severity.to_lower().strip_edges()
	if normalized == SEVERITY_INVALID:
		return 0
	if normalized == SEVERITY_SUSPICIOUS:
		return 1
	return 2


static func _derive_classification(findings: Array) -> String:
	var has_invalid: bool = false
	var has_any: bool = false
	for finding_variant in findings:
		if not (finding_variant is Dictionary):
			continue
		has_any = true
		var finding: Dictionary = finding_variant
		if String(finding.get("severity", "")).to_lower() == SEVERITY_INVALID:
			has_invalid = true
			break
	if has_invalid:
		return "invalid"
	if has_any:
		return "suspicious"
	return "clean"


static func _sort_checks_in_place(checks: Array) -> void:
	for i in range(checks.size()):
		for j in range(i + 1, checks.size()):
			var left_variant = checks[i]
			var right_variant = checks[j]
			if not (left_variant is Dictionary) or not (right_variant is Dictionary):
				continue
			var left: Dictionary = left_variant
			var right: Dictionary = right_variant
			var left_id: String = String(left.get("check_id", ""))
			var right_id: String = String(right.get("check_id", ""))
			if right_id < left_id:
				checks[i] = right
				checks[j] = left


static func _sort_findings_in_place(findings: Array) -> void:
	for i in range(findings.size()):
		for j in range(i + 1, findings.size()):
			var left_variant = findings[i]
			var right_variant = findings[j]
			if not (left_variant is Dictionary) or not (right_variant is Dictionary):
				continue
			var left: Dictionary = left_variant
			var right: Dictionary = right_variant
			var left_rank: int = _severity_rank(String(left.get("severity", "")))
			var right_rank: int = _severity_rank(String(right.get("severity", "")))
			var should_swap: bool = false
			if right_rank < left_rank:
				should_swap = true
			elif right_rank == left_rank:
				var left_code: String = String(left.get("code", ""))
				var right_code: String = String(right.get("code", ""))
				if right_code < left_code:
					should_swap = true
				elif right_code == left_code:
					var left_message: String = String(left.get("message", ""))
					var right_message: String = String(right.get("message", ""))
					if right_message < left_message:
						should_swap = true
			if should_swap:
				findings[i] = right
				findings[j] = left
