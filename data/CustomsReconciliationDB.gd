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
