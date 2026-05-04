# res://data/CustomsReconciliationDB.gd
extends Node

# Inert Level 3 customs reconciliation primitives.
# This file is static data only; runtime readers belong in future jobs.

const DEFAULT_CONTAINER_CLASS_ID: String = "standard_freight_crate"
const DEFAULT_TOLERANCE_POLICY_ID: String = "level3_default"

const CONTAINER_CLASSES: Dictionary = {
	"standard_freight_crate": {
		"class_id": "standard_freight_crate",
		"display_name": "Standard Freight Crate",
		"tare_mass": 1.0,
		"max_cargo_mass": 25.0,
		"notes": "Baseline sealed or unsealed freight container for future Level 3 reconciliation."
	},
	"light_parcel_crate": {
		"class_id": "light_parcel_crate",
		"display_name": "Light Parcel Crate",
		"tare_mass": 0.5,
		"max_cargo_mass": 10.0,
		"notes": "Small container archetype for low-mass cargo declarations."
	},
	"heavy_bulk_container": {
		"class_id": "heavy_bulk_container",
		"display_name": "Heavy Bulk Container",
		"tare_mass": 2.0,
		"max_cargo_mass": 50.0,
		"notes": "Large container archetype for dense or bulk cargo declarations."
	}
}

const RECONCILIATION_TOLERANCE_POLICIES: Dictionary = {
	"level3_default": {
		"policy_id": "level3_default",
		"absolute_mass_tolerance": 0.5,
		"relative_mass_tolerance": 0.05,
		"rounding_decimals": 2,
		"missing_data_result": "not_evaluable",
		"unknown_container_class_result": "not_evaluable",
		"unknown_commodity_mass_result": "not_evaluable"
	}
}

static func get_all_container_class_ids() -> Array:
	return CONTAINER_CLASSES.keys()

static func get_container_class(class_id: String) -> Dictionary:
	var normalized_id: String = class_id.strip_edges()
	if normalized_id == "":
		return {}
	var record_variant = CONTAINER_CLASSES.get(normalized_id, null)
	if not (record_variant is Dictionary):
		return {}
	var record: Dictionary = record_variant
	if String(record.get("class_id", "")).strip_edges() != normalized_id:
		return {}
	return record.duplicate(true)

static func get_default_container_class() -> Dictionary:
	return get_container_class(DEFAULT_CONTAINER_CLASS_ID)

static func get_container_tare_mass(class_id: String, fallback: float = -1.0) -> float:
	var record: Dictionary = get_container_class(class_id)
	if record.is_empty():
		return fallback
	return _get_non_negative_float(record, "tare_mass", fallback)

static func get_container_max_cargo_mass(class_id: String, fallback: float = -1.0) -> float:
	var record: Dictionary = get_container_class(class_id)
	if record.is_empty():
		return fallback
	return _get_non_negative_float(record, "max_cargo_mass", fallback)

static func get_all_tolerance_policy_ids() -> Array:
	return RECONCILIATION_TOLERANCE_POLICIES.keys()

static func get_tolerance_policy(policy_id: String) -> Dictionary:
	var normalized_id: String = policy_id.strip_edges()
	if normalized_id == "":
		return {}
	var record_variant = RECONCILIATION_TOLERANCE_POLICIES.get(normalized_id, null)
	if not (record_variant is Dictionary):
		return {}
	var record: Dictionary = record_variant
	if String(record.get("policy_id", "")).strip_edges() != normalized_id:
		return {}
	return record.duplicate(true)

static func get_default_tolerance_policy() -> Dictionary:
	return get_tolerance_policy(DEFAULT_TOLERANCE_POLICY_ID)

static func _get_non_negative_float(record: Dictionary, field_name: String, fallback: float) -> float:
	var value_variant = record.get(field_name, null)
	if not (value_variant is int or value_variant is float):
		return fallback
	var value: float = float(value_variant)
	if value < 0.0:
		return fallback
	return value
