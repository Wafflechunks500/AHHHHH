class_name CharacterAttention
extends Resource


# ============================================================
# CHARACTER ATTENTION
#
# Attention determines what the character focuses on.
#
# Perception answers:
#
#     "What is happening around me?"
#
# Attention answers:
#
#     "What should I pay attention to?"
#
# It does NOT make decisions.
#
# It simply determines what information deserves processing.
# ============================================================


# ============================================================
# ATTENTION TARGET
# ============================================================

## The thing currently receiving the most attention.

var current_target: String = ""


## Category of the current target.
##
## Examples:
##
##     person
##     object
##     event
##     environment
##     internal_need

var current_target_type: String = ""


## Current attention strength.
##
## 0.0 = barely noticed
## 1.0 = extremely focused

@export_range(0.0, 1.0)
var current_attention: float = 0.0


# ============================================================
# INTERNAL STATE
# ============================================================

## General ability to concentrate.

@export_range(0.0, 1.0)
var concentration: float = 0.75


## How easily attention is pulled toward new stimuli.

@export_range(0.0, 1.0)
var distractibility: float = 0.30


## How strongly emotionally important things capture
## attention.

@export_range(0.0, 1.0)
var emotional_sensitivity: float = 0.70


## How strongly novel or unusual things capture attention.

@export_range(0.0, 1.0)
var novelty_sensitivity: float = 0.65


# ============================================================
# ATTENTION TARGETS
# ============================================================

var targets: Array[Dictionary] = []


# ============================================================
# ADD TARGET
# ============================================================

func add_target(
	target_name: String,
	target_type: String,
	salience: float,
	emotional_importance: float = 0.0,
	novelty: float = 0.0,
	urgency: float = 0.0
) -> void:

	var target := {
		"name": target_name,
		"type": target_type,
		"salience": clamp(salience, 0.0, 1.0),
		"emotional_importance": clamp(
			emotional_importance,
			0.0,
			1.0
		),
		"novelty": clamp(
			novelty,
			0.0,
			1.0
		),
		"urgency": clamp(
			urgency,
			0.0,
			1.0
		)
	}

	targets.append(target)


# ============================================================
# CALCULATE ATTENTION
# ============================================================

func calculate_attention(target: Dictionary) -> float:

	var salience: float = target.get(
		"salience",
		0.0
	)

	var emotional_importance: float = target.get(
		"emotional_importance",
		0.0
	)

	var novelty: float = target.get(
		"novelty",
		0.0
	)

	var urgency: float = target.get(
		"urgency",
		0.0
	)


	# --------------------------------------------------------
	# Base attention comes from how noticeable something is.
	# --------------------------------------------------------

	var score := salience * 0.30


	# --------------------------------------------------------
	# Emotional importance.
	# --------------------------------------------------------

	score += (
		emotional_importance
		* emotional_sensitivity
		* 0.25
	)


	# --------------------------------------------------------
	# Novelty.
	# --------------------------------------------------------

	score += (
		novelty
		* novelty_sensitivity
		* 0.20
	)


	# --------------------------------------------------------
	# Urgency.
	#
	# Urgent things can override normal attention priorities.
	# --------------------------------------------------------

	score += (
		urgency
		* 0.25
	)


	# --------------------------------------------------------
	# Concentration modifies how effectively attention can
	# remain focused.
	# --------------------------------------------------------

	score *= concentration


	# --------------------------------------------------------
	# Distractibility makes competing stimuli more influential.
	#
	# We don't simply subtract distractibility because a
	# distractible character can still become intensely focused
	# on something highly stimulating.
	# --------------------------------------------------------

	score += (
		novelty
		* distractibility
		* 0.10
	)


	return clamp(
		score,
		0.0,
		1.0
	)


# ============================================================
# SELECT TARGET
# ============================================================

func select_target() -> void:

	if targets.is_empty():

		current_target = ""

		current_target_type = ""

		current_attention = 0.0

		return


	var best_score := -1.0

	var best_target: Dictionary = {}


	for target in targets:

		var score := calculate_attention(
			target
		)

		if score > best_score:

			best_score = score

			best_target = target


	if not best_target.is_empty():

		current_target = best_target.get(
			"name",
			""
		)

		current_target_type = best_target.get(
			"type",
			""
		)

		current_attention = best_score


# ============================================================
# CLEAR TARGETS
# ============================================================

func clear_targets() -> void:

	targets.clear()


# ============================================================
# REMOVE TARGET
# ============================================================

func remove_target(
	target_name: String
) -> void:

	for i in range(targets.size() - 1, -1, -1):

		if targets[i].get("name", "") == target_name:

			targets.remove_at(i)


# ============================================================
# UPDATE
# ============================================================

func update(delta: float) -> void:

	# Attention gradually relaxes when there is no strong
	# stimulus.

	if current_attention > 0.0:

		current_attention = move_toward(
			current_attention,
			0.0,
			delta * 0.01
		)


# ============================================================
# INFORMATION FOR THE BRAIN
# ============================================================

func has_attention() -> bool:

	return current_target != ""


func get_attention_target() -> String:

	return current_target


func get_attention_strength() -> float:

	return current_attention


# ============================================================
# DEBUG SUMMARY
# ============================================================

func get_summary() -> String:

	return (

		"Current target: %s | "

		+ "Type: %s | "

		+ "Attention: %.2f | "

		+ "Concentration: %.2f | "

		+ "Distractibility: %.2f | "

		+ "Emotional sensitivity: %.2f | "

		+ "Novelty sensitivity: %.2f | "

		+ "Targets: %d"

	) % [

		current_target,

		current_target_type,

		current_attention,

		concentration,

		distractibility,

		emotional_sensitivity,

		novelty_sensitivity,

		targets.size()
	]
