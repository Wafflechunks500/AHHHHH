class_name CharacterLearning
extends Resource


# ============================================================
# CHARACTER LEARNING
#
# Represents how the character changes as a result of experience.
#
# Learning is intentionally separate from:
#
#     Personality
#     Self Model
#     Memory
#     Goals
#     Decision Making
#
# Memory answers:
#     "What happened?"
#
# Learning answers:
#     "What did I learn from what happened?"
#
# Learning can eventually influence:
#
#     - personality
#     - self-model
#     - expectations
#     - preferences
#     - social interpretation
#     - confidence
#     - future decisions
#     - goal formation
#
# Learning should generally be gradual.
#
# A single experience should not completely redefine the
# character unless its significance is extremely high.
# ============================================================


# ============================================================
# LEARNED BELIEFS
# ============================================================

## General beliefs formed from experience.
##
## These are intentionally separate from self-beliefs.
##
## Example:
##
## "People usually respond positively when I ask for help."
## "This environment is dangerous."
## "Matthew tends to become nervous when..."
##
## The value represents how strongly the character currently
## believes the proposition.

var learned_beliefs: Dictionary = {}


## Confidence in individual learned beliefs.
##
## Key:
##     belief identifier
##
## Value:
##     0.0 - 1.0

var belief_confidence: Dictionary = {}


# ============================================================
# LEARNED ASSOCIATIONS
# ============================================================

## Associations between concepts, actions, people, situations,
## and outcomes.
##
## Example:
##
##     "person_smiles" -> "positive_social_outcome"
##     "dark_room" -> "unsafe"
##
## These associations can become stronger through repetition.

var associations: Dictionary = {}


# ============================================================
# EXPECTATIONS
# ============================================================

## What the character currently expects to happen in different
## situations.
##
## Values represent expected likelihood.

var expectations: Dictionary = {}


# ============================================================
# PREFERENCE LEARNING
# ============================================================

## Things the character has learned she tends to enjoy.

var learned_preferences: Dictionary = {}


## Things the character has learned she tends to dislike.

var learned_dislikes: Dictionary = {}


## Things she is uncertain about and may want to explore.

var learned_uncertainties: Dictionary = {}


# ============================================================
# BEHAVIORAL OUTCOMES
# ============================================================

## Records simplified outcomes of previous decisions.
##
## This allows the learning system to determine whether a
## particular type of action tends to produce desirable or
## undesirable results.

var action_outcomes: Dictionary = {}


# ============================================================
# SOCIAL LEARNING
# ============================================================

## Learned information about particular people.
##
## The relationship system will eventually contain the detailed
## relationship state.
##
## Learning stores conclusions produced from experience.

var social_learning: Dictionary = {}


# ============================================================
# SELF-LEARNING
# ============================================================

## Learned conclusions about the character herself.
##
## These can eventually be passed to CharacterSelfModel.

var self_observations: Dictionary = {}


# ============================================================
# LEARNING RATE
# ============================================================

## Global learning rate.
##
## Higher values mean experiences change learned information
## more quickly.

@export_range(0.0, 1.0)
var learning_rate: float = 0.25


## How resistant the character is to changing an established
## belief.
##
## Higher values make established beliefs harder to change.

@export_range(0.0, 1.0)
var belief_inertia: float = 0.65


# ============================================================
# EXPERIENCE COUNTER
# ============================================================

var total_experiences: int = 0


var successful_experiences: int = 0


var unsuccessful_experiences: int = 0


# ============================================================
# MAIN UPDATE
# ============================================================

## Learning is event-driven rather than continuously changing
## every frame.
##
## delta is accepted so CharacterBrain can update all systems
## through a consistent interface.

func update(delta: float) -> void:

	# Learning itself does not currently decay.
	#
	# Future versions may implement:
	#
	#     belief forgetting
	#     memory decay
	#     preference drift
	#     reinforcement decay
	#
	# Those should be deliberate processes rather than automatic
	# frame-by-frame changes.

	if delta < 0.0:
		return


# ============================================================
# LEARN FROM EXPERIENCE
# ============================================================

## Main learning entry point.
##
## experience should contain whatever information the brain
## currently has about an event.
##
## Expected optional keys include:
##
##     event
##     outcome
##     success
##     significance
##     context
##     action
##     target_id
##     emotional_impact
##     self_relevance
##
## The dictionary is intentionally flexible so additional
## information can be introduced without rewriting the system.

func learn_from_experience(
	experience: Dictionary
) -> void:

	if experience.is_empty():
		return

	total_experiences += 1

	var significance: float = clamp(
		float(experience.get("significance", 0.5)),
		0.0,
		1.0
	)

	var success: float = _extract_success(experience)

	if success > 0.5:
		successful_experiences += 1
	elif success < 0.5:
		unsuccessful_experiences += 1


	_learn_general_belief(
		experience,
		significance
	)

	_learn_association(
		experience,
		significance
	)

	_learn_expectation(
		experience,
		significance,
		success
	)

	_learn_preference(
		experience,
		significance,
		success
	)

	_learn_action_outcome(
		experience,
		significance,
		success
	)

	_learn_social_information(
		experience,
		significance
	)

	_learn_self_information(
		experience,
		significance,
		success
	)


# ============================================================
# GENERAL BELIEFS
# ============================================================

func _learn_general_belief(
	experience: Dictionary,
	significance: float
) -> void:

	var belief: String = str(
		experience.get("belief", "")
	).strip_edges()

	if belief.is_empty():
		return

	var target_confidence: float = clamp(
		float(
			experience.get(
				"belief_confidence",
				0.5
			)
		),
		0.0,
		1.0
	)

	_update_dictionary_value(
		learned_beliefs,
		belief,
		target_confidence,
		significance
	)

	_update_dictionary_value(
		belief_confidence,
		belief,
		target_confidence,
		significance
	)


# ============================================================
# ASSOCIATIONS
# ============================================================

func _learn_association(
	experience: Dictionary,
	significance: float
) -> void:

	var source: String = str(
		experience.get("association_source", "")
	).strip_edges()

	var destination: String = str(
		experience.get("association_target", "")
	).strip_edges()

	if source.is_empty() or destination.is_empty():
		return

	if not associations.has(source):
		associations[source] = {}

	var source_associations: Dictionary = associations[source]

	var current_strength: float = float(
		source_associations.get(
			destination,
			0.0
		)
	)

	var target_strength: float = clamp(
		float(
			experience.get(
				"association_strength",
				1.0
			)
		),
		0.0,
		1.0
	)

	var rate := _effective_learning_rate(
		significance
	)

	source_associations[destination] = lerp(
		current_strength,
		target_strength,
		rate
	)

	associations[source] = source_associations


# ============================================================
# EXPECTATIONS
# ============================================================

func _learn_expectation(
	experience: Dictionary,
	significance: float,
	success: float
) -> void:

	var expectation_key: String = str(
		experience.get("expectation_key", "")
	).strip_edges()

	if expectation_key.is_empty():
		return

	var observed_probability: float = clamp(
		float(
			experience.get(
				"observed_probability",
				success
			)
		),
		0.0,
		1.0
	)

	var current: float = float(
		expectations.get(
			expectation_key,
			0.5
		)
	)

	expectations[expectation_key] = _learn_toward(
		current,
		observed_probability,
		significance
	)


# ============================================================
# PREFERENCE LEARNING
# ============================================================

func _learn_preference(
	experience: Dictionary,
	significance: float,
	success: float
) -> void:

	var preference: String = str(
		experience.get("preference", "")
	).strip_edges()

	if preference.is_empty():
		return

	var enjoyment: float = clamp(
		float(
			experience.get(
				"enjoyment",
				success
			)
		),
		0.0,
		1.0
	)

	var current: float = 0.5

	if learned_preferences.has(preference):
		current = float(
			learned_preferences[preference]
		)
	elif learned_dislikes.has(preference):
		current = 1.0 - float(
			learned_dislikes[preference]
		)

	var updated := _learn_toward(
		current,
		enjoyment,
		significance
	)

	if updated >= 0.6:

		learned_preferences[preference] = updated

		learned_dislikes.erase(
			preference
		)

	elif updated <= 0.4:

		learned_dislikes[preference] = 1.0 - updated

		learned_preferences.erase(
			preference
		)

	else:

		learned_uncertainties[preference] = (
			1.0 - abs(updated - 0.5) * 2.0
		)


# ============================================================
# ACTION OUTCOME LEARNING
# ============================================================

func _learn_action_outcome(
	experience: Dictionary,
	significance: float,
	success: float
) -> void:

	var action: String = str(
		experience.get("action", "")
	).strip_edges()

	if action.is_empty():
		return

	if not action_outcomes.has(action):
		action_outcomes[action] = {
			"attempts": 0,
			"successes": 0,
			"average_outcome": 0.5
		}

	var record: Dictionary = action_outcomes[action]

	record["attempts"] = int(
		record.get("attempts", 0)
	) + 1

	if success > 0.5:
		record["successes"] = int(
			record.get("successes", 0)
		) + 1

	var current_outcome: float = float(
		record.get(
			"average_outcome",
			0.5
		)
	)

	record["average_outcome"] = _learn_toward(
		current_outcome,
		success,
		significance
	)

	action_outcomes[action] = record


# ============================================================
# SOCIAL LEARNING
# ============================================================

func _learn_social_information(
	experience: Dictionary,
	significance: float
) -> void:

	var target_id: String = str(
		experience.get("target_id", "")
	).strip_edges()

	if target_id.is_empty():
		return

	var learned_key: String = str(
		experience.get("social_key", "")
	).strip_edges()

	if learned_key.is_empty():
		return

	if not social_learning.has(target_id):
		social_learning[target_id] = {}

	var target_data: Dictionary = (
		social_learning[target_id]
	)

	var target_value: float = clamp(
		float(
			experience.get(
				"social_value",
				0.5
			)
		),
		0.0,
		1.0
	)

	var current_value: float = float(
		target_data.get(
			learned_key,
			0.5
		)
	)

	target_data[learned_key] = _learn_toward(
		current_value,
		target_value,
		significance
	)

	social_learning[target_id] = target_data


# ============================================================
# SELF LEARNING
# ============================================================

func _learn_self_information(
	experience: Dictionary,
	significance: float,
	success: float
) -> void:

	var self_key: String = str(
		experience.get("self_key", "")
	).strip_edges()

	if self_key.is_empty():
		return

	var value: float = clamp(
		float(
			experience.get(
				"self_value",
				success
			)
		),
		0.0,
		1.0
	)

	var current: float = float(
		self_observations.get(
			self_key,
			0.5
		)
	)

	self_observations[self_key] = _learn_toward(
		current,
		value,
		significance
	)


# ============================================================
# LEARNING MATH
# ============================================================

func _effective_learning_rate(
	significance: float
) -> float:

	var rate : float = learning_rate * clamp(
		significance,
		0.0,
		1.0
	)

	return clamp(
		rate,
		0.0,
		1.0
	)


func _learn_toward(
	current: float,
	target: float,
	significance: float
) -> float:

	var rate := _effective_learning_rate(
		significance
	)

	# Established beliefs resist change.
	#
	# This makes repeated evidence more important than one
	# isolated event.

	var inertia_modifier : float = lerp(
		1.0,
		0.25,
		belief_inertia
	)

	rate *= inertia_modifier

	return clamp(
		lerp(
			current,
			target,
			rate
		),
		0.0,
		1.0
	)


func _update_dictionary_value(
	dictionary: Dictionary,
	key: String,
	target: float,
	significance: float
) -> void:

	var current: float = float(
		dictionary.get(
			key,
			0.5
		)
	)

	dictionary[key] = _learn_toward(
		current,
		target,
		significance
	)


# ============================================================
# SUCCESS EXTRACTION
# ============================================================

func _extract_success(
	experience: Dictionary
) -> float:

	if experience.has("success"):
		return clamp(
			float(experience["success"]),
			0.0,
			1.0
		)

	if experience.has("outcome"):
		var outcome: String = str(
			experience["outcome"]
		).to_lower()

		if outcome in [
			"success",
			"successful",
			"positive",
			"good"
		]:
			return 1.0

		if outcome in [
			"failure",
			"failed",
			"negative",
			"bad"
		]:
			return 0.0

	return 0.5


# ============================================================
# QUERY FUNCTIONS
# ============================================================

func get_belief(
	belief: String,
	default_value: float = 0.5
) -> float:

	return float(
		learned_beliefs.get(
			belief,
			default_value
		)
	)


func get_belief_confidence(
	belief: String,
	default_value: float = 0.0
) -> float:

	return float(
		belief_confidence.get(
			belief,
			default_value
		)
	)


func get_expectation(
	key: String,
	default_value: float = 0.5
) -> float:

	return float(
		expectations.get(
			key,
			default_value
		)
	)


func get_preference(
	key: String,
	default_value: float = 0.5
) -> float:

	if learned_preferences.has(key):
		return float(
			learned_preferences[key]
		)

	if learned_dislikes.has(key):
		return 1.0 - float(
			learned_dislikes[key]
		)

	return default_value


func get_action_success(
	action: String
) -> float:

	if not action_outcomes.has(action):
		return 0.5

	var record: Dictionary = (
		action_outcomes[action]
	)

	return float(
		record.get(
			"average_outcome",
			0.5
		)
	)


func get_social_learning(
	target_id: String,
	key: String,
	default_value: float = 0.5
) -> float:

	if not social_learning.has(target_id):
		return default_value

	var data: Dictionary = (
		social_learning[target_id]
	)

	return float(
		data.get(
			key,
			default_value
		)
	)


func get_self_observation(
	key: String,
	default_value: float = 0.5
) -> float:

	return float(
		self_observations.get(
			key,
			default_value
		)
	)


# ============================================================
# SUMMARY
# ============================================================

func get_summary() -> String:

	return (
		"Experiences: %d | "
		+ "Successful: %d | "
		+ "Unsuccessful: %d | "
		+ "Beliefs: %d | "
		+ "Associations: %d | "
		+ "Expectations: %d | "
		+ "Preferences: %d | "
		+ "Action outcomes: %d"
	) % [
		total_experiences,
		successful_experiences,
		unsuccessful_experiences,
		learned_beliefs.size(),
		associations.size(),
		expectations.size(),
		learned_preferences.size(),
		action_outcomes.size()
	]


# ============================================================
# DEBUG
# ============================================================

func print_state() -> void:

	print("========================================")
	print("LEARNING")
	print("========================================")

	print("Total experiences: ", total_experiences)
	print("Successful: ", successful_experiences)
	print("Unsuccessful: ", unsuccessful_experiences)

	print("Learned beliefs: ", learned_beliefs)
	print("Belief confidence: ", belief_confidence)

	print("Associations: ", associations)
	print("Expectations: ", expectations)

	print("Preferences: ", learned_preferences)
	print("Dislikes: ", learned_dislikes)
	print("Uncertainties: ", learned_uncertainties)

	print("Action outcomes: ", action_outcomes)
	print("Social learning: ", social_learning)
	print("Self observations: ", self_observations)

	print("Learning rate: ", learning_rate)
	print("Belief inertia: ", belief_inertia)

	print("========================================")
