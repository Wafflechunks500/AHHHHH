class_name CharacterSelfModel
extends Resource


# ============================================================
# CHARACTER SELF MODEL
#
# Represents the character's internal model of herself.
#
# IMPORTANT:
#
# Character data describes what is objectively true about the
# character.
#
# Self-model describes what the character BELIEVES about
# herself.
#
# Example:
#
# Character data:
#     confidence = 0.60
#
# Self-model:
#     "I am reasonably confident."
#
# These do not necessarily have to agree.
#
# Experiences, memories, relationships, and learning can
# gradually change the self-model.
# ============================================================


# ============================================================
# CORE SELF-PERCEPTION
# ============================================================

## How positively the character currently views herself.
##
## 0.0 = strongly negative self-image
## 1.0 = strongly positive self-image

@export_range(0.0, 1.0)
var self_worth: float = 0.60


## How capable the character believes she is.
##
## This is NOT necessarily her actual capability.

@export_range(0.0, 1.0)
var perceived_competence: float = 0.60


## How confident the character believes she is.

@export_range(0.0, 1.0)
var perceived_confidence: float = 0.60


## How much control the character believes she has
## over her circumstances.

@export_range(0.0, 1.0)
var perceived_control: float = 0.60


## How strongly the character feels that she has a stable
## sense of identity.

@export_range(0.0, 1.0)
var identity_stability: float = 0.75


# ============================================================
# SOCIAL SELF-PERCEPTION
# ============================================================

## How socially capable the character believes she is.

@export_range(0.0, 1.0)
var perceived_social_skill: float = 0.60


## How much the character believes other people generally
## like her.

@export_range(0.0, 1.0)
var perceived_social_acceptance: float = 0.55


## How comfortable the character believes she is around
## other people.

@export_range(0.0, 1.0)
var perceived_social_comfort: float = 0.60


## How much the character believes she deserves affection
## and positive treatment.

@export_range(0.0, 1.0)
var perceived_lovability: float = 0.60


# ============================================================
# PERSONAL AGENCY
# ============================================================

## How strongly the character believes she can make meaningful
## choices for herself.

@export_range(0.0, 1.0)
var agency: float = 0.70


## How strongly the character believes she can change the
## outcome of a situation.

@export_range(0.0, 1.0)
var efficacy: float = 0.60


## How strongly the character believes she can recover after
## making mistakes.

@export_range(0.0, 1.0)
var perceived_resilience: float = 0.60


# ============================================================
# SELF-KNOWLEDGE
# ============================================================

## How well the character understands her own personality.

@export_range(0.0, 1.0)
var personality_awareness: float = 0.65


## How well the character understands her own emotional
## states.

@export_range(0.0, 1.0)
var emotional_awareness: float = 0.60


## How well the character understands her own motivations.

@export_range(0.0, 1.0)
var motivation_awareness: float = 0.55


## How accurately the character understands her own
## strengths and weaknesses.

@export_range(0.0, 1.0)
var self_knowledge: float = 0.60


# ============================================================
# CURRENT SELF-STATE
# ============================================================

## Current broad description of how the character feels
## about herself.

var current_self_assessment: String = "I feel reasonably confident in myself."


## The most recent thing that significantly changed the
## character's self-perception.

var recent_self_event: String = ""


## How strongly the recent event affected the self-model.

@export_range(0.0, 1.0)
var recent_self_event_strength: float = 0.0


# ============================================================
# SELF-BELIEFS
# ============================================================

## Flexible beliefs the character currently holds about
## herself.
##
## Examples:
##
## "I am good at helping people."
## "I get nervous around strangers."
## "I am attractive."
## "I am bad at confrontation."
##
## These can eventually be created, strengthened, weakened,
## or removed by learning and experience.

var self_beliefs: Array[String] = []


# ============================================================
# IDENTITY TRAITS
# ============================================================

## Traits the character considers important to her identity.
##
## These are not necessarily the same as her personality
## statistics.

var identity_traits: Array[String] = []


# ============================================================
# SELF-MODEL UPDATE
# ============================================================

## Slowly moves the self-model toward a new perception.
##
## rate controls how quickly the belief changes.

func update_self_perception(
	new_worth: float,
	new_competence: float,
	new_confidence: float,
	rate: float = 0.05
) -> void:

	rate = clamp(rate, 0.0, 1.0)

	self_worth = lerp(
		self_worth,
		clamp(new_worth, 0.0, 1.0),
		rate
	)

	perceived_competence = lerp(
		perceived_competence,
		clamp(new_competence, 0.0, 1.0),
		rate
	)

	perceived_confidence = lerp(
		perceived_confidence,
		clamp(new_confidence, 0.0, 1.0),
		rate
	)


# ============================================================
# SELF-EVENTS
# ============================================================

## Apply a positive experience involving the character's
## sense of self.
##
## Examples:
##
## succeeding at something
## receiving praise
## helping someone
## overcoming fear

func apply_positive_self_event(
	description: String,
	strength: float
) -> void:

	strength = clamp(strength, 0.0, 1.0)

	recent_self_event = description
	recent_self_event_strength = strength

	self_worth = clamp(
		self_worth + strength * 0.08,
		0.0,
		1.0
	)

	perceived_competence = clamp(
		perceived_competence + strength * 0.08,
		0.0,
		1.0
	)

	perceived_confidence = clamp(
		perceived_confidence + strength * 0.06,
		0.0,
		1.0
	)


## Apply a negative experience involving the character's
## sense of self.
##
## Examples:
##
## failure
## rejection
## embarrassment
## making a serious mistake

func apply_negative_self_event(
	description: String,
	strength: float
) -> void:

	strength = clamp(strength, 0.0, 1.0)

	recent_self_event = description
	recent_self_event_strength = strength

	self_worth = clamp(
		self_worth - strength * 0.08,
		0.0,
		1.0
	)

	perceived_competence = clamp(
		perceived_competence - strength * 0.08,
		0.0,
		1.0
	)

	perceived_confidence = clamp(
		perceived_confidence - strength * 0.06,
		0.0,
		1.0
	)


# ============================================================
# SELF-BELIEFS
# ============================================================

## Add a belief about the self if it does not already exist.

func add_self_belief(belief: String) -> void:

	if belief.strip_edges() == "":
		return

	if not self_beliefs.has(belief):
		self_beliefs.append(belief)


## Remove a self-belief.

func remove_self_belief(belief: String) -> void:

	self_beliefs.erase(belief)


## Check whether the character currently holds a belief.

func has_self_belief(belief: String) -> bool:

	return self_beliefs.has(belief)


# ============================================================
# IDENTITY
# ============================================================

## Add something the character considers part of her identity.

func add_identity_trait(trait_name: String) -> void:

	if trait_name.strip_edges() == "":
		return

	if not identity_traits.has(trait_name):
		identity_traits.append(trait_name)


## Remove an identity trait.

func remove_identity_trait(trait_name: String) -> void:

	identity_traits.erase(trait_name)


## Check whether something is considered part of the
## character's identity.

func has_identity_trait(trait_name: String) -> bool:

	return identity_traits.has(trait_name)


# ============================================================
# DERIVED VALUES
# ============================================================

## General confidence in the self.

func get_self_confidence() -> float:

	return clamp(
		(
			perceived_confidence * 0.35
			+ perceived_competence * 0.25
			+ self_worth * 0.20
			+ perceived_control * 0.20
		),
		0.0,
		1.0
	)


## General social self-confidence.

func get_social_confidence() -> float:

	return clamp(
		(
			perceived_social_skill * 0.35
			+ perceived_social_acceptance * 0.20
			+ perceived_social_comfort * 0.20
			+ perceived_lovability * 0.15
			+ perceived_confidence * 0.10
		),
		0.0,
		1.0
	)


## How vulnerable the character's self-image currently is.
##
## Higher values mean negative social experiences are more
## likely to affect the self-model.

func get_self_image_vulnerability() -> float:

	return clamp(
		(
			(1.0 - self_worth) * 0.35
			+ (1.0 - identity_stability) * 0.25
			+ (1.0 - perceived_resilience) * 0.25
			+ (1.0 - self_knowledge) * 0.15
		),
		0.0,
		1.0
	)


## How strongly the character believes she can influence
## her circumstances.

func get_agency_strength() -> float:

	return clamp(
		(
			agency * 0.55
			+ efficacy * 0.45
		),
		0.0,
		1.0
	)


# ============================================================
# SELF-ASSESSMENT
# ============================================================

## Returns a simple human-readable description of the current
## self-image.
##
## This is deliberately simple for now.
##
## Later, the language system can turn the underlying values
## into much richer internal thoughts.

func get_self_assessment() -> String:

	var confidence: float = get_self_confidence()

	if self_worth < 0.30:
		return "I don't feel very good about myself."

	if confidence < 0.35:
		return "I don't feel very confident in myself."

	if confidence < 0.50:
		return "I'm somewhat uncertain about myself."

	if confidence < 0.70:
		return "I feel reasonably confident in myself."

	if confidence < 0.85:
		return "I feel confident in myself."

	return "I feel very confident in myself."


# ============================================================
# INFORMATION FOR THE BRAIN
# ============================================================

## Returns the most important self-model information in a
## dictionary so other brain systems can inspect it.

func get_self_state() -> Dictionary:

	return {
		"self_worth": self_worth,
		"perceived_competence": perceived_competence,
		"perceived_confidence": perceived_confidence,
		"perceived_control": perceived_control,
		"identity_stability": identity_stability,
		"perceived_social_skill": perceived_social_skill,
		"perceived_social_acceptance": perceived_social_acceptance,
		"perceived_social_comfort": perceived_social_comfort,
		"perceived_lovability": perceived_lovability,
		"agency": agency,
		"efficacy": efficacy,
		"perceived_resilience": perceived_resilience,
		"personality_awareness": personality_awareness,
		"emotional_awareness": emotional_awareness,
		"motivation_awareness": motivation_awareness,
		"self_knowledge": self_knowledge,
		"self_confidence": get_self_confidence(),
		"social_confidence": get_social_confidence(),
		"self_image_vulnerability": get_self_image_vulnerability(),
		"agency_strength": get_agency_strength(),
		"assessment": get_self_assessment()
	}


# ============================================================
# DEBUG
# ============================================================

func print_state() -> void:

	print("========================================")
	print("SELF MODEL")
	print("========================================")

	print(
		"Self-worth: %.2f | " +
		"Competence: %.2f | " +
		"Confidence: %.2f" %
		[
			self_worth,
			perceived_competence,
			perceived_confidence
		]
	)

	print(
		"Control: %.2f | " +
		"Agency: %.2f | " +
		"Resilience: %.2f" %
		[
			perceived_control,
			agency,
			perceived_resilience
		]
	)

	print(
		"Social skill: %.2f | " +
		"Social acceptance: %.2f | " +
		"Lovability: %.2f" %
		[
			perceived_social_skill,
			perceived_social_acceptance,
			perceived_lovability
		]
	)

	print(
		"Self-knowledge: %.2f | " +
		"Emotional awareness: %.2f | " +
		"Motivation awareness: %.2f" %
		[
			self_knowledge,
			emotional_awareness,
			motivation_awareness
		]
	)

	print(
		"Self-confidence: %.2f | " +
		"Social confidence: %.2f | " +
		"Vulnerability: %.2f" %
		[
			get_self_confidence(),
			get_social_confidence(),
			get_self_image_vulnerability()
		]
	)

	print("Assessment: ", get_self_assessment())

	print("Identity traits: ", identity_traits)
	print("Self beliefs: ", self_beliefs)

	if recent_self_event != "":
		print(
			"Recent self-event: ",
			recent_self_event,
			" | Strength: ",
			recent_self_event_strength
		)

	print("========================================")
