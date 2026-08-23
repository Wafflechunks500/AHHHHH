class_name CharacterPresets
extends RefCounted

const PERSONALITY_KEYS := [
	"confidence", "empathy", "assertiveness", "curiosity", "openness",
	"sociability", "caution", "playfulness", "resilience", "patience",
	"independence", "romanticism", "jealousy", "spontaneity"
]

static func names() -> Array[String]:
	return ["Balanced", "Loving Partner", "Shy", "Playful", "Confident", "Dominant"]

static func apply_preset(character: CharacterDefinition, preset_name: String) -> void:
	var values := preset_values(preset_name)
	for key in values:
		character.set_personality(key, values[key])

static func preset_values(preset_name: String) -> Dictionary:
	var values := {}
	for key in PERSONALITY_KEYS:
		values[key] = 0.5

	match preset_name:
		"Loving Partner":
			values.merge({
				"confidence": 0.55, "empathy": 0.90, "assertiveness": 0.45,
				"sociability": 0.65, "playfulness": 0.70, "patience": 0.75,
				"romanticism": 0.95, "affection": 0.90, "commitment": 0.90
			})
		"Shy":
			values.merge({
				"confidence": 0.30, "empathy": 0.70, "assertiveness": 0.25,
				"sociability": 0.25, "caution": 0.80, "patience": 0.65,
				"romanticism": 0.65, "social_initiative": 0.25
			})
		"Playful":
			values.merge({
				"confidence": 0.65, "sociability": 0.75, "playfulness": 0.95,
				"spontaneity": 0.85, "curiosity": 0.75, "openness": 0.80
			})
		"Confident":
			values.merge({
				"confidence": 0.90, "assertiveness": 0.80, "sociability": 0.75,
				"caution": 0.25, "independence": 0.75, "social_initiative": 0.85
			})
		"Dominant":
			values.merge({
				"confidence": 0.85, "assertiveness": 0.95, "sociability": 0.65,
				"patience": 0.60, "independence": 0.80, "playfulness": 0.65,
				"social_initiative": 0.90
			})

	return values
