class_name CharacterPersonality
extends Resource


# ============================================================
# CHARACTER PERSONALITY
#
# Personality describes relatively stable characteristics of
# the individual.
#
# It is NOT the character's current emotional state.
#
# Example:
#
#     Personality:
#         confidence = 0.75
#         empathy = 0.85
#         curiosity = 0.70
#
#     Current emotion:
#         anxiety = 0.65
#
# The character can therefore be a generally confident person
# who is currently nervous.
#
# Personality should influence:
#
#     - emotional responses
#     - interpretation of events
#     - social behavior
#     - risk taking
#     - curiosity
#     - decision making
#     - relationships
#     - romantic behavior
#     - sexual preferences
#
# Personality should NOT directly determine behavior.
#
# The brain will eventually combine personality with:
#
#     Physiology
#     Emotion
#     Perception
#     Memory
#     Relationships
#     Goals
#     Preferences
#
# to decide what the character actually does.
# ============================================================


# ============================================================
# CORE PERSONALITY TRAITS
#
# These are normalized from 0.0 to 1.0.
#
# 0.0 = very low
# 1.0 = very high
# ============================================================


## General belief in one's own ability.
@export_range(0.0, 1.0)
var confidence: float = 0.60


## Tendency to understand and care about other people's
## emotional states.
@export_range(0.0, 1.0)
var empathy: float = 0.70


## Willingness to take initiative and impose one's preferences.
@export_range(0.0, 1.0)
var assertiveness: float = 0.50


## Tendency to investigate unfamiliar things.
@export_range(0.0, 1.0)
var curiosity: float = 0.65


## Willingness to accept unfamiliar ideas and experiences.
@export_range(0.0, 1.0)
var openness: float = 0.65


## Desire for social interaction.
@export_range(0.0, 1.0)
var sociability: float = 0.55


## Tendency to avoid danger and uncertainty.
@export_range(0.0, 1.0)
var caution: float = 0.45


## Tendency to experience emotions strongly.
@export_range(0.0, 1.0)
var emotional_sensitivity: float = 0.60


## Tendency to act quickly rather than carefully considering
## consequences.
@export_range(0.0, 1.0)
var impulsiveness: float = 0.40


## Tendency to joke, tease, play, and engage in lighthearted
## behavior.
@export_range(0.0, 1.0)
var playfulness: float = 0.65


## Preference for making decisions independently.
@export_range(0.0, 1.0)
var independence: float = 0.55


## Importance placed on approval from other people.
@export_range(0.0, 1.0)
var need_for_approval: float = 0.40


## Ability to recover emotionally after setbacks.
@export_range(0.0, 1.0)
var emotional_resilience: float = 0.60


## Tendency to be patient rather than immediately seeking
## results.
@export_range(0.0, 1.0)
var patience: float = 0.55


## Tendency to become emotionally attached to people.
@export_range(0.0, 1.0)
var attachment_tendency: float = 0.60


# ============================================================
# SOCIAL PERSONALITY
# ============================================================

## How easily the character trusts people.
@export_range(0.0, 1.0)
var trustfulness: float = 0.50


## How easily the character becomes suspicious.
@export_range(0.0, 1.0)
var suspiciousness: float = 0.30


## Tendency to seek reassurance from others.
@export_range(0.0, 1.0)
var reassurance_seeking: float = 0.35


## Tendency to take responsibility for other people's
## emotional wellbeing.
@export_range(0.0, 1.0)
var caretaking: float = 0.65


## How comfortable the character is expressing vulnerability.
@export_range(0.0, 1.0)
var vulnerability_comfort: float = 0.50


## How comfortable the character is initiating interactions.
@export_range(0.0, 1.0)
var social_initiative: float = 0.55


# ============================================================
# EMOTIONAL RESPONSE TENDENCIES
#
# These don't represent current emotions.
#
# They describe how strongly personality tends to influence
# emotional reactions.
# ============================================================


## How strongly the character reacts to perceived rejection.
@export_range(0.0, 1.0)
var rejection_sensitivity: float = 0.40


## How strongly the character reacts to criticism.
@export_range(0.0, 1.0)
var criticism_sensitivity: float = 0.35


## How easily the character becomes embarrassed.
@export_range(0.0, 1.0)
var embarrassment_proneness: float = 0.35


## How strongly the character responds to positive attention.
@export_range(0.0, 1.0)
var praise_sensitivity: float = 0.50


## How strongly the character seeks emotionally intense
## experiences.
@export_range(0.0, 1.0)
var intensity_seeking: float = 0.45


## How easily the character becomes overwhelmed.
@export_range(0.0, 1.0)
var overwhelm_sensitivity: float = 0.40


# ============================================================
# CONFLICT / STRESS RESPONSE
# ============================================================

## Tendency to confront problems directly.
@export_range(0.0, 1.0)
var confrontation: float = 0.50


## Tendency to avoid uncomfortable situations.
@export_range(0.0, 1.0)
var avoidance: float = 0.35


## Tendency to become defensive when threatened.
@export_range(0.0, 1.0)
var defensiveness: float = 0.30


## Tendency to seek help when struggling.
@export_range(0.0, 1.0)
var help_seeking: float = 0.45


# ============================================================
# BEHAVIORAL TENDENCIES
#
# These are not commands.
#
# They are preferences that the decision system can consider.
# ============================================================


## Preference for taking action quickly.
@export_range(0.0, 1.0)
var action_bias: float = 0.45


## Preference for planning before acting.
@export_range(0.0, 1.0)
var planning_tendency: float = 0.55


## Preference for familiar situations.
@export_range(0.0, 1.0)
var familiarity_preference: float = 0.40


## Desire for novelty and new experiences.
@export_range(0.0, 1.0)
var novelty_seeking: float = 0.65


## Tendency to maintain routines.
@export_range(0.0, 1.0)
var routine_preference: float = 0.35


# ============================================================
# PERSONALITY LABELS
#
# These are descriptive rather than mechanically important.
#
# They are useful for debugging, UI, and eventually dialogue.
# ============================================================

var personality_tags: Array[String] = [
	"curious",
	"empathetic",
	"playful"
]


# ============================================================
# PERSONALITY DESCRIPTION
#
# Optional human-readable information about the character.
#
# This is NOT used as the actual decision-making mechanism.
# The numerical traits above are.
# ============================================================

@export_multiline
var description: String = """
A curious and empathetic person who enjoys discovering
new things and connecting with others.
"""


# ============================================================
# TRAIT ACCESS
#
# Allows other systems to request a personality trait without
# knowing how the personality system stores it.
# ============================================================

func get_trait(trait_name: String) -> float:

	match trait_name:

		"confidence":
			return confidence

		"empathy":
			return empathy

		"assertiveness":
			return assertiveness

		"curiosity":
			return curiosity

		"openness":
			return openness

		"sociability":
			return sociability

		"caution":
			return caution

		"emotional_sensitivity":
			return emotional_sensitivity

		"impulsiveness":
			return impulsiveness

		"playfulness":
			return playfulness

		"independence":
			return independence

		"need_for_approval":
			return need_for_approval

		"emotional_resilience":
			return emotional_resilience

		"patience":
			return patience

		"attachment_tendency":
			return attachment_tendency

		"trustfulness":
			return trustfulness

		"suspiciousness":
			return suspiciousness

		"reassurance_seeking":
			return reassurance_seeking

		"caretaking":
			return caretaking

		"vulnerability_comfort":
			return vulnerability_comfort

		"social_initiative":
			return social_initiative

		"rejection_sensitivity":
			return rejection_sensitivity

		"criticism_sensitivity":
			return criticism_sensitivity

		"embarrassment_proneness":
			return embarrassment_proneness

		"praise_sensitivity":
			return praise_sensitivity

		"intensity_seeking":
			return intensity_seeking

		"overwhelm_sensitivity":
			return overwhelm_sensitivity

		"confrontation":
			return confrontation

		"avoidance":
			return avoidance

		"defensiveness":
			return defensiveness

		"help_seeking":
			return help_seeking

		"action_bias":
			return action_bias

		"planning_tendency":
			return planning_tendency

		"familiarity_preference":
			return familiarity_preference

		"novelty_seeking":
			return novelty_seeking

		"routine_preference":
			return routine_preference


	return 0.0


# ============================================================
# SET TRAIT
#
# Primarily useful for character creation, debugging, and
# eventually personality development.
# ============================================================

func set_trait(
	trait_name: String,
	value: float
) -> void:

	value = clamp(
		value,
		0.0,
		1.0
	)


	match trait_name:

		"confidence":
			confidence = value

		"empathy":
			empathy = value

		"assertiveness":
			assertiveness = value

		"curiosity":
			curiosity = value

		"openness":
			openness = value

		"sociability":
			sociability = value

		"caution":
			caution = value

		"emotional_sensitivity":
			emotional_sensitivity = value

		"impulsiveness":
			impulsiveness = value

		"playfulness":
			playfulness = value

		"independence":
			independence = value

		"need_for_approval":
			need_for_approval = value

		"emotional_resilience":
			emotional_resilience = value

		"patience":
			patience = value

		"attachment_tendency":
			attachment_tendency = value

		"trustfulness":
			trustfulness = value

		"suspiciousness":
			suspiciousness = value

		"reassurance_seeking":
			reassurance_seeking = value

		"caretaking":
			caretaking = value

		"vulnerability_comfort":
			vulnerability_comfort = value

		"social_initiative":
			social_initiative = value

		"rejection_sensitivity":
			rejection_sensitivity = value

		"criticism_sensitivity":
			criticism_sensitivity = value

		"embarrassment_proneness":
			embarrassment_proneness = value

		"praise_sensitivity":
			praise_sensitivity = value

		"intensity_seeking":
			intensity_seeking = value

		"overwhelm_sensitivity":
			overwhelm_sensitivity = value

		"confrontation":
			confrontation = value

		"avoidance":
			avoidance = value

		"defensiveness":
			defensiveness = value

		"help_seeking":
			help_seeking = value

		"action_bias":
			action_bias = value

		"planning_tendency":
			planning_tendency = value

		"familiarity_preference":
			familiarity_preference = value

		"novelty_seeking":
			novelty_seeking = value

		"routine_preference":
			routine_preference = value


# ============================================================
# PERSONALITY-BASED MODIFIERS
#
# These functions are where personality starts becoming useful
# to the rest of the brain.
#
# They don't make decisions themselves.
# They simply answer questions about tendencies.
# ============================================================


## Returns how strongly the character tends to react to a
## stressful situation.

func get_stress_reactivity() -> float:

	var sensitivity := (
		emotional_sensitivity * 0.35
		+ overwhelm_sensitivity * 0.25
		+ rejection_sensitivity * 0.15
		+ criticism_sensitivity * 0.10
		+ (1.0 - emotional_resilience) * 0.15
	)

	return clamp(
		sensitivity,
		0.0,
		1.0
	)


## Returns how likely the character is to approach something
## unfamiliar.

func get_exploration_drive() -> float:

	var exploration := (
		curiosity * 0.30
		+ openness * 0.25
		+ novelty_seeking * 0.25
		+ impulsiveness * 0.10
		+ (1.0 - caution) * 0.10
	)

	return clamp(
		exploration,
		0.0,
		1.0
	)


## Returns how socially motivated the character tends to be.

func get_social_drive() -> float:

	var social := (
		sociability * 0.35
		+ attachment_tendency * 0.20
		+ social_initiative * 0.20
		+ empathy * 0.10
		+ (1.0 - independence) * 0.15
	)

	return clamp(
		social,
		0.0,
		1.0
	)


## Returns how likely the character is to take initiative.

func get_initiative() -> float:

	var initiative := (
		assertiveness * 0.30
		+ confidence * 0.25
		+ social_initiative * 0.15
		+ action_bias * 0.15
		+ impulsiveness * 0.05
		+ (1.0 - caution) * 0.10
	)

	return clamp(
		initiative,
		0.0,
		1.0
	)


## Returns how likely the character is to avoid a situation.

func get_avoidance_drive() -> float:

	var avoidance_drive := (
		avoidance * 0.30
		+ caution * 0.20
		+ anxiety_modifier() * 0.20
		+ rejection_sensitivity * 0.15
		+ overwhelm_sensitivity * 0.15
	)

	return clamp(
		avoidance_drive,
		0.0,
		1.0
	)


## A personality-based tendency toward anxiety.
##
## This is NOT current anxiety.
##
## Current anxiety belongs to emotion.gd.

func anxiety_modifier() -> float:

	var anxiety_tendency := (
		rejection_sensitivity * 0.25
		+ criticism_sensitivity * 0.15
		+ overwhelm_sensitivity * 0.20
		+ need_for_approval * 0.15
		+ suspiciousness * 0.10
		+ (1.0 - confidence) * 0.15
	)

	return clamp(
		anxiety_tendency,
		0.0,
		1.0
	)


# ============================================================
# SOCIAL RESPONSE STYLE
#
# Returns a rough tendency describing how the character
# generally responds when interacting with another person.
#
# This does NOT mean the character will always behave this way.
# ============================================================

func get_social_response_style() -> String:

	var initiative := get_initiative()

	var avoidance_drive := get_avoidance_drive()


	if initiative > 0.70:

		if playfulness > 0.65:
			return "playful_initiator"

		return "confident_initiator"


	if avoidance_drive > 0.70:

		if reassurance_seeking > 0.60:
			return "reassurance_seeking"

		return "withdrawn"


	if empathy > 0.75 and caretaking > 0.65:

		return "caretaking"


	if playfulness > 0.70:

		return "playful"


	if sociability < 0.30:

		return "reserved"


	return "balanced"


# ============================================================
# PERSONALITY DEVELOPMENT
#
# Personality is relatively stable.
#
# These functions allow tiny long-term changes.
#
# IMPORTANT:
#
# A single event should NOT radically change someone's
# personality.
#
# Personality development should happen gradually through
# repeated experiences.
# ============================================================

func develop_trait(
	trait_name: String,
	amount: float
) -> void:

	var current := get_trait(
		trait_name
	)

	if current == 0.0 and not is_valid_trait(trait_name):

		push_warning(
			"Cannot develop unknown trait: "
			+ trait_name
		)

		return


	set_trait(
		trait_name,
		current + amount
	)


func is_valid_trait(
	trait_name: String
) -> bool:

	var valid_traits := [

		"confidence",
		"empathy",
		"assertiveness",
		"curiosity",
		"openness",
		"sociability",
		"caution",
		"emotional_sensitivity",
		"impulsiveness",
		"playfulness",
		"independence",
		"need_for_approval",
		"emotional_resilience",
		"patience",
		"attachment_tendency",
		"trustfulness",
		"suspiciousness",
		"reassurance_seeking",
		"caretaking",
		"vulnerability_comfort",
		"social_initiative",
		"rejection_sensitivity",
		"criticism_sensitivity",
		"embarrassment_proneness",
		"praise_sensitivity",
		"intensity_seeking",
		"overwhelm_sensitivity",
		"confrontation",
		"avoidance",
		"defensiveness",
		"help_seeking",
		"action_bias",
		"planning_tendency",
		"familiarity_preference",
		"novelty_seeking",
		"routine_preference"
	]

	return trait_name in valid_traits


# ============================================================
# DEBUG SUMMARY
# ============================================================

func get_summary() -> String:

	return (

		"Confidence: %.2f | "

		+ "Empathy: %.2f | "

		+ "Assertiveness: %.2f | "

		+ "Curiosity: %.2f | "

		+ "Openness: %.2f | "

		+ "Sociability: %.2f | "

		+ "Caution: %.2f | "

		+ "Playfulness: %.2f | "

		+ "Resilience: %.2f"

	) % [

		confidence,

		empathy,

		assertiveness,

		curiosity,

		openness,

		sociability,

		caution,

		playfulness,

		emotional_resilience
	]


# ============================================================
# CHARACTER PROFILE
# ============================================================

func get_profile() -> String:

	return (

		"PERSONALITY PROFILE\n"

		+ "-------------------\n"

		+ "Social style: %s\n"

		+ "Exploration drive: %.2f\n"

		+ "Social drive: %.2f\n"

		+ "Initiative: %.2f\n"

		+ "Avoidance drive: %.2f\n"

		+ "Stress reactivity: %.2f\n"

		+ "Anxiety tendency: %.2f\n"

		+ "Tags: %s"

	) % [

		get_social_response_style(),

		get_exploration_drive(),

		get_social_drive(),

		get_initiative(),

		get_avoidance_drive(),

		get_stress_reactivity(),

		anxiety_modifier(),

		", ".join(personality_tags)
	]
