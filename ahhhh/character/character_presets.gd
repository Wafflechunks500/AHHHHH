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
	var preset := preset_values(preset_name)
	for key in preset.get("personality", {}):
		character.set_personality(key, preset.personality[key])
	for key in preset.get("relationship_preferences", {}):
		character.relationship_preferences[key] = clampf(preset.relationship_preferences[key], 0.0, 1.0)

static func preset_values(preset_name: String) -> Dictionary:
	var personality := {}
	for key in PERSONALITY_KEYS:
		personality[key] = 0.5

	var relationships := {
		"affection": 0.5,
		"commitment": 0.5,
		"romance": 0.5,
		"social_initiative": 0.5
	}

	match preset_name:
		"Loving Partner":
			personality.merge({
				"confidence": 0.55, "empathy": 0.90, "assertiveness": 0.45,
				"sociability": 0.65, "playfulness": 0.70, "patience": 0.75,
				"romanticism": 0.95
			})
			relationships.merge({
				"affection": 0.90, "commitment": 0.90,
				"romance": 0.95, "social_initiative": 0.60
			})
		"Shy":
			personality.merge({
				"confidence": 0.30, "empathy": 0.70, "assertiveness": 0.25,
				"sociability": 0.25, "caution": 0.80, "patience": 0.65,
				"romanticism": 0.65
			})
			relationships.merge({"affection": 0.65, "commitment": 0.55, "romance": 0.70, "social_initiative": 0.20})
		"Playful":
			personality.merge({
				"confidence": 0.65, "sociability": 0.75, "playfulness": 0.95,
				"spontaneity": 0.85, "curiosity": 0.75, "openness": 0.80
			})
			relationships.merge({"affection": 0.65, "commitment": 0.45, "romance": 0.65, "social_initiative": 0.80})
		"Confident":
			personality.merge({
				"confidence": 0.90, "assertiveness": 0.80, "sociability": 0.75,
				"caution": 0.25, "independence": 0.75
			})
			relationships["social_initiative"] = 0.85
		"Dominant":
			personality.merge({
				"confidence": 0.85, "assertiveness": 0.95, "sociability": 0.65,
				"patience": 0.60, "independence": 0.80, "playfulness": 0.65
			})
			relationships.merge({"affection": 0.55, "commitment": 0.50, "romance": 0.55, "social_initiative": 0.90})

	return {
		"personality": personality,
		"relationship_preferences": relationships
	}
