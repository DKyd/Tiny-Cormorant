#C res://singletons/Customs.gd
extends Node

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
	if not normalized_context.has("docs"):
		var chain_snapshot: Dictionary = GameState.get_freightdoc_chain_snapshot()
		normalized_context["docs"] = chain_snapshot.get("docs", {})
		if not normalized_context.has("tick"):
			normalized_context["tick"] = int(chain_snapshot.get("tick", GameState.time_tick))
	elif not normalized_context.has("tick"):
		normalized_context["tick"] = int(GameState.time_tick)
	return GameState.run_level2_customs_audit(normalized_context)


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

	var preview: Dictionary = GameState.get_inspection_preview({
		"system_id": system_id,
		"location_id": location_id,
	})
	var max_depth: int = int(preview.get("max_depth", 1))
	if not bool(preview.get("ok", false)):
		max_depth = 1
	max_depth = clamp(max_depth, 0, 2)

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

	var preview: Dictionary = GameState.get_inspection_preview({
		"system_id": system_id,
		"location_id": location_id,
	})
	var max_depth: int = int(preview.get("max_depth", 1))
	if not bool(preview.get("ok", false)):
		max_depth = 1
	max_depth = clamp(max_depth, 0, 2)

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

	var preview: Dictionary = GameState.get_inspection_preview({
		"system_id": system_id,
		"location_id": location_id,
	})
	var max_depth: int = int(preview.get("max_depth", 1))
	if not bool(preview.get("ok", false)):
		max_depth = 1
	max_depth = clamp(max_depth, 0, 2)

	var report: Dictionary = GameState.run_customs_inspection({
		"system_id": system_id,
		"location_id": location_id,
		"action": "ENTRY_CLEARANCE",
		"max_depth": max_depth,
	})
	_log_inspection("Entry clearance", system_id, location_id, report)
