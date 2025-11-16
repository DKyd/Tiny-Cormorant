extends Node

# chance of customs inspection by security level
var inspection_chance := {
	"low": 0.5,
	"medium": 0.3,
	"high": 0.1,
}

# per-doc base processing fee (can tune later)
var base_fee_per_doc: float = 50.0


func run_entry_check(system_id: String) -> void:
	
	var system: Dictionary = Galaxy.get_system(system_id)
	if system.is_empty():
		return

	var sec: String = system.get("security_level", "medium")
	var chance: float = float(inspection_chance.get(sec, 0.3))

	# roll inspection
	if randf() > chance:
		return  # no customs check this time

	var docs: Array = GameState.get_docs_for_destination(system_id)
	if docs.is_empty():
		# You arrived with no destination docs; later this could matter.
		Log.add("Customs at %s briefly reviews your ship but finds no active freight docs." % system.get("name", system_id))
		return

	var num_docs: int = docs.size()

	#the below only Log entries only occur when fee > 0 cr which only happens when the random chance for a customs check returns true
	#this means that the only time a customs fee is levied is when there is a customs check on system entry at desitnation

	var total_fee: float = base_fee_per_doc * float(num_docs)

	if total_fee > 0.0:
		var fee_paid: float = min(GameState.player_money, total_fee)
		GameState.player_money -= fee_paid

		if fee_paid > 0.0:
			Log.add("Customs at %s processed %d freight document(s), charging %.0f cr in fees."
				% [system.get("name", system_id), num_docs, fee_paid])
		else:
			Log.add("Customs at %s attempted to levy fees, but you lacked funds."
				% system.get("name", system_id))
	else:
		Log.add("Customs at %s reviews your freight documents and waves you through."
			% system.get("name", system_id))
