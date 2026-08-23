class_name CharacterPerception
extends Resource


# ============================================================
# CHARACTER PERCEPTION
#
# Perception represents what the character currently detects
# about the outside world.
#
# IMPORTANT:
#
# Perception is NOT the same as reality.
#
# The character should eventually be able to:
#
#     observe something
#         ↓
#     interpret it
#         ↓
#     form a belief
#
# That means the character can be wrong.
#
# Example:
#
# Observable:
#     Someone is looking away.
#
# Possible interpretations:
#     - nervous
#     - distracted
#     - bored
#     - avoiding eye contact
#     - simply looking at something else
#
# Personality, emotion, memory, and relationships will
# eventually influence which interpretation seems most likely.
# ============================================================


# ============================================================
# CURRENT ENVIRONMENT
# ============================================================

## How crowded the character currently perceives the
## environment to be.
##
## 0.0 = completely empty
## 1.0 = extremely crowded

@export_range(0.0, 1.0)
var crowding: float = 0.0


## How loud the environment currently seems.

@export_range(0.0, 1.0)
var noise_level: float = 0.10


## How visually stimulating the environment is.

@export_range(0.0, 1.0)
var visual_stimulation: float = 0.20


## How familiar the current environment feels.

@export_range(0.0, 1.0)
var environmental_familiarity: float = 0.70


## Whether the character currently perceives the environment
## as generally safe.

@export_range(0.0, 1.0)
var perceived_safety: float = 0.80


# ============================================================
# ATTENTION / SALIENCE
#
# These represent how noticeable something is.
#
# They do NOT determine what the character chooses to focus
# on. That will eventually be handled by attention.gd.
# ============================================================

## General amount of unusual activity currently detected.

@export_range(0.0, 1.0)
var unusual_activity: float = 0.0


## General amount of movement detected.

@export_range(0.0, 1.0)
var movement_activity: float = 0.10


## How strongly something currently stands out.

@export_range(0.0, 1.0)
var environmental_salience: float = 0.10


# ============================================================
# SOCIAL PERCEPTION
#
# These represent observations about another person.
#
# They are deliberately separate from conclusions about
# personality or intentions.
# ============================================================


## Whether another person is currently perceived nearby.

var person_present: bool = false


## Approximate perceived distance from the character.

var person_distance: float = 10.0


## Whether the person is looking toward the character.

var eye_contact: float = 0.0


## Observable body posture.

var observed_posture: String = "neutral"


## Observable movement style.

var observed_movement: String = "still"


## Observable facial expression.

var observed_expression: String = "neutral"


## Observable speech characteristics.

var observed_speech: String = "none"


## Whether the person is currently speaking.

var person_speaking: bool = false


## Whether the person appears to be approaching.

var person_approaching: bool = false


## Whether the person appears to be leaving.

var person_leaving: bool = false


# ============================================================
# SOCIAL OBSERVATION VALUES
#
# These are observations, not personality conclusions.
#
# Example:
#
#     observed_confidence = 0.7
#
# does NOT mean:
#
#     "This person IS confident."
#
# It means:
#
#     "Their observable behavior currently resembles
#      confident behavior."
#
# Later, the character's brain can decide how much it trusts
# that interpretation.
# ============================================================

@export_range(0.0, 1.0)
var observed_confidence: float = 0.50


@export_range(0.0, 1.0)
var observed_nervousness: float = 0.0


@export_range(0.0, 1.0)
var observed_friendliness: float = 0.50


@export_range(0.0, 1.0)
var observed_aggression: float = 0.0


@export_range(0.0, 1.0)
var observed_interest: float = 0.50


# ============================================================
# CURRENTLY PERCEIVED EVENTS
# ============================================================

var current_events: Array[String] = []


# ============================================================
# UPDATE
# ============================================================

func update(delta: float) -> void:

	# --------------------------------------------------------
	# Environmental values naturally settle over time.
	# --------------------------------------------------------

	environmental_salience = move_toward(
		environmental_salience,
		0.10,
		delta * 0.05
	)

	unusual_activity = move_toward(
		unusual_activity,
		0.0,
		delta * 0.02
	)

	movement_activity = move_toward(
		movement_activity,
		0.10,
		delta * 0.02
	)


	# --------------------------------------------------------
	# Temporary events eventually disappear from immediate
	# perception.
	#
	# Long-term memory will handle remembering them.
	# --------------------------------------------------------

	if current_events.size() > 0:

		current_events.clear()


# ============================================================
# ENVIRONMENTAL INPUT
# ============================================================

func perceive_environment(
	new_crowding: float,
	new_noise: float,
	new_visual_stimulation: float,
	new_familiarity: float,
	new_safety: float
) -> void:

	crowding = clamp(
		new_crowding,
		0.0,
		1.0
	)

	noise_level = clamp(
		new_noise,
		0.0,
		1.0
	)

	visual_stimulation = clamp(
		new_visual_stimulation,
		0.0,
		1.0
	)

	environmental_familiarity = clamp(
		new_familiarity,
		0.0,
		1.0
	)

	perceived_safety = clamp(
		new_safety,
		0.0,
		1.0
	)


# ============================================================
# SOCIAL INPUT
# ============================================================

func perceive_person(
	distance: float,
	looking_at_character: float,
	posture: String,
	movement: String,
	expression: String,
	speech: String
) -> void:

	person_present = true

	person_distance = max(
		distance,
		0.0
	)

	eye_contact = clamp(
		looking_at_character,
		0.0,
		1.0
	)

	observed_posture = posture

	observed_movement = movement

	observed_expression = expression

	observed_speech = speech

	person_speaking = speech != "none"

	person_approaching = (
		movement == "approaching"
	)

	person_leaving = (
		movement == "leaving"
	)


# ============================================================
# SOCIAL BEHAVIOR OBSERVATION
#
# This represents the perception system interpreting observable
# behavior into rough estimates.
#
# Again:
#
# These are NOT guaranteed facts.
# ============================================================

func estimate_social_behavior() -> void:

	# --------------------------------------------------------
	# Confidence
	#
	# Confident-looking behavior:
	#
	#     upright posture
	#     steady speech
	#     direct eye contact
	#     deliberate movement
	# --------------------------------------------------------

	var confidence_score := 0.50


	if observed_posture == "upright":
		confidence_score += 0.15

	if observed_posture == "slouched":
		confidence_score -= 0.15

	if observed_movement == "deliberate":
		confidence_score += 0.10

	if observed_movement == "hesitant":
		confidence_score -= 0.10

	confidence_score += (
		eye_contact - 0.5
	) * 0.20


	observed_confidence = clamp(
		confidence_score,
		0.0,
		1.0
	)


	# --------------------------------------------------------
	# Nervousness
	# --------------------------------------------------------

	var nervousness_score := 0.10


	if observed_movement == "hesitant":
		nervousness_score += 0.25

	if observed_posture == "closed":
		nervousness_score += 0.15

	if observed_speech == "hesitant":
		nervousness_score += 0.25

	if eye_contact < 0.25:
		nervousness_score += 0.15


	observed_nervousness = clamp(
		nervousness_score,
		0.0,
		1.0
	)


	# --------------------------------------------------------
	# Friendliness
	# --------------------------------------------------------

	var friendliness_score := 0.50


	if observed_expression == "smiling":
		friendliness_score += 0.25

	if observed_expression == "warm":
		friendliness_score += 0.20

	if observed_expression == "angry":
		friendliness_score -= 0.30

	if observed_posture == "open":
		friendliness_score += 0.10

	if observed_posture == "closed":
		friendliness_score -= 0.10


	observed_friendliness = clamp(
		friendliness_score,
		0.0,
		1.0
	)


	# --------------------------------------------------------
	# Aggression
	# --------------------------------------------------------

	var aggression_score := 0.0


	if observed_expression == "angry":
		aggression_score += 0.40

	if observed_movement == "aggressive":
		aggression_score += 0.40

	if observed_posture == "threatening":
		aggression_score += 0.30


	observed_aggression = clamp(
		aggression_score,
		0.0,
		1.0
	)


	# --------------------------------------------------------
	# Interest
	# --------------------------------------------------------

	var interest_score := 0.50


	if eye_contact > 0.75:
		interest_score += 0.15

	if observed_expression == "smiling":
		interest_score += 0.10

	if person_approaching:
		interest_score += 0.10

	if person_leaving:
		interest_score -= 0.20


	observed_interest = clamp(
		interest_score,
		0.0,
		1.0
	)


# ============================================================
# EVENT PERCEPTION
# ============================================================

func perceive_event(
	event_name: String
) -> void:

	if event_name.is_empty():
		return

	current_events.append(
		event_name
	)

	environmental_salience = max(
		environmental_salience,
		0.70
	)

	unusual_activity = max(
		unusual_activity,
		0.50
	)


# ============================================================
# CLEAR PERSON
# ============================================================

func clear_person() -> void:

	person_present = false

	person_distance = 10.0

	eye_contact = 0.0

	observed_posture = "neutral"

	observed_movement = "still"

	observed_expression = "neutral"

	observed_speech = "none"

	person_speaking = false

	person_approaching = false

	person_leaving = false

	observed_confidence = 0.50

	observed_nervousness = 0.0

	observed_friendliness = 0.50

	observed_aggression = 0.0

	observed_interest = 0.50


# ============================================================
# INFORMATION FOR THE BRAIN
# ============================================================

func get_social_salience() -> float:

	if not person_present:
		return 0.0

	var salience := 0.50


	if person_approaching:
		salience += 0.20

	if person_speaking:
		salience += 0.15

	if eye_contact > 0.75:
		salience += 0.10

	if observed_aggression > 0.50:
		salience += 0.25


	return clamp(
		salience,
		0.0,
		1.0
	)


func get_environmental_stress() -> float:

	var result := (

		noise_level * 0.25

		+ crowding * 0.20

		+ visual_stimulation * 0.10

		+ (1.0 - perceived_safety) * 0.35

		+ (1.0 - environmental_familiarity) * 0.10
	)

	return clamp(
		result,
		0.0,
		1.0
	)


# ============================================================
# DEBUG SUMMARY
# ============================================================

func get_summary() -> String:

	return (

		"Safety: %.2f | "

		+ "Noise: %.2f | "

		+ "Crowding: %.2f | "

		+ "Visual stimulation: %.2f | "

		+ "Salience: %.2f | "

		+ "Person present: %s | "

		+ "Eye contact: %.2f | "

		+ "Observed confidence: %.2f | "

		+ "Observed nervousness: %.2f | "

		+ "Observed friendliness: %.2f | "

		+ "Observed aggression: %.2f | "

		+ "Observed interest: %.2f"

	) % [

		perceived_safety,

		noise_level,

		crowding,

		visual_stimulation,

		environmental_salience,

		str(person_present),

		eye_contact,

		observed_confidence,

		observed_nervousness,

		observed_friendliness,

		observed_aggression,

		observed_interest
	]
