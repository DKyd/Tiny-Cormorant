extends RefCounted

const SURFACE_COMPLIANCE_RULES := {
	"contract": {
		"required_fields": [
			"doc_id",
			"doc_type",
			"contract_id",
			"status",
			"origin_system_id",
			"destination_system_id",
			"cargo_lines",
			"container_meta",
		],
		"required_arrays": [
			"cargo_lines",
		],
		"cargo_line_required_fields": [
			"commodity_id",
			"declared_qty",
		],
		"numeric_fields": [
			"declared_qty",
		],
		"container_meta_required_fields": [
			"container_id",
			"seal_state",
		],
		"seal_requires_id": true,
	},
	"purchase_order": {
		"required_fields": [
			"doc_id",
			"doc_type",
			"status",
			"commodity_id",
			"quantity",
			"unit_price",
			"total_cost",
			"purchase_tick",
			"purchase_system_id",
			"purchase_location_id",
			"container_meta",
			"cargo_lines",
		],
		"required_arrays": [
			"cargo_lines",
		],
		"cargo_line_required_fields": [
			"commodity_id",
			"declared_qty",
		],
		"numeric_fields": [
			"quantity",
			"unit_price",
			"total_cost",
			"purchase_tick",
			"declared_qty",
		],
		"container_meta_required_fields": [
			"container_id",
			"seal_state",
		],
		"seal_requires_id": false,
	},
	"bill_of_sale": {
		"required_fields": [
			"doc_id",
			"doc_type",
			"status",
			"market_kind",
			"system_id",
			"location_id",
			"tick",
			"cargo_lines",
			"container_meta",
		],
		"required_arrays": [
			"cargo_lines",
		],
		"cargo_line_required_fields": [
			"commodity_id",
			"sold_qty",
			"unit_price",
			"total_price",
			"sources",
		],
		"numeric_fields": [
			"sold_qty",
			"unit_price",
			"total_price",
			"tick",
			"qty",
		],
		"container_meta_required_fields": [
			"container_id",
			"seal_state",
		],
		"seal_requires_id": false,
	},
}

const SURFACE_ACTION_REQUIREMENTS := {
	"ENTRY_CLEARANCE": {
		"required_any_of_doc_types": ["purchase_order", "contract"],
		"requires_cargo_present": true,
	},
	"PORT_DEPARTURE_CLEARANCE": {
		"required_any_of_doc_types": ["purchase_order", "contract"],
		"requires_cargo_present": true,
	},
	"SELL_CARGO_LEGAL": {
		"required_any_of_doc_types": ["purchase_order", "contract"],
		"requires_cargo_present": true,
	},
}


static func _is_non_empty_string(value) -> bool:
	return value is String and value.strip_edges() != ""


static func _append_surface_issue(issues: Array, code: String, message: String, path: String) -> void:
	issues.append({
		"code": code,
		"message": message,
		"path": path,
	})


static func _validate_numeric_field(value, issues: Array, path: String) -> void:
	if not (value is int or value is float):
		_append_surface_issue(issues, "invalid_type", "Expected numeric value.", path)
		return
	if float(value) < 0.0:
		_append_surface_issue(issues, "negative_value", "Value must be non-negative.", path)


static func _validate_required_field(
	doc: Dictionary,
	field: String,
	issues: Array,
	path_prefix: String = ""
) -> void:
	var path: String = field if path_prefix == "" else "%s.%s" % [path_prefix, field]
	if not doc.has(field):
		_append_surface_issue(issues, "missing_field", "Missing required field.", path)
		return
	var value = doc.get(field)
	if value is String and value.strip_edges() == "":
		_append_surface_issue(issues, "missing_field", "Missing required field.", path)


static func _validate_container_meta(
	container_meta_variant,
	rules: Dictionary,
	issues: Array
) -> void:
	if not (container_meta_variant is Dictionary):
		_append_surface_issue(issues, "invalid_type", "Container metadata must be a dictionary.", "container_meta")
		return
	var container_meta: Dictionary = container_meta_variant
	for field_variant in rules.get("container_meta_required_fields", []):
		var field: String = String(field_variant)
		if not _is_non_empty_string(container_meta.get(field, "")):
			_append_surface_issue(
				issues,
				"missing_field",
				"Missing required container field.",
				"container_meta.%s" % field
			)
	if bool(rules.get("seal_requires_id", false)) and String(container_meta.get("seal_state", "")) == "sealed":
		if not _is_non_empty_string(container_meta.get("seal_id", "")):
			_append_surface_issue(
				issues,
				"missing_field",
				"Missing required container field when sealed.",
				"container_meta.seal_id"
			)


static func _validate_cargo_lines(
	cargo_lines_variant,
	rules: Dictionary,
	issues: Array
) -> void:
	if not (cargo_lines_variant is Array):
		_append_surface_issue(issues, "invalid_type", "Cargo lines must be an array.", "cargo_lines")
		return
	var cargo_lines: Array = cargo_lines_variant
	for index in range(cargo_lines.size()):
		var line_variant = cargo_lines[index]
		var path_prefix: String = "cargo_lines[%d]" % index
		if not (line_variant is Dictionary):
			_append_surface_issue(issues, "invalid_type", "Cargo line must be a dictionary.", path_prefix)
			continue
		var line: Dictionary = line_variant
		for field_variant in rules.get("cargo_line_required_fields", []):
			var field: String = String(field_variant)
			_validate_required_field(line, field, issues, path_prefix)
			if rules.get("numeric_fields", []).has(field) and line.has(field):
				_validate_numeric_field(line.get(field), issues, "%s.%s" % [path_prefix, field])
		if line.has("sources"):
			var sources_variant = line.get("sources")
			if not (sources_variant is Array):
				_append_surface_issue(
					issues,
					"invalid_type",
					"Sources must be an array.",
					"%s.sources" % path_prefix
				)
			else:
				var sources: Array = sources_variant
				if sources.is_empty():
					_append_surface_issue(
						issues,
						"missing_field",
						"Sources must not be empty.",
						"%s.sources" % path_prefix
					)
				for source_index in range(sources.size()):
					var source_variant = sources[source_index]
					var source_path: String = "%s.sources[%d]" % [path_prefix, source_index]
					if not (source_variant is Dictionary):
						_append_surface_issue(
							issues,
							"invalid_type",
							"Source entry must be a dictionary.",
							source_path
						)
						continue
					var source: Dictionary = source_variant
					if not _is_non_empty_string(source.get("doc_id", "")):
						_append_surface_issue(
							issues,
							"missing_field",
							"Missing required source field.",
							"%s.doc_id" % source_path
						)
					if not source.has("qty"):
						_append_surface_issue(
							issues,
							"missing_field",
							"Missing required source field.",
							"%s.qty" % source_path
						)
					else:
						_validate_numeric_field(source.get("qty"), issues, "%s.qty" % source_path)


static func validate_freight_doc_surface(doc: Dictionary) -> Dictionary:
	var issues: Array = []
	var doc_id: String = str(doc.get("doc_id", ""))
	var doc_type: String = str(doc.get("doc_type", ""))

	if not _is_non_empty_string(doc.get("doc_id", "")):
		_append_surface_issue(issues, "missing_field", "Missing required field.", "doc_id")
	if not _is_non_empty_string(doc.get("doc_type", "")):
		_append_surface_issue(issues, "missing_field", "Missing required field.", "doc_type")

	if doc_type == "" or not SURFACE_COMPLIANCE_RULES.has(doc_type):
		if doc_type != "":
			_append_surface_issue(
				issues,
				"unsupported_doc_type",
				"Unsupported document type.",
				"doc_type"
			)
		return {
			"doc_id": doc_id,
			"doc_type": doc_type,
			"ok": issues.is_empty(),
			"issues": issues,
		}

	var rules: Dictionary = SURFACE_COMPLIANCE_RULES.get(doc_type, {})
	for field_variant in rules.get("required_fields", []):
		var field: String = String(field_variant)
		_validate_required_field(doc, field, issues)

	for field_variant in rules.get("required_arrays", []):
		var field: String = String(field_variant)
		var arr_variant = doc.get(field)
		if not (arr_variant is Array) or (arr_variant as Array).is_empty():
			_append_surface_issue(
				issues,
				"missing_field",
				"Required array must be present and non-empty.",
				field
			)

	for field_variant in rules.get("numeric_fields", []):
		var field: String = String(field_variant)
		if doc.has(field):
			_validate_numeric_field(doc.get(field), issues, field)

	_validate_container_meta(doc.get("container_meta"), rules, issues)
	_validate_cargo_lines(doc.get("cargo_lines"), rules, issues)

	return {
		"doc_id": doc_id,
		"doc_type": doc_type,
		"ok": issues.is_empty(),
		"issues": issues,
	}


static func validate_freight_docs_for_action(context: Dictionary = {}) -> Array:
	var docs_variant = context.get("docs", [])
	if not (docs_variant is Array):
		return []
	var results: Array = []
	var docs: Array = docs_variant
	for doc_variant in docs:
		if not (doc_variant is Dictionary):
			continue
		results.append(validate_freight_doc_surface(doc_variant))
	return results


static func _has_positive_cargo(cargo_variant) -> bool:
	if not (cargo_variant is Dictionary):
		return false
	var cargo_dict: Dictionary = cargo_variant
	for qty_variant in cargo_dict.values():
		if qty_variant is int or qty_variant is float:
			if float(qty_variant) > 0.0:
				return true
	return false


static func validate_action_surface_compliance(action: String, context: Dictionary = {}) -> Dictionary:
	var result := {
		"action": action,
		"ok": true,
		"issues": [],
	}

	if action == "":
		return result
	if not SURFACE_ACTION_REQUIREMENTS.has(action):
		result.issues.append({
			"code": "unsupported_action",
			"message": "Unsupported action for surface compliance.",
			"path": "action",
		})
		result.ok = false
		return result

	var rules: Dictionary = SURFACE_ACTION_REQUIREMENTS.get(action, {})
	var cargo_present: bool = _has_positive_cargo(context.get("cargo", {}))
	if bool(rules.get("requires_cargo_present", false)) and not cargo_present:
		return result

	var required_any_variant = rules.get("required_any_of_doc_types", [])
	if not (required_any_variant is Array) or required_any_variant.is_empty():
		return result

	var required_any_of: Array = required_any_variant
	var docs_variant = context.get("docs", [])
	var found := false
	if docs_variant is Array:
		var docs: Array = docs_variant
		for doc_variant in docs:
			if not (doc_variant is Dictionary):
				continue
			var doc: Dictionary = doc_variant
			var doc_type: String = String(doc.get("doc_type", ""))
			if required_any_of.has(doc_type):
				found = true
				break

	if not found:
		result.issues.append({
			"code": "missing_required_doc_type",
			"message": "Missing required document types for action.",
			"path": "freight_docs.doc_type",
			"required_any_of_doc_types": required_any_of.duplicate(),
		})
		result.ok = false

	return result