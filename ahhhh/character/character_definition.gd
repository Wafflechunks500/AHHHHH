class_name CharacterDefinition
extends Resource

@export var character_id: String = ""
@export var display_name: String = "New Character"
@export_range(18, 100, 1) var age: int = 25

# Personality values are normalized to 0.0-1.0.
@export var personality: Dictionary = {
	"confidence": 0.5,
	"empathy": 0.5,
	"assertiveness": 0.5,
	"curiosity": 0.5,
	"openness": 0.5,
	"sociability": 0.5,
	"caution": 0.5,
	"playfulness": 0.5,
	"resilience": 0.5,
	"patience": 0.5,
	"independence": 0.5,
	"romanticism": 0.5,
	"jealousy": 0.3,
	"spontaneity": 0.5
}

# Relationship tendencies. These are not the current relationship state.
@export var relationship_preferences: Dictionary = {
	"affection": 0.5,
	"commitment": 0.5,
	"romance": 0.5,
	"social_initiative": 0.5
}

# Generalized preference values. Detailed categories can be added later.
@export var intimacy_preferences: Dictionary = {}

# Appearance is deliberately asset-independent so the eventual renderer can change.
@export var appearance: Dictionary = {
	"skin_tone": 0.5,
	"height": 0.5,
	"body_build": 0.5,
	"face_id": "default",
	"hair_id": "default",
	"voice_id": "default"
}

@export var background: Dictionary = {
	"occupation": "",
	"education": "",
	"interests": []
}

func duplicate_definition() -> CharacterDefinition:
	var copy := CharacterDefinition.new()
	copy.character_id = character_id
	copy.display_name = display_name
	copy.age = age
	copy.personality = personality.duplicate(true)
	copy.relationship_preferences = relationship_preferences.duplicate(true)
	copy.intimacy_preferences = intimacy_preferences.duplicate(true)
	copy.appearance = appearance.duplicate(true)
	copy.background = background.duplicate(true)
	return copy

func set_personality(name: String, value: float) -> void:
	personality[name] = clampf(value, 0.0, 1.0)

func get_personality(name: String, fallback: float = 0.5) -> float:
	return float(personality.get(name, fallback))
