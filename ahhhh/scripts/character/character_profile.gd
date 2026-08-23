class_name CharacterProfile
extends Resource


# ============================================================
# CHARACTER PROFILE
#
# Represents the persistent definition of a character.
#
# The profile brings the character's relatively stable
# identity information together:
#
#     Biography
#     Appearance
#     Preferences
#
# Other persistent character systems can eventually be added
# here as the project grows.
#
# IMPORTANT:
#
# This is NOT the character's brain.
#
# The brain contains changing internal state such as:
#
#     Emotion
#     Physiology
#     Perception
#     Memory
#     Motivation
#     Goals
#     Decision making
#     Learning
#
# The profile describes WHO the character is.
#
# ============================================================


# ============================================================
# CHARACTER RESOURCES
# ============================================================

## Persistent personal history.

@export var biography: CharacterBiography


## Physical appearance and visual presentation.

@export var appearance: CharacterAppearance


## Persistent preferences, romantic preferences, sexual
## preferences, boundaries, and enduring tastes.

@export var preferences: CharacterPreferences


# ============================================================
# PROFILE METADATA
# ============================================================

## Internal identifier for this character.
##
## This should remain unique within a multi-character scene.

@export var character_id: String = "character_01"


## Optional internal version number for the character profile.

@export var profile_version: int = 1


## Optional description of the character as a whole.

@export_multiline
var profile_description: String = ""


# ============================================================
# INITIALIZATION
# ============================================================

## Creates missing character resources.
##
## This makes the profile safe to instantiate even when some
## resources have not yet been assigned in the Inspector.

func initialize() -> void:

	if biography == null:
		biography = CharacterBiography.new()

	if appearance == null:
		appearance = CharacterAppearance.new()

	if preferences == null:
		preferences = CharacterPreferences.new()


# ============================================================
# IDENTITY
# ============================================================

## Returns the character's preferred display name.

func get_character_name() -> String:

	initialize()

	return biography.get_display_name()


## Returns the character's complete name.

func get_full_name() -> String:

	initialize()

	return biography.get_full_name()


## Returns the character's unique identifier.

func get_id() -> String:

	return character_id


## Returns the character's age.

func get_age() -> int:

	initialize()

	return biography.age


# ============================================================
# PROFILE ACCESS
# ============================================================

func get_biography() -> CharacterBiography:

	initialize()

	return biography


func get_appearance() -> CharacterAppearance:

	initialize()

	return appearance


func get_preferences() -> CharacterPreferences:

	initialize()

	return preferences


# ============================================================
# CHARACTER DESCRIPTION
# ============================================================

## Returns a concise description of the character's identity.

func get_identity_description() -> String:

	initialize()

	var result := ""

	var name := biography.get_display_name()

	if name != "":
		result += name

	if biography.age > 0:

		if result != "":
			result += ", "

		result += "%d years old" % biography.age

	if biography.occupation != "":

		if result != "":
			result += ", "

		result += biography.occupation

	return result


## Returns a broader description combining the character's
## persistent identity, appearance, and preferences.

func get_character_description() -> String:

	initialize()

	var result := ""

	var identity := get_identity_description()

	if identity != "":
		result += identity

	var biography_text := biography.life_summary

	if biography_text != "":
		if result != "":
			result += "\n\n"

		result += biography_text

	var appearance_text := appearance.get_full_appearance_description()

	if appearance_text != "":
		if result != "":
			result += "\n\n"

		result += appearance_text

	return result


# ============================================================
# CHARACTER STATE FOR OTHER SYSTEMS
# ============================================================

## Returns the persistent character information in a single
## dictionary.
##
## This is useful when another system needs character identity
## without directly manipulating the underlying resources.

func get_profile_state() -> Dictionary:

	initialize()

	return {
		"character_id": character_id,
		"profile_version": profile_version,

		"identity": {
			"name": biography.get_display_name(),
			"full_name": biography.get_full_name(),
			"age": biography.age,
			"birthplace": biography.birthplace,
			"hometown": biography.hometown,
			"occupation": biography.occupation
		},

		"appearance": appearance.get_appearance_state(),

		"biography": biography.get_biographical_state(),

		"preferences": {
			"romantic_style": preferences.romantic_style,
			"sexual_drive_baseline":
				preferences.sexual_drive_baseline,
			"preferred_intensity":
				preferences.preferred_intensity,
			"preferred_pace":
				preferences.preferred_pace,
			"dominance_interest":
				preferences.dominance_interest,
			"submission_interest":
				preferences.submission_interest,
			"switching_interest":
				preferences.switching_interest
		}
	}


# ============================================================
# PREFERENCE ACCESS
# ============================================================

## Check whether a particular sexual/romantic interest exists
## in the character's persistent preference model.

func has_interest(
	act_id: String
) -> bool:

	initialize()

	return preferences.get_interest(act_id).size() > 0


## Get a specific interest from the preference model.

func get_interest(
	act_id: String
) -> Dictionary:

	initialize()

	return preferences.get_interest(act_id)


## Check whether something is a hard limit.

func is_hard_limit(
	act_id: String
) -> bool:

	initialize()

	return preferences.is_hard_limit(act_id)


## Get the character's personal meaning for an interest.

func get_personal_meaning(
	act_id: String
) -> String:

	initialize()

	return preferences.get_personal_meaning(act_id)


# ============================================================
# APPEARANCE ACCESS
# ============================================================

## Returns the character's current physical appearance.

func get_physical_description() -> String:

	initialize()

	return appearance.get_physical_description()


## Returns the character's current outfit.

func get_outfit_description() -> String:

	initialize()

	return appearance.get_outfit_description()


## Returns the character's complete current visual
## presentation.

func get_appearance_description() -> String:

	initialize()

	return appearance.get_full_appearance_description()


# ============================================================
# BIOGRAPHICAL ACCESS
# ============================================================

## Returns the character's persistent life context.

func get_biographical_description() -> String:

	initialize()

	return biography.get_context_description()


# ============================================================
# PROFILE SUMMARY
# ============================================================

func get_summary() -> String:

	initialize()

	return (
		"Character: %s | " +
		"ID: %s | " +
		"Age: %d | " +
		"Occupation: %s | " +
		"Appearance: %s"
	) % [
		biography.get_display_name(),
		character_id,
		biography.age,
		biography.occupation,
		appearance.fashion_style
	]


# ============================================================
# DEBUG
# ============================================================

func print_state() -> void:

	initialize()

	print("========================================")
	print("CHARACTER PROFILE")
	print("========================================")

	print("Character ID: ", character_id)
	print("Profile version: ", profile_version)

	print("")
	print("IDENTITY")
	print("Name: ", biography.get_display_name())
	print("Full name: ", biography.get_full_name())
	print("Age: ", biography.age)

	print("")
	print("BIOGRAPHY")
	print(biography.get_context_description())

	print("")
	print("APPEARANCE")
	print(appearance.get_full_appearance_description())

	print("")
	print("PREFERENCES")
	print(preferences.get_summary())

	print("========================================")
