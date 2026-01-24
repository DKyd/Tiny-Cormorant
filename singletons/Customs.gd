extends Node

# chance of customs inspection by pressure bucket
var inspection_chance := {
	"Low": 0.1,
	"Elevated": 0.3,
	"High": 0.5,
}

func run_entry_check(system_id: String, location_id: String = "") -> void:
	var system: Dictionary = Galaxy.get_system(system_id)
	if system.is_empty():
		return
	if location_id == "":
		location_id = GameState.current_location_id
	if location_id == "":
		var location_ids: Array = Galaxy.get_location_ids_for_system(system_id)
		var sorted_ids: Array = []
		for id_variant in location_ids:
			sorted_ids.append(String(id_variant))
		sorted_ids.sort()
		if sorted_ids.is_empty():
			return
		location_id = String(sorted_ids[0])

	var bucket: String = GameState.get_customs_pressure_bucket(location_id)
	var chance: float = float(inspection_chance.get(bucket, 0.3))

	# roll inspection 
	if randf() > chance:
		return  # no customs check this time

	var report: Dictionary = GameState.run_customs_inspection({
		"system_id": system_id,
		"location_id": location_id,
		"action": "ENTRY_CLEARANCE",
	})
	Log.add_entry("Customs at %s inspected your paperwork: %s."
		% [system.get("name", system_id), str(report.get("classification", "unknown"))])

