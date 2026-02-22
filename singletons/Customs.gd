#C res://singletons/Customs.gd
extends Node

const CustomsLevel2Audit = preload("res://scripts/customs/CustomsLevel2Audit.gd")

# chance of customs inspection by pressure bucket
var inspection_chance := {
	"Low": 0.1,
	"Elevated": 0.3,
	"High": 0.5,
}

func _format_location_label(system_id: String, location_id: String) -> String:
	var system: Dictionary = Galaxy.get_system(system_id)
	var location: Dictionary = Galaxy.get_location(location_id)
	var system_name: String = String(system.get("name", system_id))
	var location_name: String = String(location.get("name", location_id))
	if system_name == "":
		system_name = system_id
	if location_name == "":
		location_name = location_id
	if system_name == "" and location_name == "":
		return "unknown location"
	if system_name == "":
		return location_name
	if location_name == "":
		return system_name
	return "%s (%s)" % [location_name, system_name]


func _log_inspection(action_label: String, system_id: String, location_id: String, report: Dictionary) -> void:
	var classification: String = String(report.get("classification", "")).strip_edges()
	if classification == "":
		classification = "unknown"
	var location_label: String = _format_location_label(system_id, location_id)
	Log.add_entry(
		"CUSTOMS: %s inspection at %s: %s."
			% [action_label, location_label, classification],
		"CUSTOMS"
	)


func _resolve_inspection_max_depth(system_id: String, location_id: String) -> int:
	var resolved: Dictionary = GameState.resolve_customs_inspection_depth({
		"system_id": system_id,
		"location_id": location_id,
	})
	var max_depth: int = int(resolved.get("max_depth", 1))
	if not bool(resolved.get("ok", false)):
		return 1
	var depth_bias: int = int(resolved.get("depth_bias", 0))
	if depth_bias > 0:
		var location_label: String = _format_location_label(system_id, location_id)
		Log.add_entry(
			"CUSTOMS: Heightened scrutiny at %s: +%d inspection depth due to recent Level-2 violations."
				% [location_label, depth_bias],
			"CUSTOMS"
		)
	return max_depth


func _normalize_level2_docs_for_audit(docs_variant) -> Dictionary:
	var docs_by_id: Dictionary = {}
	if docs_variant is Dictionary:
		var source_docs: Dictionary = docs_variant
		var source_keys: Array = source_docs.keys()
		source_keys.sort()
		for key_variant in source_keys:
			var key: String = String(key_variant).strip_edges()
			if key == "":
				continue
			var value_variant = source_docs[key_variant]
			if value_variant is Dictionary:
				var doc: Dictionary = (value_variant as Dictionary).duplicate(true)
				var doc_id: String = String(doc.get("doc_id", key)).strip_edges()
				if doc_id == "":
					doc_id = key
				doc["doc_id"] = doc_id
				docs_by_id[doc_id] = doc
				continue
			if value_variant is Array:
				var bucket_docs: Array = value_variant
				for i in range(bucket_docs.size()):
					var bucket_doc_variant = bucket_docs[i]
					if not (bucket_doc_variant is Dictionary):
						continue
					var bucket_doc: Dictionary = (bucket_doc_variant as Dictionary).duplicate(true)
					var bucket_doc_id: String = String(bucket_doc.get("doc_id", "")).strip_edges()
					if bucket_doc_id == "":
						bucket_doc_id = "%s_%03d" % [key, i]
					bucket_doc["doc_id"] = bucket_doc_id
					if String(bucket_doc.get("doc_type", "")).strip_edges() == "":
						bucket_doc["doc_type"] = key
					docs_by_id[bucket_doc_id] = bucket_doc

	var normalized_ids: Array = docs_by_id.keys()
	normalized_ids.sort()
	for doc_id_variant in normalized_ids:
		var doc_id: String = String(doc_id_variant).strip_edges()
		if doc_id == "":
			continue
		if not docs_by_id.has(doc_id):
			continue
		var doc_variant = docs_by_id[doc_id]
		if not (doc_variant is Dictionary):
			continue
		var doc: Dictionary = doc_variant
		var doc_type: String = String(doc.get("doc_type", "")).strip_edges().to_lower()
		var should_derive_declaration_like: bool = (
			String(doc_id).begins_with("FDOC-")
			or doc_type == "contract"
			or doc_type == "freightdoc"
			or doc_type == "freight_doc"
			or doc_type == "freight_docs"
		)
		if not should_derive_declaration_like:
			continue
		var declaration_like_id: String = "%s__declaration_like" % doc_id
		if docs_by_id.has(declaration_like_id):
			continue
		var declaration_like_doc: Dictionary = doc.duplicate(true)
		declaration_like_doc["doc_id"] = declaration_like_id
		declaration_like_doc["doc_type"] = "purchase_order"
		declaration_like_doc["derived_from_doc_id"] = doc_id
		docs_by_id[declaration_like_id] = declaration_like_doc

	return docs_by_id


func run_level_2_audit(context: Dictionary = {}) -> Dictionary:
	var normalized_context: Dictionary = context.duplicate(true)
	if String(normalized_context.get("system_id", "")).strip_edges() == "":
		normalized_context["system_id"] = GameState.current_system_id
	if String(normalized_context.get("location_id", "")).strip_edges() == "":
		var current_location_id: String = String(GameState.current_location_id).strip_edges()
		if current_location_id != "":
			normalized_context["location_id"] = current_location_id
	if String(normalized_context.get("action", "")).strip_edges() == "":
		normalized_context["action"] = "UNKNOWN_ACTION"
	var docs_variant = normalized_context.get("docs", null)
	if docs_variant == null:
		var chain_snapshot: Dictionary = GameState.get_freightdoc_chain_snapshot()
		docs_variant = chain_snapshot.get("docs", {})
		if not normalized_context.has("tick"):
			normalized_context["tick"] = int(chain_snapshot.get("tick", GameState.time_tick))
	elif not normalized_context.has("tick"):
		normalized_context["tick"] = int(GameState.time_tick)

	normalized_context["docs"] = _normalize_level2_docs_for_audit(docs_variant)
	if not normalized_context.has("cargo"):
		normalized_context["cargo"] = GameState.cargo.duplicate(true)
	return CustomsLevel2Audit.build_level2_audit(normalized_context)


func _evaluate_cross_document_invariants(
	inspection_ctx: Dictionary = {},
	precomputed_audit: Dictionary = {}
) -> Array:
	var audit: Dictionary = precomputed_audit
	if audit.is_empty():
		audit = run_level_2_audit(inspection_ctx)
	var findings_variant = audit.get("findings", [])
	if not (findings_variant is Array):
		return []
	var findings: Array = []
	for finding_variant in findings_variant:
		if not (finding_variant is Dictionary):
			continue
		findings.append((finding_variant as Dictionary).duplicate(true))
	return findings


func evaluate_level2_cross_document_invariants(
	inspection_ctx: Dictionary = {},
	precomputed_audit: Dictionary = {}
) -> Array:
	return _evaluate_cross_document_invariants(inspection_ctx, precomputed_audit)


func run_sale_check(system_id: String, location_id: String) -> void:
	if system_id == "" or location_id == "":
		return
	if Galaxy.get_system(system_id).is_empty():
		return
	if Galaxy.get_location(location_id).is_empty():
		return

	var bucket: String = GameState.get_customs_pressure_bucket(location_id)
	var chance: float = float(inspection_chance.get(bucket, 0.3))
	if not GameState.roll_customs_inspection(system_id, location_id, "SELL_CARGO_LEGAL", chance):
		return

	var max_depth: int = _resolve_inspection_max_depth(system_id, location_id)

	var report: Dictionary = GameState.run_customs_inspection({
		"system_id": system_id,
		"location_id": location_id,
		"action": "SELL_CARGO_LEGAL",
		"max_depth": max_depth,
	})
	_log_inspection("Sale", system_id, location_id, report)

func run_departure_check(system_id: String, location_id: String) -> void:
	if system_id == "" or location_id == "":
		return
	if Galaxy.get_system(system_id).is_empty():
		return
	if Galaxy.get_location(location_id).is_empty():
		return

	var bucket: String = GameState.get_customs_pressure_bucket(location_id)
	var chance: float = float(inspection_chance.get(bucket, 0.3))
	if not GameState.roll_customs_inspection(system_id, location_id, "PORT_DEPARTURE_CLEARANCE", chance):
		return

	var max_depth: int = _resolve_inspection_max_depth(system_id, location_id)

	var report: Dictionary = GameState.run_customs_inspection({
		"system_id": system_id,
		"location_id": location_id,
		"action": "PORT_DEPARTURE_CLEARANCE",
		"max_depth": max_depth,
	})
	_log_inspection("Departure clearance", system_id, location_id, report)

func run_entry_check(system_id: String, location_id: String = "") -> void:
	var system: Dictionary = Galaxy.get_system(system_id)
	if system.is_empty():
		return
	location_id = GameState.get_entry_customs_location_id(system_id)
	if location_id == "":
		return

	var bucket: String = GameState.get_customs_pressure_bucket(location_id)
	var chance: float = float(inspection_chance.get(bucket, 0.3))

	# roll inspection 
	if not GameState.roll_customs_inspection(system_id, location_id, "ENTRY_CLEARANCE", chance):
		return  # no customs check this time

	var max_depth: int = _resolve_inspection_max_depth(system_id, location_id)

	var report: Dictionary = GameState.run_customs_inspection({
		"system_id": system_id,
		"location_id": location_id,
		"action": "ENTRY_CLEARANCE",
		"max_depth": max_depth,
	})
	_log_inspection("Entry clearance", system_id, location_id, report)
