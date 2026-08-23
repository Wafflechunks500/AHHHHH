class_name CharacterPersonality
extends Resource

# Persistent personality tendencies. These describe who the character tends to be,
# not what the character is feeling or doing right now.

@export_range(0.0, 1.0) var confidence: float = 0.5
@export_range(0.0, 1.0) var empathy: float = 0.5
@export_range(0.0, 1.0) var assertiveness: float = 0.5
@export_range(0.0, 1.0) var curiosity: float = 0.5
@export_range(0.0, 1.0) var openness: float = 0.5
@export_range(0.0, 1.0) var sociability: float = 0.5
@export_range(0.0, 1.0) var caution: float = 0.5
@export_range(0.0, 1.0) var playfulness: float = 0.5
@export_range(0.0, 1.0) var resilience: float = 0.5
@export_range(0.0, 1.0) var patience: float = 0.5
@export_range(0.0, 1.0) var independence: float = 0.5
@export_range(0.0, 1.0) var romanticism: float = 0.5
@export_range(0.0, 1.0) var jealousy: float = 0.3
@export_range(0.0, 1.0) var spontaneity: float = 0.5

func set_value(key: String, value: float) -> void:
	if not _has_property(key):
		return
	set(key, clampf(value, 0.0, 1.0))

func get_value(key: String, fallback: float = 0.5) -> float:
	if not _has_property(key):
		return fallback
	return float(get(key))

func _has_property(key: String) -> bool:
	return key in [
		"confidence", "empathy", "assertiveness", "curiosity", "openness",
		"sociability", "caution", "playfulness", "resilience", "patience",
		"independence", "romanticism", "jealousy", "spontaneity"
	]

func to_dictionary() -> Dictionary:
	var result := {}
	for key in [
		"confidence", "empathy", "assertiveness", "curiosity", "openness",
		"sociability", "caution", "playfulness", "resilience", "patience",
		"independence", "romanticism", "jealousy", "spontaneity"
	]:
		result[key] = get_value(key)
	return result
