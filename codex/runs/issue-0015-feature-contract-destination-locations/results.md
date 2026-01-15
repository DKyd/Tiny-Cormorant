# Results: feature-0015-contract-destination-locations

## Summary
- Ensured newly generated contracts include destination location fields by selecting a destination location during contract generation.
- Repaired active contracts that lack destination location fields on accept and load using a deterministic, system-stable selection.

## Files Changed
- singletons/Contracts.gd: choose a destination location for generated contracts and include destination_location_id/name in new contract dictionaries.
- singletons/GameState.gd: repair missing destination_location_id/name deterministically when contracts are accepted or loaded from saves.

## Assumptions
- Galaxy.get_location_ids_for_system returns a stable set of IDs that can be sorted for deterministic selection.
- Contract IDs are stable across saves and loads.

## Known Limitations / TODOs
- Repair logs once per contract; large legacy saves may still emit multiple repair messages.
- If a destination system has no locations, contracts are skipped during generation and repairs log a failure.
