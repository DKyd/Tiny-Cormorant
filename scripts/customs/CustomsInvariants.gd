extends RefCounted

const STATUS_PASS: String = "pass"
const STATUS_FAIL: String = "fail"
const STATUS_NOT_EVALUABLE: String = "not_evaluable"

const INVARIANT_ID_QTY: String = "L2INV-001"
const INVARIANT_ID_ROUTE: String = "L2INV-002"
const INVARIANT_ID_TIME: String = "L2INV-003"
const INVARIANT_ID_CONTAINER: String = "L2INV-004"
const INVARIANT_ID_BILL_SOURCE_PRESENCE: String = "L2INV-005"
const INVARIANT_ID_BILL_SOURCE_TOTALS: String = "L2INV-006"
const INVARIANT_ID_BILL_SOURCE_DOC_VALIDITY: String = "L2INV-007"
const INVARIANT_ID_BILL_SOURCE_DESTROYED: String = "L2INV-008"
const INVARIANT_ID_BILL_SOURCE_OVERSELL: String = "L2INV-009"


static func evaluate(context: Dictionary = {}) -> Array:
	var docs_by_id: Dictionary = _extract_docs_by_id(context)
	var cargo_snapshot: Dictionary = _extract_cargo_snapshot(context)

	var results: Array = []
	results.append(_evaluate_quantity_consistency(docs_by_id, cargo_snapshot))
	results.append(_evaluate_origin_destination_consistency_policy_disabled())
	results.append(_evaluate_timestamp_order_consistency(docs_by_id))
	results.append(_evaluate_container_meta_consistency(docs_by_id))
	results.append(_evaluate_bill_source_presence(docs_by_id))
	results.append(_evaluate_bill_source_totals(docs_by_id))
	results.append(_evaluate_bill_source_doc_validity(docs_by_id))
	results.append(_evaluate_bill_source_destroyed_status(docs_by_id))
	results.append(_evaluate_bill_source_oversell(docs_by_id))
	return results


static func _extract_docs_by_id(context: Dictionary) -> Dictionary:
	var docs_variant = context.get("docs", {})
	if not (docs_variant is Dictionary):
		return {}
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
		docs_by_id[doc_id] = (doc_variant as Dictionary).duplicate(true)
	return docs_by_id


static func _extract_cargo_snapshot(context: Dictionary) -> Dictionary:
	var cargo_variant = context.get("cargo", {})
	if not (cargo_variant is Dictionary):
		return {}
	var source_cargo: Dictionary = cargo_variant
	var cargo_snapshot: Dictionary = {}
	var commodity_ids: Array = source_cargo.keys()
	commodity_ids.sort()
	for commodity_id_variant in commodity_ids:
		var commodity_id: String = String(commodity_id_variant).strip_edges()
		if commodity_id == "":
			continue
		cargo_snapshot[commodity_id] = max(0, int(source_cargo[commodity_id_variant]))
	return cargo_snapshot


static func _result(
	invariant_id: String,
	status: String,
	severity: String,
	weight: int,
	summary: String,
	details: Dictionary = {}
) -> Dictionary:
	return {
		"id": invariant_id,
		"status": status,
		"severity": severity,
		"weight": weight,
		"summary": summary,
		"details": details.duplicate(true),
	}


static func _build_not_evaluable_details(reason: String, missing_inputs: Array = []) -> Dictionary:
	var normalized_missing_inputs: Array = []
	for item_variant in missing_inputs:
		var item: String = String(item_variant).strip_edges()
		if item == "":
			continue
		normalized_missing_inputs.append(item)
	normalized_missing_inputs.sort()
	var details := {
		"reason": reason,
	}
	if not normalized_missing_inputs.is_empty():
		details["missing_inputs"] = normalized_missing_inputs
	return details


static func _get_docs_by_type(docs_by_id: Dictionary, doc_types: Array) -> Array:
	var docs: Array = []
	var doc_ids: Array = docs_by_id.keys()
	doc_ids.sort()
	for doc_id in doc_ids:
		var doc: Dictionary = docs_by_id[doc_id]
		var doc_type: String = String(doc.get("doc_type", "")).strip_edges()
		if doc_types.has(doc_type):
			docs.append({
				"doc_id": String(doc.get("doc_id", doc_id)),
				"doc": doc,
			})
	return docs


static func _collect_declared_totals(doc_entries: Array) -> Dictionary:
	var totals: Dictionary = {}
	for entry_variant in doc_entries:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		var doc: Dictionary = entry.get("doc", {})
		if doc.is_empty():
			continue

		var cargo_lines_variant = doc.get("cargo_lines", [])
		if cargo_lines_variant is Array and not (cargo_lines_variant as Array).is_empty():
			var cargo_lines: Array = cargo_lines_variant
			for line_variant in cargo_lines:
				if not (line_variant is Dictionary):
					continue
				var line: Dictionary = line_variant
				var commodity_id: String = String(line.get("commodity_id", "")).strip_edges()
				if commodity_id == "":
					continue
				var qty: int = int(line.get("declared_qty", line.get("quantity", 0)))
				if qty <= 0:
					continue
				totals[commodity_id] = int(totals.get(commodity_id, 0)) + qty
			continue

		var commodity_id: String = String(doc.get("commodity_id", "")).strip_edges()
		var qty: int = int(doc.get("quantity", 0))
		if commodity_id != "" and qty > 0:
			totals[commodity_id] = int(totals.get(commodity_id, 0)) + qty
	return totals


static func _evaluate_quantity_consistency(docs_by_id: Dictionary, cargo_snapshot: Dictionary) -> Dictionary:
	var declaration_docs: Array = _get_docs_by_type(docs_by_id, ["declaration", "purchase_order"])
	if declaration_docs.is_empty():
		return _result(
			INVARIANT_ID_QTY,
			STATUS_NOT_EVALUABLE,
			"none",
			3,
			"Quantity consistency not evaluable: no declaration-like documents found.",
			_build_not_evaluable_details(
				"missing_declaration_docs",
				["docs.declaration_or_purchase_order"]
			)
		)
	if cargo_snapshot.is_empty():
		return _result(
			INVARIANT_ID_QTY,
			STATUS_NOT_EVALUABLE,
			"none",
			3,
			"Quantity consistency not evaluable: cargo snapshot is unavailable.",
			_build_not_evaluable_details("missing_cargo_snapshot", ["cargo"])
		)

	var declared_totals: Dictionary = _collect_declared_totals(declaration_docs)
	if declared_totals.is_empty():
		return _result(
			INVARIANT_ID_QTY,
			STATUS_NOT_EVALUABLE,
			"none",
			3,
			"Quantity consistency not evaluable: declarations have no usable quantity fields.",
			_build_not_evaluable_details(
				"missing_declaration_quantities",
				[
					"declaration.cargo_lines[].commodity_id",
					"declaration.cargo_lines[].declared_qty|quantity",
					"declaration.commodity_id",
					"declaration.quantity",
				]
			)
		)

	var commodity_ids: Dictionary = {}
	for commodity_id_variant in declared_totals.keys():
		commodity_ids[String(commodity_id_variant)] = true
	for commodity_id_variant in cargo_snapshot.keys():
		commodity_ids[String(commodity_id_variant)] = true

	var mismatches: Array = []
	var sorted_ids: Array = commodity_ids.keys()
	sorted_ids.sort()
	for commodity_id_variant in sorted_ids:
		var commodity_id: String = String(commodity_id_variant)
		var declared_qty: int = int(declared_totals.get(commodity_id, 0))
		var cargo_qty: int = int(cargo_snapshot.get(commodity_id, 0))
		if declared_qty == cargo_qty:
			continue
		mismatches.append({
			"commodity_id": commodity_id,
			"declared_qty": declared_qty,
			"cargo_qty": cargo_qty,
		})

	if not mismatches.is_empty():
		return _result(
			INVARIANT_ID_QTY,
			STATUS_FAIL,
			"invalid",
			3,
			"Declaration quantities do not match cargo totals.",
			{
				"mismatch_count": mismatches.size(),
				"mismatches": mismatches,
			}
		)

	return _result(
		INVARIANT_ID_QTY,
		STATUS_PASS,
		"none",
		3,
		"Declaration quantities match cargo totals."
	)


static func _evaluate_origin_destination_consistency_policy_disabled() -> Dictionary:
	return _result(
		INVARIANT_ID_ROUTE,
		STATUS_NOT_EVALUABLE,
		"none",
		2,
		"Route consistency not evaluable: policy-disabled until mandated routes exist.",
		_build_not_evaluable_details("policy_disabled_no_mandated_routes")
	)


static func _extract_doc_tick(doc: Dictionary) -> int:
	if doc.has("purchase_tick"):
		return int(doc.get("purchase_tick", -1))
	if doc.has("tick"):
		return int(doc.get("tick", -1))
	var container_meta_variant = doc.get("container_meta", {})
	if container_meta_variant is Dictionary:
		var container_meta: Dictionary = container_meta_variant
		if container_meta.has("packed_tick"):
			return int(container_meta.get("packed_tick", -1))
	return -1


static func _evaluate_timestamp_order_consistency(docs_by_id: Dictionary) -> Dictionary:
	var contract_docs: Array = _get_docs_by_type(docs_by_id, ["contract"])
	var declaration_docs: Array = _get_docs_by_type(docs_by_id, ["declaration", "purchase_order"])
	var bill_docs: Array = _get_docs_by_type(docs_by_id, ["bill_of_sale"])

	var violations: Array = []
	var comparable_checks: int = 0

	var declaration_tick_values: Array = []
	for entry_variant in declaration_docs:
		var entry: Dictionary = entry_variant
		var declaration_doc: Dictionary = entry.get("doc", {})
		var declaration_tick: int = _extract_doc_tick(declaration_doc)
		if declaration_tick >= 0:
			declaration_tick_values.append(declaration_tick)

	for entry_variant in contract_docs:
		var entry: Dictionary = entry_variant
		var contract_doc: Dictionary = entry.get("doc", {})
		var contract_doc_id: String = String(entry.get("doc_id", ""))
		var contract_tick: int = _extract_doc_tick(contract_doc)
		if contract_tick < 0:
			continue
		for declaration_tick_variant in declaration_tick_values:
			var declaration_tick: int = int(declaration_tick_variant)
			comparable_checks += 1
			if contract_tick > declaration_tick:
				violations.append({
					"kind": "contract_after_declaration",
					"contract_doc_id": contract_doc_id,
					"contract_tick": contract_tick,
					"declaration_tick": declaration_tick,
				})

	for entry_variant in bill_docs:
		var entry: Dictionary = entry_variant
		var bill_doc_id: String = String(entry.get("doc_id", ""))
		var bill_doc: Dictionary = entry.get("doc", {})
		var bill_tick: int = _extract_doc_tick(bill_doc)
		if bill_tick < 0:
			continue
		var cargo_lines_variant = bill_doc.get("cargo_lines", [])
		if not (cargo_lines_variant is Array):
			continue
		var cargo_lines: Array = cargo_lines_variant
		for line_variant in cargo_lines:
			if not (line_variant is Dictionary):
				continue
			var line: Dictionary = line_variant
			var sources_variant = line.get("sources", [])
			if not (sources_variant is Array):
				continue
			var sources: Array = sources_variant
			for source_variant in sources:
				if not (source_variant is Dictionary):
					continue
				var source: Dictionary = source_variant
				var source_doc_id: String = String(source.get("doc_id", "")).strip_edges()
				if source_doc_id == "":
					continue
				if not docs_by_id.has(source_doc_id):
					continue
				var source_doc: Dictionary = docs_by_id[source_doc_id]
				var source_tick: int = _extract_doc_tick(source_doc)
				if source_tick < 0:
					continue
				comparable_checks += 1
				if source_tick > bill_tick:
					violations.append({
						"kind": "source_after_bill_of_sale",
						"source_doc_id": source_doc_id,
						"source_tick": source_tick,
						"bill_doc_id": bill_doc_id,
						"bill_tick": bill_tick,
					})

	if comparable_checks == 0:
		return _result(
			INVARIANT_ID_TIME,
			STATUS_NOT_EVALUABLE,
			"none",
			2,
			"Timestamp/order consistency not evaluable: no comparable timestamps found.",
			_build_not_evaluable_details(
				"missing_comparable_timestamps",
				[
					"bill_of_sale.cargo_lines[].sources[].doc_id",
					"contract.purchase_tick|tick|container_meta.packed_tick",
					"declaration_or_purchase_order.purchase_tick|tick|container_meta.packed_tick",
				]
			)
		)

	if not violations.is_empty():
		return _result(
			INVARIANT_ID_TIME,
			STATUS_FAIL,
			"invalid",
			2,
			"Timestamp/order consistency check failed.",
			{
				"comparable_checks": comparable_checks,
				"violation_count": violations.size(),
				"violations": violations,
			}
		)

	return _result(
		INVARIANT_ID_TIME,
		STATUS_PASS,
		"none",
		2,
		"Timestamp/order consistency is valid.",
		{"comparable_checks": comparable_checks}
	)


static func _extract_relevant_container_docs(docs_by_id: Dictionary) -> Array:
	return _get_docs_by_type(docs_by_id, ["contract", "declaration", "purchase_order", "bill_of_sale"])


static func _evaluate_container_meta_consistency(docs_by_id: Dictionary) -> Dictionary:
	var relevant_docs: Array = _extract_relevant_container_docs(docs_by_id)
	if relevant_docs.is_empty():
		return _result(
			INVARIANT_ID_CONTAINER,
			STATUS_NOT_EVALUABLE,
			"none",
			2,
			"Container metadata consistency not evaluable: missing container fields.",
			_build_not_evaluable_details(
				"missing_container_fields",
				["docs.contract|declaration|purchase_order|bill_of_sale"]
			)
		)

	var docs_with_meta: int = 0
	var docs_with_required_fields: int = 0
	var sealed_without_id: Array = []
	var container_ids: Dictionary = {}
	var seal_states: Dictionary = {}

	for entry_variant in relevant_docs:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		var doc_id: String = String(entry.get("doc_id", "")).strip_edges()
		var doc: Dictionary = entry.get("doc", {})
		if doc.is_empty():
			continue

		var container_meta_variant = doc.get("container_meta", null)
		if not (container_meta_variant is Dictionary):
			continue
		docs_with_meta += 1
		var container_meta: Dictionary = container_meta_variant
		var container_id: String = String(container_meta.get("container_id", "")).strip_edges()
		var seal_state: String = String(container_meta.get("seal_state", "")).strip_edges()
		var seal_id: String = String(container_meta.get("seal_id", "")).strip_edges()

		if container_id != "" and seal_state != "":
			docs_with_required_fields += 1
			container_ids[container_id] = true
			seal_states[seal_state] = true

		if seal_state == "sealed" and seal_id == "":
			sealed_without_id.append(doc_id)

	if docs_with_required_fields == 0:
		return _result(
			INVARIANT_ID_CONTAINER,
			STATUS_NOT_EVALUABLE,
			"none",
			2,
			"Container metadata consistency not evaluable: missing container fields.",
			_build_not_evaluable_details(
				"missing_container_fields",
				["container_meta.container_id", "container_meta.seal_state"]
			)
		)

	if docs_with_meta > 0 and docs_with_meta < relevant_docs.size():
		return _result(
			INVARIANT_ID_CONTAINER,
			STATUS_FAIL,
			"suspicious",
			2,
			"Container metadata completeness mismatch across documents.",
			{
				"reason": "cross_doc_container_completeness_mismatch",
				"docs_with_container_meta": docs_with_meta,
				"relevant_doc_count": relevant_docs.size(),
			}
		)

	if docs_with_required_fields > 0 and docs_with_required_fields < relevant_docs.size():
		return _result(
			INVARIANT_ID_CONTAINER,
			STATUS_FAIL,
			"suspicious",
			2,
			"Container metadata completeness mismatch across documents.",
			{
				"reason": "cross_doc_container_completeness_mismatch",
				"docs_with_required_fields": docs_with_required_fields,
				"relevant_doc_count": relevant_docs.size(),
			}
		)

	var container_id_values: Array = container_ids.keys()
	container_id_values.sort()
	var seal_state_values: Array = seal_states.keys()
	seal_state_values.sort()
	sealed_without_id.sort()

	if container_id_values.size() > 1:
		return _result(
			INVARIANT_ID_CONTAINER,
			STATUS_FAIL,
			"suspicious",
			2,
			"Container metadata contradiction: container IDs differ across documents.",
			{
				"reason": "cross_doc_container_id_conflict",
				"container_ids": container_id_values,
			}
		)

	if seal_state_values.size() > 1:
		return _result(
			INVARIANT_ID_CONTAINER,
			STATUS_FAIL,
			"suspicious",
			2,
			"Container metadata contradiction: seal states differ across documents.",
			{
				"reason": "cross_doc_seal_state_conflict",
				"seal_states": seal_state_values,
			}
		)

	if not sealed_without_id.is_empty():
		return _result(
			INVARIANT_ID_CONTAINER,
			STATUS_FAIL,
			"suspicious",
			2,
			"Container metadata contradiction: sealed container is missing seal ID.",
			{
				"reason": "sealed_without_seal_id",
				"doc_ids": sealed_without_id,
			}
		)

	return _result(
		INVARIANT_ID_CONTAINER,
		STATUS_PASS,
		"none",
		2,
		"Container metadata consistency is valid.",
		{
			"relevant_doc_count": relevant_docs.size(),
			"docs_with_required_fields": docs_with_required_fields,
		}
	)



static func _collect_bill_line_entries(docs_by_id: Dictionary) -> Array:
	var entries: Array = []
	var doc_ids: Array = docs_by_id.keys()
	doc_ids.sort()
	for doc_id_variant in doc_ids:
		var doc_id: String = String(doc_id_variant).strip_edges()
		if doc_id == "":
			continue
		var doc_variant = docs_by_id[doc_id_variant]
		if not (doc_variant is Dictionary):
			continue
		var doc: Dictionary = doc_variant
		if String(doc.get("doc_type", "")).strip_edges() != "bill_of_sale":
			continue
		var bill_doc_id: String = String(doc.get("doc_id", doc_id)).strip_edges()
		if bill_doc_id == "":
			bill_doc_id = doc_id
		var cargo_lines_variant = doc.get("cargo_lines", [])
		if not (cargo_lines_variant is Array):
			entries.append({
				"bill_doc_id": bill_doc_id,
				"line_index": -1,
				"commodity_id": "",
				"sold_qty": 0,
				"sources": null,
			})
			continue
		var cargo_lines: Array = cargo_lines_variant
		for line_index in range(cargo_lines.size()):
			var line_variant = cargo_lines[line_index]
			if not (line_variant is Dictionary):
				continue
			var line: Dictionary = line_variant
			var sold_qty: int = int(line.get("sold_qty", line.get("declared_qty", line.get("quantity", 0))))
			entries.append({
				"bill_doc_id": bill_doc_id,
				"line_index": line_index,
				"commodity_id": String(line.get("commodity_id", "")).strip_edges(),
				"sold_qty": sold_qty,
				"sources": line.get("sources", null),
			})
	return entries


static func _extract_source_availability_for_math(docs_by_id: Dictionary) -> Dictionary:
	var availability: Dictionary = {}
	var doc_ids: Array = docs_by_id.keys()
	doc_ids.sort()
	for doc_id_variant in doc_ids:
		var doc_id: String = String(doc_id_variant).strip_edges()
		if doc_id == "":
			continue
		var doc_variant = docs_by_id[doc_id_variant]
		if not (doc_variant is Dictionary):
			continue
		var doc: Dictionary = doc_variant
		var doc_type: String = String(doc.get("doc_type", "")).strip_edges()
		if doc_type != "purchase_order" and doc_type != "contract":
			continue
		var source_doc_id: String = String(doc.get("doc_id", doc_id)).strip_edges()
		if source_doc_id == "":
			source_doc_id = doc_id
		var commodity_qty: Dictionary = {}
		var cargo_lines_variant = doc.get("cargo_lines", [])
		if cargo_lines_variant is Array:
			var cargo_lines: Array = cargo_lines_variant
			for line_variant in cargo_lines:
				if not (line_variant is Dictionary):
					continue
				var line: Dictionary = line_variant
				var commodity_id: String = String(line.get("commodity_id", "")).strip_edges()
				if commodity_id == "":
					continue
				var qty: int = int(line.get("declared_qty", line.get("quantity", 0)))
				if qty <= 0:
					continue
				commodity_qty[commodity_id] = int(commodity_qty.get(commodity_id, 0)) + qty
		else:
			var commodity_id: String = String(doc.get("commodity_id", "")).strip_edges()
			var qty: int = int(doc.get("quantity", 0))
			if commodity_id != "" and qty > 0:
				commodity_qty[commodity_id] = qty
		availability[source_doc_id] = {
			"commodity_qty": commodity_qty,
			"has_quantity_data": not commodity_qty.is_empty(),
		}
	return availability


static func _sort_chain_issues(issues: Array) -> void:
	for i in range(issues.size()):
		for j in range(i + 1, issues.size()):
			var left_variant = issues[i]
			var right_variant = issues[j]
			if not (left_variant is Dictionary) or not (right_variant is Dictionary):
				continue
			var left: Dictionary = left_variant
			var right: Dictionary = right_variant
			var left_bill: String = String(left.get("bill_doc_id", ""))
			var right_bill: String = String(right.get("bill_doc_id", ""))
			var left_line: int = int(left.get("line_index", -1))
			var right_line: int = int(right.get("line_index", -1))
			var left_source: int = int(left.get("source_index", -1))
			var right_source: int = int(right.get("source_index", -1))
			var left_reason: String = String(left.get("reason", ""))
			var right_reason: String = String(right.get("reason", ""))
			var should_swap: bool = false
			if right_bill < left_bill:
				should_swap = true
			elif right_bill == left_bill and right_line < left_line:
				should_swap = true
			elif right_bill == left_bill and right_line == left_line and right_source < left_source:
				should_swap = true
			elif right_bill == left_bill and right_line == left_line and right_source == left_source and right_reason < left_reason:
				should_swap = true
			if should_swap:
				issues[i] = right
				issues[j] = left


static func _evaluate_bill_source_presence(docs_by_id: Dictionary) -> Dictionary:
	var line_entries: Array = _collect_bill_line_entries(docs_by_id)
	if line_entries.is_empty():
		return _result(
			INVARIANT_ID_BILL_SOURCE_PRESENCE,
			STATUS_NOT_EVALUABLE,
			"none",
			3,
			"Bill-of-sale source presence not evaluable: no bill-of-sale documents found.",
			_build_not_evaluable_details("missing_bill_of_sale_docs", ["docs.bill_of_sale"])
		)
	var issues: Array = []
	for entry_variant in line_entries:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		var sold_qty: int = int(entry.get("sold_qty", 0))
		if sold_qty <= 0:
			continue
		var sources_variant = entry.get("sources", null)
		var has_sources: bool = sources_variant is Array and not (sources_variant as Array).is_empty()
		if has_sources:
			continue
		issues.append({
			"reason": "missing_sources",
			"bill_doc_id": String(entry.get("bill_doc_id", "")),
			"line_index": int(entry.get("line_index", -1)),
			"source_index": -1,
			"commodity_id": String(entry.get("commodity_id", "")),
			"sold_qty": sold_qty,
		})
	if not issues.is_empty():
		_sort_chain_issues(issues)
		return _result(
			INVARIANT_ID_BILL_SOURCE_PRESENCE,
			STATUS_FAIL,
			"suspicious",
			3,
			"Bill-of-sale lines are missing required source references.",
			{
				"reason": "missing_sources",
				"issue_count": issues.size(),
				"issues": issues,
			}
		)
	return _result(
		INVARIANT_ID_BILL_SOURCE_PRESENCE,
		STATUS_PASS,
		"none",
		3,
		"Bill-of-sale lines include source references."
	)


static func _evaluate_bill_source_totals(docs_by_id: Dictionary) -> Dictionary:
	var line_entries: Array = _collect_bill_line_entries(docs_by_id)
	if line_entries.is_empty():
		return _result(
			INVARIANT_ID_BILL_SOURCE_TOTALS,
			STATUS_NOT_EVALUABLE,
			"none",
			3,
			"Bill-of-sale source totals not evaluable: no bill-of-sale documents found.",
			_build_not_evaluable_details("missing_bill_of_sale_docs", ["docs.bill_of_sale"])
		)
	var issues: Array = []
	for entry_variant in line_entries:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		var sold_qty: int = int(entry.get("sold_qty", 0))
		if sold_qty <= 0:
			continue
		var sources_variant = entry.get("sources", null)
		if sources_variant != null and not (sources_variant is Array):
			issues.append({
				"reason": "sources_field_not_array",
				"bill_doc_id": String(entry.get("bill_doc_id", "")),
				"line_index": int(entry.get("line_index", -1)),
				"source_index": -1,
				"commodity_id": String(entry.get("commodity_id", "")),
				"sold_qty": sold_qty,
			})
			continue
		if not (sources_variant is Array):
			continue
		var sources: Array = sources_variant
		var total_source_qty: int = 0
		for source_variant in sources:
			if not (source_variant is Dictionary):
				continue
			var source: Dictionary = source_variant
			var source_qty: int = int(source.get("qty", 0))
			if source_qty <= 0:
				continue
			total_source_qty += source_qty
		if total_source_qty == sold_qty:
			continue
		issues.append({
			"reason": "source_total_mismatch",
			"bill_doc_id": String(entry.get("bill_doc_id", "")),
			"line_index": int(entry.get("line_index", -1)),
			"source_index": -1,
			"commodity_id": String(entry.get("commodity_id", "")),
			"sold_qty": sold_qty,
			"sourced_qty": total_source_qty,
		})
	if not issues.is_empty():
		_sort_chain_issues(issues)
		return _result(
			INVARIANT_ID_BILL_SOURCE_TOTALS,
			STATUS_FAIL,
			"invalid",
			3,
			"Bill-of-sale source totals do not match sold quantities.",
			{
				"reason": "source_total_mismatch",
				"issue_count": issues.size(),
				"issues": issues,
			}
		)
	return _result(
		INVARIANT_ID_BILL_SOURCE_TOTALS,
		STATUS_PASS,
		"none",
		3,
		"Bill-of-sale source totals match sold quantities."
	)


static func _evaluate_bill_source_doc_validity(docs_by_id: Dictionary) -> Dictionary:
	var line_entries: Array = _collect_bill_line_entries(docs_by_id)
	if line_entries.is_empty():
		return _result(
			INVARIANT_ID_BILL_SOURCE_DOC_VALIDITY,
			STATUS_NOT_EVALUABLE,
			"none",
			3,
			"Bill-of-sale source validity not evaluable: no bill-of-sale documents found.",
			_build_not_evaluable_details("missing_bill_of_sale_docs", ["docs.bill_of_sale"])
		)
	var source_availability: Dictionary = _extract_source_availability_for_math(docs_by_id)
	var issues: Array = []
	for entry_variant in line_entries:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		var sold_qty: int = int(entry.get("sold_qty", 0))
		if sold_qty <= 0:
			continue
		var sources_variant = entry.get("sources", null)
		if not (sources_variant is Array):
			continue
		var sources: Array = sources_variant
		for source_index in range(sources.size()):
			var source_variant = sources[source_index]
			if not (source_variant is Dictionary):
				continue
			var source: Dictionary = source_variant
			var source_doc_id: String = String(source.get("doc_id", "")).strip_edges()
			var source_qty: int = int(source.get("qty", 0))
			if source_doc_id == "" or source_qty <= 0:
				issues.append({
					"reason": "invalid_source_entry",
					"severity": "suspicious",
					"bill_doc_id": String(entry.get("bill_doc_id", "")),
					"line_index": int(entry.get("line_index", -1)),
					"source_index": source_index,
					"source_doc_id": source_doc_id,
					"source_qty": source_qty,
				})
				continue
			if not docs_by_id.has(source_doc_id):
				issues.append({
					"reason": "missing_source_doc",
					"severity": "invalid",
					"bill_doc_id": String(entry.get("bill_doc_id", "")),
					"line_index": int(entry.get("line_index", -1)),
					"source_index": source_index,
					"source_doc_id": source_doc_id,
				})
				continue
			var source_doc_variant = docs_by_id[source_doc_id]
			if not (source_doc_variant is Dictionary):
				issues.append({
					"reason": "missing_source_doc",
					"severity": "invalid",
					"bill_doc_id": String(entry.get("bill_doc_id", "")),
					"line_index": int(entry.get("line_index", -1)),
					"source_index": source_index,
					"source_doc_id": source_doc_id,
				})
				continue
			var source_doc: Dictionary = source_doc_variant
			var source_doc_type: String = String(source_doc.get("doc_type", "")).strip_edges()
			if source_doc_type != "purchase_order" and source_doc_type != "contract":
				issues.append({
					"reason": "disallowed_source_doc_type",
					"severity": "invalid",
					"bill_doc_id": String(entry.get("bill_doc_id", "")),
					"line_index": int(entry.get("line_index", -1)),
					"source_index": source_index,
					"source_doc_id": source_doc_id,
					"source_doc_type": source_doc_type,
				})
				continue
			var source_math: Dictionary = source_availability.get(source_doc_id, {})
			if not bool(source_math.get("has_quantity_data", false)):
				issues.append({
					"reason": "missing_source_quantity_data",
					"severity": "suspicious",
					"bill_doc_id": String(entry.get("bill_doc_id", "")),
					"line_index": int(entry.get("line_index", -1)),
					"source_index": source_index,
					"source_doc_id": source_doc_id,
				})
				continue
			var commodity_id: String = String(entry.get("commodity_id", "")).strip_edges()
			var commodity_qty: Dictionary = source_math.get("commodity_qty", {})
			if int(commodity_qty.get(commodity_id, 0)) <= 0:
				issues.append({
					"reason": "source_missing_commodity",
					"severity": "invalid",
					"bill_doc_id": String(entry.get("bill_doc_id", "")),
					"line_index": int(entry.get("line_index", -1)),
					"source_index": source_index,
					"source_doc_id": source_doc_id,
					"commodity_id": commodity_id,
				})
	if not issues.is_empty():
		_sort_chain_issues(issues)
		var severity: String = "suspicious"
		for issue_variant in issues:
			if not (issue_variant is Dictionary):
				continue
			var issue: Dictionary = issue_variant
			if String(issue.get("severity", "")).strip_edges() == "invalid":
				severity = "invalid"
				break
		return _result(
			INVARIANT_ID_BILL_SOURCE_DOC_VALIDITY,
			STATUS_FAIL,
			severity,
			3,
			"Bill-of-sale source documents failed validity checks.",
			{
				"issue_count": issues.size(),
				"issues": issues,
			}
		)
	return _result(
		INVARIANT_ID_BILL_SOURCE_DOC_VALIDITY,
		STATUS_PASS,
		"none",
		3,
		"Bill-of-sale source documents are valid."
	)


static func _evaluate_bill_source_destroyed_status(docs_by_id: Dictionary) -> Dictionary:
	var line_entries: Array = _collect_bill_line_entries(docs_by_id)
	if line_entries.is_empty():
		return _result(
			INVARIANT_ID_BILL_SOURCE_DESTROYED,
			STATUS_NOT_EVALUABLE,
			"none",
			3,
			"Bill-of-sale source destruction check not evaluable: no bill-of-sale documents found.",
			_build_not_evaluable_details("missing_bill_of_sale_docs", ["docs.bill_of_sale"])
		)
	var issues: Array = []
	for entry_variant in line_entries:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		var sold_qty: int = int(entry.get("sold_qty", 0))
		if sold_qty <= 0:
			continue
		var sources_variant = entry.get("sources", null)
		if not (sources_variant is Array):
			continue
		var sources: Array = sources_variant
		for source_index in range(sources.size()):
			var source_variant = sources[source_index]
			if not (source_variant is Dictionary):
				continue
			var source: Dictionary = source_variant
			var source_doc_id: String = String(source.get("doc_id", "")).strip_edges()
			if source_doc_id == "" or not docs_by_id.has(source_doc_id):
				continue
			var source_doc_variant = docs_by_id[source_doc_id]
			if not (source_doc_variant is Dictionary):
				continue
			var source_doc: Dictionary = source_doc_variant
			if not bool(source_doc.get("is_destroyed", false)):
				continue
			issues.append({
				"reason": "destroyed_source_doc",
				"bill_doc_id": String(entry.get("bill_doc_id", "")),
				"line_index": int(entry.get("line_index", -1)),
				"source_index": source_index,
				"source_doc_id": source_doc_id,
			})
	if not issues.is_empty():
		_sort_chain_issues(issues)
		return _result(
			INVARIANT_ID_BILL_SOURCE_DESTROYED,
			STATUS_FAIL,
			"invalid",
			3,
			"Bill-of-sale references include destroyed source documents.",
			{
				"reason": "destroyed_source_doc",
				"issue_count": issues.size(),
				"issues": issues,
			}
		)
	return _result(
		INVARIANT_ID_BILL_SOURCE_DESTROYED,
		STATUS_PASS,
		"none",
		3,
		"Bill-of-sale sources do not reference destroyed documents."
	)


static func _evaluate_bill_source_oversell(docs_by_id: Dictionary) -> Dictionary:
	var line_entries: Array = _collect_bill_line_entries(docs_by_id)
	if line_entries.is_empty():
		return _result(
			INVARIANT_ID_BILL_SOURCE_OVERSELL,
			STATUS_NOT_EVALUABLE,
			"none",
			3,
			"Bill-of-sale oversell check not evaluable: no bill-of-sale documents found.",
			_build_not_evaluable_details("missing_bill_of_sale_docs", ["docs.bill_of_sale"])
		)
	var source_availability: Dictionary = _extract_source_availability_for_math(docs_by_id)
	var sold_by_source: Dictionary = {}
	var missing_availability_issues: Array = []
	for entry_variant in line_entries:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		var commodity_id: String = String(entry.get("commodity_id", "")).strip_edges()
		if commodity_id == "":
			continue
		var sold_qty: int = int(entry.get("sold_qty", 0))
		if sold_qty <= 0:
			continue
		var sources_variant = entry.get("sources", null)
		if not (sources_variant is Array):
			continue
		var sources: Array = sources_variant
		for source_index in range(sources.size()):
			var source_variant = sources[source_index]
			if not (source_variant is Dictionary):
				continue
			var source: Dictionary = source_variant
			var source_doc_id: String = String(source.get("doc_id", "")).strip_edges()
			var source_qty: int = int(source.get("qty", 0))
			if source_doc_id == "" or source_qty <= 0:
				continue
			if not docs_by_id.has(source_doc_id):
				continue
			var source_doc_variant = docs_by_id[source_doc_id]
			if not (source_doc_variant is Dictionary):
				continue
			var source_doc: Dictionary = source_doc_variant
			var source_doc_type: String = String(source_doc.get("doc_type", "")).strip_edges()
			if source_doc_type != "purchase_order" and source_doc_type != "contract":
				continue
			var source_math: Dictionary = source_availability.get(source_doc_id, {})
			var has_qty_data: bool = bool(source_math.get("has_quantity_data", false))
			var commodity_qty: Dictionary = source_math.get("commodity_qty", {})
			var has_commodity: bool = commodity_qty.has(commodity_id)
			if not has_qty_data or not has_commodity:
				missing_availability_issues.append({
					"reason": "missing_availability_for_source",
					"bill_doc_id": String(entry.get("bill_doc_id", "")),
					"line_index": int(entry.get("line_index", -1)),
					"source_index": source_index,
					"source_doc_id": source_doc_id,
					"commodity_id": commodity_id,
				})
				continue
			var key: String = "%s|%s" % [source_doc_id, commodity_id]
			sold_by_source[key] = int(sold_by_source.get(key, 0)) + source_qty
	if not missing_availability_issues.is_empty():
		_sort_chain_issues(missing_availability_issues)
		return _result(
			INVARIANT_ID_BILL_SOURCE_OVERSELL,
			STATUS_FAIL,
			"suspicious",
			3,
			"Bill-of-sale oversell check failed: missing availability for one or more sources.",
			{
				"reason": "missing_availability_for_source",
				"issue_count": missing_availability_issues.size(),
				"issues": missing_availability_issues,
			}
		)
	var oversold_issues: Array = []
	var sold_keys: Array = sold_by_source.keys()
	sold_keys.sort()
	for sold_key_variant in sold_keys:
		var sold_key: String = String(sold_key_variant)
		var parts: Array = sold_key.split("|")
		if parts.size() != 2:
			continue
		var source_doc_id: String = parts[0]
		var commodity_id: String = parts[1]
		var sold_qty: int = int(sold_by_source.get(sold_key, 0))
		var source_math: Dictionary = source_availability.get(source_doc_id, {})
		var commodity_qty: Dictionary = source_math.get("commodity_qty", {})
		var available_qty: int = int(commodity_qty.get(commodity_id, 0))
		if sold_qty <= available_qty:
			continue
		oversold_issues.append({
			"reason": "source_oversold",
			"bill_doc_id": "",
			"line_index": -1,
			"source_index": -1,
			"source_doc_id": source_doc_id,
			"commodity_id": commodity_id,
			"sold_qty": sold_qty,
			"available_qty": available_qty,
		})
	if not oversold_issues.is_empty():
		_sort_chain_issues(oversold_issues)
		return _result(
			INVARIANT_ID_BILL_SOURCE_OVERSELL,
			STATUS_FAIL,
			"invalid",
			3,
			"Bill-of-sale sources are oversold against available documentary quantities.",
			{
				"reason": "source_oversold",
				"issue_count": oversold_issues.size(),
				"issues": oversold_issues,
			}
		)
	return _result(
		INVARIANT_ID_BILL_SOURCE_OVERSELL,
		STATUS_PASS,
		"none",
		3,
		"Bill-of-sale source quantities are not oversold."
	)


