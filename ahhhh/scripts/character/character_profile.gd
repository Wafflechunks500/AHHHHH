class_name CharacterProfile
extends Resource

# Persistent definition of who a character is.
# Current emotion, thought, motivation, perception, memory state and decisions
# belong to the brain, not this profile.

@export var biography: CharacterBiography
@export var appearance: CharacterAppearance
@export var personality: CharacterPersonality
@export var preferences: CharacterPreferences
@export var character_id: String = "character_01"
@export var profile_version: int = 1
@export_multiline var profile_description: String = ""
@export var archetype: String = "Balanced"

func initialize() -> void:
	if biography == null:
		biography = CharacterBiography.new()
	if appearance == null:
		appearance = CharacterAppearance.new()
	if personality == null:
		personality = CharacterPersonality.new()
	if preferences == null:
		preferences = CharacterPreferences.new()

func get_character_name() -> String:
	initialize()
	return biography.get_display_name()

func get_full_name() -> String:
	initialize()
	return biography.get_full_name()

func get_id() -> String:
	return character_id

func get_age() -> int:
	initialize()
	return biography.age

func get_biography() -> CharacterBiography:
	initialize()
	return biography

func get_appearance() -> CharacterAppearance:
	initialize()
	return appearance

func get_personality() -> CharacterPersonality:
	initialize()
	return personality

func get_preferences() -> CharacterPreferences:
	initialize()
	return preferences

func set_personality(key: String, value: float) -> void:
	initialize()
	personality.set_trait(key, value)

func get_personality_value(key: String, fallback: float = 0.5) -> float:
	initialize()
	var value := personality.get_trait(key)
	# CharacterPersonality returns 0.0 for an unknown trait. Preserve the
	# profile API's fallback behavior for callers that request an unsupported key.
	if value == 0.0 and not _personality_has_trait(key):
		return fallback
	return value

func _personality_has_trait(key: String) -> bool:
	return key in [
		"confidence", "empathy", "assertiveness", "curiosity", "openness",
		"sociability", "caution", "emotional_sensitivity", "impulsiveness",
		"playfulness", "independence", "need_for_approval", "emotional_resilience",
		"patience", "attachment_tendency", "trustfulness", "suspiciousness",
		"reassurance_seeking", "caretaking", "vulnerability_comfort",
		"social_initiative", "rejection_sensitivity", "criticism_sensitivity",
		"embarrassment_proneness", "praise_sensitivity", "intensity_seeking",
		"overwhelm_sensitivity", "confrontation", "avoidance", "defensiveness",
		"help_seeking", "action_bias", "planning_tendency", "familiarity_preference",
		"novelty_seeking", "routine_preference"
	]

func get_profile_state() -> Dictionary:
	initialize()
	return {
		"character_id": character_id,
		"profile_version": profile_version,
		"archetype": archetype,
		"identity": {
			"name": biography.get_display_name(),
			"full_name": biography.get_full_name(),
			"age": biography.age,
			"birthplace": biography.birthplace,
			"hometown": biography.hometown,
			"occupation": biography.occupation
		},
		"personality": _personality_state(),
		"appearance": appearance.get_appearance_state(),
		"biography": biography.get_biographical_state()
	}

func _personality_state() -> Dictionary:
	var result := {}
	for key in [
		"confidence", "empathy", "assertiveness", "curiosity", "openness",
		"sociability", "caution", "emotional_sensitivity", "impulsiveness",
		"playfulness", "independence", "need_for_approval", "emotional_resilience",
		"patience", "attachment_tendency", "trustfulness", "suspiciousness",
		"reassurance_seeking", "caretaking", "vulnerability_comfort",
		"social_initiative", "rejection_sensitivity", "criticism_sensitivity",
		"embarrassment_proneness", "praise_sensitivity", "intensity_seeking",
		"overwhelm_sensitivity", "confrontation", "avoidance", "defensiveness",
		"help_seeking", "action_bias", "planning_tendency", "familiarity_preference",
		"novelty_seeking", "routine_preference"
	]:
		result[key] = personality.get_trait(key)
	return result

func get_identity_description() -> String:
	initialize()
	var result := biography.get_display_name()
	if biography.age > 0:
		result += ", %d years old" % biography.age
	if biography.occupation != "":
		result += ", " + biography.occupation
	return result

func get_character_description() -> String:
	initialize()
	var result := get_identity_description()
	if biography.life_summary != "":
		result += "\n\n" + biography.life_summary
	var appearance_text := appearance.get_full_appearance_description()
	if appearance_text != "":
		result += "\n\n" + appearance_text
	return result

func get_summary() -> String:
	initialize()
	return "Character: %s | ID: %s | Age: %d | Archetype: %s" % [biography.get_display_name(), character_id, biography.age, archetype]

func print_state() -> void:
	initialize()
	print("========================================")
	print("CHARACTER PROFILE")
	print("========================================")
	print("Character ID: ", character_id)
	print("Name: ", biography.get_display_name())
	print("Age: ", biography.age)
	print("Archetype: ", archetype)
	print("Personality: ", _personality_state())
	print("========================================")
