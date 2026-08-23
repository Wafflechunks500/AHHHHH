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
	personality.set_value(key, value)

func get_personality_value(key: String, fallback: float = 0.5) -> float:
	initialize()
	return personality.get_value(key, fallback)

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
		"personality": personality.to_dictionary(),
		"appearance": appearance.get_appearance_state(),
		"biography": biography.get_biographical_state()
	}

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
	print("Personality: ", personality.to_dictionary())
	print("========================================")
