extends RefCounted

const STATUS_PASS: String = "pass"
const STATUS_FAIL: String = "fail"
const STATUS_NOT_EVALUABLE: String = "not_evaluable"

const INVARIANT_ID_QTY: String = "L2INV-001"
const INVARIANT_ID_ROUTE: String = "L2INV-002"
const INVARIANT_ID_TIME: String = "L2INV-003"
const INVARIANT_ID_CONTAINER: String = "L2INV-004"


static func evaluate(context: Dictionary = {}) -> Array:
	var docs_by_id: Dictionary = _extract_docs_by_id(context)
	var cargo_snapshot: Dictionary = _extract_cargo_snapshot(context)

	var results: Array = []
	results.append(_evaluate_quantity_consistency(docs_by_id, cargo_snapshot))
	results.append(_evaluate_origin_destination_consistency_policy_disabled())
	results.append(_evaluate_timestamp_order_consistency(docs_by_id))
	results.append(_evaluate_container_meta_consistency(docs_by_id))
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
			{"reason": "missing_declaration_docs"}
		)
	if cargo_snapshot.is_empty():
		return _result(
			INVARIANT_ID_QTY,
			STATUS_NOT_EVALUABLE,
			"none",
			3,
			"Quantity consistency not evaluable: cargo snapshot is unavailable.",
			{"reason": "missing_cargo_snapshot"}
		)

	var declared_totals: Dictionary = _collect_declared_totals(declaration_docs)
	if declared_totals.is_empty():
		return _result(
			INVARIANT_ID_QTY,
			STATUS_NOT_EVALUABLE,
			"none",
			3,
			"Quantity consistency not evaluable: declarations have no usable quantity fields.",
			{"reason": "missing_declaration_quantities"}
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
		{"reason": "policy_disabled_no_mandated_routes"}
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
			{"reason": "missing_comparable_timestamps"}
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
			{"reason": "missing_container_fields"}
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
			{"reason": "missing_container_fields"}
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