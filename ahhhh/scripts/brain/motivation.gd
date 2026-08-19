class_name CharacterMotivation
extends Resource


# ============================================================
# CHARACTER MOTIVATION
#
# Motivation represents the forces currently pushing the
# character toward or away from different outcomes.
#
# Motivation is NOT the same thing as a goal.
#
# Motivation:
#     "I want to feel safe."
#
# Goal:
#     "I should move away from the threatening person."
#
# Motivation is also NOT the same thing as a decision.
#
# Motivation:
#     "I want to talk to them."
#
# Decision:
#     "I will walk over and talk to them."
#
# The decision_maker will eventually convert motivations
# into actual decisions.
# ============================================================


# ============================================================
# CORE MOTIVATIONS
# ============================================================

## Desire to remain physically safe.

@export_range(0.0, 1.0)
var safety: float = 0.30


## Desire for physical comfort.

@export_range(0.0, 1.0)
var comfort: float = 0.25


## Desire to satisfy biological needs.

@export_range(0.0, 1.0)
var biological_need: float = 0.20


## Desire to reduce stress and negative emotional states.

@export_range(0.0, 1.0)
var stress_relief: float = 0.20


## Desire to interact with other people.

@export_range(0.0, 1.0)
var social_connection: float = 0.35


## Desire to understand or discover things.

@export_range(0.0, 1.0)
var curiosity: float = 0.45


## Desire to experience enjoyable things.

@export_range(0.0, 1.0)
var pleasure: float = 0.30


## Desire for independence and control over one's own
## circumstances.

@export_range(0.0, 1.0)
var autonomy: float = 0.35


## Desire to accomplish meaningful objectives.

@export_range(0.0, 1.0)
var achievement: float = 0.25


## Desire to protect or help other people.

@export_range(0.0, 1.0)
var care_for_others: float = 0.30


# ============================================================
# SOCIAL / RELATIONSHIP MOTIVATION
# ============================================================

## Desire to form or strengthen emotional bonds.

@export_range(0.0, 1.0)
var attachment: float = 0.30


## Desire for acceptance and positive social feedback.

@export_range(0.0, 1.0)
var acceptance: float = 0.30


## Desire for intimacy and closeness.
##
## This is intentionally broad.
##
## Later this can interact with the relationship system and
## the character's personal preferences.

@export_range(0.0, 1.0)
var intimacy: float = 0.20


# ============================================================
# CURRENT MOTIVATION STATE
# ============================================================

## The strongest current motivation.

var dominant_motivation: String = ""


## Strength of the dominant motivation.

@export_range(0.0, 1.0)
var dominant_strength: float = 0.0


## How strongly the character is currently driven overall.

@export_range(0.0, 1.0)
var overall_drive: float = 0.35


# ============================================================
# MOTIVATION SOURCES
#
# These are temporary influences that can be applied by other
# brain systems.
# ============================================================

var external_influences: Array[Dictionary] = []


# ============================================================
# ADD EXTERNAL INFLUENCE
# ============================================================

func add_influence(
	motivation: String,
	strength: float,
	source: String = ""
) -> void:

	var influence := {

		"motivation": motivation,

		"strength": clamp(
			strength,
			-1.0,
			1.0
		),

		"source": source
	}


	external_influences.append(
		influence
	)


# ============================================================
# CLEAR EXTERNAL INFLUENCES
# ============================================================

func clear_influences() -> void:

	external_influences.clear()


# ============================================================
# GET BASE MOTIVATION
# ============================================================

func get_base_motivation(
	name: String
) -> float:

	match name:

		"safety":
			return safety

		"comfort":
			return comfort

		"biological_need":
			return biological_need

		"stress_relief":
			return stress_relief

		"social_connection":
			return social_connection

		"curiosity":
			return curiosity

		"pleasure":
			return pleasure

		"autonomy":
			return autonomy

		"achievement":
			return achievement

		"care_for_others":
			return care_for_others

		"attachment":
			return attachment

		"acceptance":
			return acceptance

		"intimacy":
			return intimacy


	return 0.0


# ============================================================
# GET MOTIVATION WITH INFLUENCES
# ============================================================

func get_motivation(
	name: String
) -> float:

	var value := get_base_motivation(
		name
	)


	for influence in external_influences:

		if influence.get(
			"motivation",
			""
		) == name:

			value += influence.get(
				"strength",
				0.0
			)


	return clamp(
		value,
		0.0,
		1.0
	)


# ============================================================
# UPDATE DOMINANT MOTIVATION
# ============================================================

func update_dominant_motivation() -> void:

	var motivation_names := [

		"safety",
		"comfort",
		"biological_need",
		"stress_relief",
		"social_connection",
		"curiosity",
		"pleasure",
		"autonomy",
		"achievement",
		"care_for_others",
		"attachment",
		"acceptance",
		"intimacy"
	]


	var best_name := ""

	var best_strength := -1.0


	for name in motivation_names:

		var strength := get_motivation(
			name
		)


		if strength > best_strength:

			best_strength = strength

			best_name = name


	dominant_motivation = best_name

	dominant_strength = clamp(
		best_strength,
		0.0,
		1.0
	)


	# --------------------------------------------------------
	# Calculate overall drive.
	#
	# This is not simply the strongest motivation.
	# Several simultaneous motivations can make the character
	# more internally driven.
	# --------------------------------------------------------

	var total := 0.0

	var count := 0


	for name in motivation_names:

		total += get_motivation(
			name
		)

		count += 1


	if count > 0:

		overall_drive = clamp(
			total / float(count),
			0.0,
			1.0
		)


# ============================================================
# UPDATE
# ============================================================

func update(delta: float) -> void:

	# --------------------------------------------------------
	# Temporary influences decay over time.
	# --------------------------------------------------------

	for i in range(
		external_influences.size() - 1,
		-1,
		-1
	):

		var influence: Dictionary = (
			external_influences[i]
		)


		var strength: float = influence.get(
			"strength",
			0.0
		)


		strength = move_toward(
			strength,
			0.0,
			delta * 0.01
		)


		influence["strength"] = strength


		# Remove negligible influences.

		if abs(strength) < 0.001:

			external_influences.remove_at(i)


	update_dominant_motivation()


# ============================================================
# FORCE A MOTIVATION
#
# Useful for external events.
#
# Example:
#
#     motivation.push_motivation(
#         "safety",
#         0.8,
#         "threat_detected"
#     )
# ============================================================

func push_motivation(
	name: String,
	strength: float,
	source: String = ""
) -> void:

	add_influence(
		name,
		strength,
		source
	)

	update_dominant_motivation()


# ============================================================
# INFORMATION FOR THE BRAIN
# ============================================================

func get_dominant_motivation() -> String:

	return dominant_motivation


func get_dominant_strength() -> float:

	return dominant_strength


func get_overall_drive() -> float:

	return overall_drive


# ============================================================
# DEBUG SUMMARY
# ============================================================

func get_summary() -> String:

	return (

		"Dominant: %s | "

		+ "Strength: %.2f | "

		+ "Overall drive: %.2f | "

		+ "Safety: %.2f | "

		+ "Comfort: %.2f | "

		+ "Biological need: %.2f | "

		+ "Stress relief: %.2f | "

		+ "Social: %.2f | "

		+ "Curiosity: %.2f | "

		+ "Pleasure: %.2f | "

		+ "Autonomy: %.2f | "

		+ "Achievement: %.2f | "

		+ "Care: %.2f | "

		+ "Attachment: %.2f | "

		+ "Acceptance: %.2f | "

		+ "Intimacy: %.2f"

	) % [

		dominant_motivation,

		dominant_strength,

		overall_drive,

		get_motivation("safety"),

		get_motivation("comfort"),

		get_motivation("biological_need"),

		get_motivation("stress_relief"),

		get_motivation("social_connection"),

		get_motivation("curiosity"),

		get_motivation("pleasure"),

		get_motivation("autonomy"),

		get_motivation("achievement"),

		get_motivation("care_for_others"),

		get_motivation("attachment"),

		get_motivation("acceptance"),

		get_motivation("intimacy")
	]
