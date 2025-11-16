# res://data/CommodityDB.gd
extends Node

# Simple structured commodity database.
# You can later export this from JSON or CSV if you want.

const COMMODITIES: Dictionary = {
	"ore_iron": {
		"id": "ore_iron",
		"name": "Iron Ore",
		"category": "raw",
		"base_price": 50.0,
		"weight_per_unit": 1.0,
		"producer_types": ["mining"],
		"consumer_types": ["industrial"]
	},
	"ore_copper": {
		"id": "ore_copper",
		"name": "Copper Ore",
		"category": "raw",
		"base_price": 60.0,
		"weight_per_unit": 1.0,
		"producer_types": ["mining"],
		"consumer_types": ["industrial"]
	},
	"ore_palladium": {
		"id": "ore_palladium",
		"name": "Palladium Ore",
		"category": "raw_rare",
		"base_price": 500.0,
		"weight_per_unit": 1.0,
		"producer_types": ["mining"],
		"consumer_types": ["industrial"]
	},
	"ore_rare_earths": {
		"id": "ore_rare_earths",
		"name": "Rare Earth Ore",
		"category": "raw_rare",
		"base_price": 400.0,
		"weight_per_unit": 1.0,
		"producer_types": ["mining"],
		"consumer_types": ["industrial"]
	},
	"ice_industrial": {
		"id": "ice_industrial",
		"name": "Industrial Ice",
		"category": "raw",
		"base_price": 40.0,
		"weight_per_unit": 1.0,
		"producer_types": ["mining"],
		"consumer_types": ["industrial", "agri"]
	},
	"fuel_unrefined": {
		"id": "fuel_unrefined",
		"name": "Unrefined Fuel",
		"category": "raw",
		"base_price": 70.0,
		"weight_per_unit": 1.0,
		"producer_types": ["mining"],
		"consumer_types": ["industrial"]
	},
	"scrap_metal": {
		"id": "scrap_metal",
		"name": "Scrap Metal",
		"category": "raw_recycled",
		"base_price": 30.0,
		"weight_per_unit": 1.0,
		"producer_types": ["mining", "industrial"],
		"consumer_types": ["industrial"]
	},
	"grain_bulk": {
		"id": "grain_bulk",
		"name": "Bulk Grain",
		"category": "food_bulk",
		"base_price": 45.0,
		"weight_per_unit": 1.0,
		"producer_types": ["agri"],
		"consumer_types": ["industrial", "mining"]
	},
	"protein_meal": {
		"id": "protein_meal",
		"name": "Protein Meal",
		"category": "food_processed",
		"base_price": 60.0,
		"weight_per_unit": 1.0,
		"producer_types": ["agri"],
		"consumer_types": ["mining", "industrial"]
	},
	"fresh_produce": {
		"id": "fresh_produce",
		"name": "Fresh Produce",
		"category": "food_fresh",
		"base_price": 80.0,
		"weight_per_unit": 1.0,
		"producer_types": ["agri"],
		"consumer_types": ["industrial", "mining"]
	},
	"livestock_small": {
		"id": "livestock_small",
		"name": "Livestock Crates",
		"category": "livestock",
		"base_price": 120.0,
		"weight_per_unit": 2.0,
		"producer_types": ["agri"],
		"consumer_types": ["industrial", "mining"]
	},
	"textiles_basic": {
		"id": "textiles_basic",
		"name": "Basic Textiles",
		"category": "consumer",
		"base_price": 90.0,
		"weight_per_unit": 1.0,
		"producer_types": ["agri"],
		"consumer_types": ["industrial", "mining"]
	},
	"water_purified": {
		"id": "water_purified",
		"name": "Purified Water",
		"category": "utility",
		"base_price": 35.0,
		"weight_per_unit": 1.0,
		"producer_types": ["agri", "mining"],
		"consumer_types": ["industrial", "mining"]
	},
	"stimulant_leaf": {
		"id": "stimulant_leaf",
		"name": "Stimulant Leaf",
		"category": "stimulant",
		"base_price": 150.0,
		"weight_per_unit": 0.5,
		"producer_types": ["agri"],
		"consumer_types": ["industrial", "luxury"]
	},
	"alloys_struct": {
		"id": "alloys_struct",
		"name": "Structural Alloys",
		"category": "manufactured",
		"base_price": 200.0,
		"weight_per_unit": 1.0,
		"producer_types": ["industrial"],
		"consumer_types": ["mining", "agri"]
	},
	"machine_parts": {
		"id": "machine_parts",
		"name": "Machine Parts",
		"category": "manufactured",
		"base_price": 220.0,
		"weight_per_unit": 1.0,
		"producer_types": ["industrial"],
		"consumer_types": ["mining", "agri"]
	},
	"electronics_cons": {
		"id": "electronics_cons",
		"name": "Consumer Electronics",
		"category": "manufactured",
		"base_price": 260.0,
		"weight_per_unit": 0.5,
		"producer_types": ["industrial"],
		"consumer_types": ["mining", "agri", "industrial"]
	},
	"med_supplies": {
		"id": "med_supplies",
		"name": "Medical Supplies",
		"category": "medical",
		"base_price": 240.0,
		"weight_per_unit": 0.5,
		"producer_types": ["industrial"],
		"consumer_types": ["mining", "agri", "industrial"]
	},
	"chem_industrial": {
		"id": "chem_industrial",
		"name": "Industrial Chemicals",
		"category": "chemical",
		"base_price": 190.0,
		"weight_per_unit": 1.0,
		"producer_types": ["industrial"],
		"consumer_types": ["mining", "agri"]
	},
	"constr_materials": {
		"id": "constr_materials",
		"name": "Construction Materials",
		"category": "manufactured",
		"base_price": 150.0,
		"weight_per_unit": 2.0,
		"producer_types": ["industrial"],
		"consumer_types": ["mining", "agri"]
	},
	"luxury_foods": {
		"id": "luxury_foods",
		"name": "Luxury Foods",
		"category": "luxury",
		"base_price": 350.0,
		"weight_per_unit": 0.5,
		"producer_types": ["industrial", "agri"],
		"consumer_types": ["industrial"]
	},
	"fine_liquor": {
		"id": "fine_liquor",
		"name": "Fine Liquor",
		"category": "luxury",
		"base_price": 320.0,
		"weight_per_unit": 0.5,
		"producer_types": ["agri"],
		"consumer_types": ["industrial", "luxury"]
	},
	"art_objects": {
		"id": "art_objects",
		"name": "Art Objects",
		"category": "luxury",
		"base_price": 600.0,
		"weight_per_unit": 0.5,
		"producer_types": ["industrial"],
		"consumer_types": ["luxury"]
	},
	"narcotics_illicit": {
		"id": "narcotics_illicit",
		"name": "Illicit Narcotics",
		"category": "illicit",
		"base_price": 800.0,
		"weight_per_unit": 0.5,
		"producer_types": ["agri", "industrial"],
		"consumer_types": ["luxury"]
	}
}

static func get_all_ids() -> Array:
	return COMMODITIES.keys()

static func get_commodity(id: String) -> Dictionary:
	return COMMODITIES.get(id, null)
