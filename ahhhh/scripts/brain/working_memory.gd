class_name CharacterWorkingMemory
extends Resource


# ============================================================
# CHARACTER WORKING MEMORY
#
# Working memory represents information that is currently
# active in the character's mind.
#
# It is NOT long-term memory.
#
# Examples:
#
#     "Someone is approaching me."
#     "They seem nervous."
#     "I am currently talking to them."
#     "They just looked away."
#
# Working memory should:
#
#     - hold a limited amount of information
#     - prioritize important information
#     - allow information to decay
#     - distinguish observations from interpretations
#     - track the current thought
#     - track the current situation
#
# Long-term memories belong in memory.gd.
# ============================================================


# ============================================================
# MEMORY LIMITS
# ============================================================

## Maximum number of items that can remain in working memory.

@export_range(1, 50)
var capacity: int = 12


## How quickly unimportant information is forgotten.

@export_range(0.0, 1.0)
var forgetting_rate: float = 0.10


## How strongly important information resists forgetting.

@export_range(0.0, 1.0)
var importance_retention: float = 0.80


# ============================================================
# CURRENT THOUGHT
# ============================================================

## The character's current active thought.

var current_thought: String = ""


## Type of the current thought.
##
## Examples:
##
##     observation
##     interpretation
##     question
##     memory
##     goal
##     concern
##     desire

var current_thought_type: String = ""


## Strength of the current thought.

@export_range(0.0, 1.0)
var current_thought_strength: float = 0.0


# ============================================================
# CURRENT SITUATION
# ============================================================

## Short description of what the character currently believes
## is happening.

var current_situation: String = ""


## The person/object/event currently occupying the character's
## working memory.

var current_subject: String = ""


# ============================================================
# MEMORY ITEMS
# ============================================================

## Each item is stored as a Dictionary.
##
## Example:
##
## {
##     "content": "Someone is approaching me.",
##     "type": "observation",
##     "subject": "friendly_person",
##     "importance": 0.7,
##     "confidence": 0.9,
##     "age": 0.0,
##     "emotional_weight": 0.3
## }

var memories: Array[Dictionary] = []


# ============================================================
# ADD MEMORY
# ============================================================

func add_memory(
	content: String,
	memory_type: String = "observation",
	subject: String = "",
	importance: float = 0.5,
	confidence: float = 1.0,
	emotional_weight: float = 0.0
) -> void:

	var memory := {

		"content": content,

		"type": memory_type,

		"subject": subject,

		"importance": clamp(
			importance,
			0.0,
			1.0
		),

		"confidence": clamp(
			confidence,
			0.0,
			1.0
		),

		"age": 0.0,

		"emotional_weight": clamp(
			emotional_weight,
			0.0,
			1.0
		)
	}


	memories.append(memory)


	# --------------------------------------------------------
	# If working memory becomes too large, remove the least
	# important item.
	# --------------------------------------------------------

	enforce_capacity()


# ============================================================
# UPDATE
# ============================================================

func update(delta: float) -> void:

	# --------------------------------------------------------
	# Age every memory.
	# --------------------------------------------------------

	for memory in memories:

		memory["age"] += delta


	# --------------------------------------------------------
	# Forget weak information.
	# --------------------------------------------------------

	for i in range(memories.size() - 1, -1, -1):

		var memory: Dictionary = memories[i]

		var importance: float = memory.get(
			"importance",
			0.0
		)

		var emotional_weight: float = memory.get(
			"emotional_weight",
			0.0
		)

		var age: float = memory.get(
			"age",
			0.0
		)


		# Important or emotionally meaningful information
		# lasts longer.

		var retention: float = clamp(
			(
				importance
				* importance_retention
				+ emotional_weight
				* 0.50
			),
			0.0,
			1.0
		)


		var effective_forgetting: float = (
			forgetting_rate
			* (1.0 - retention)
		)


		# ----------------------------------------------------
		# Convert age into a simple forgetting probability.
		#
		# This isn't intended to be a scientifically accurate
		# model of human memory. It gives us controllable
		# behavior that we can refine later.
		# ----------------------------------------------------

		var forgetting_pressure: float = (
			age
			* effective_forgetting
			* 0.01
		)


		if forgetting_pressure > 0.50:

			memories.remove_at(i)


	# --------------------------------------------------------
	# Current thought gradually loses strength.
	# --------------------------------------------------------

	if current_thought_strength > 0.0:

		current_thought_strength = move_toward(
			current_thought_strength,
			0.0,
			delta * forgetting_rate * 0.05
		)


# ============================================================
# SET CURRENT THOUGHT
# ============================================================

func set_current_thought(
	content: String,
	thought_type: String = "observation",
	strength: float = 0.5
) -> void:

	current_thought = content

	current_thought_type = thought_type

	current_thought_strength = clamp(
		strength,
		0.0,
		1.0
	)


# ============================================================
# SET SITUATION
# ============================================================

func set_situation(
	situation: String,
	subject: String = ""
) -> void:

	current_situation = situation

	current_subject = subject


# ============================================================
# GET MOST IMPORTANT MEMORY
# ============================================================

func get_most_important_memory() -> Dictionary:

	if memories.is_empty():

		return {}


	var best_memory: Dictionary = {}

	var best_score := -1.0


	for memory in memories:

		var importance: float = memory.get(
			"importance",
			0.0
		)

		var emotional_weight: float = memory.get(
			"emotional_weight",
			0.0
		)

		var confidence: float = memory.get(
			"confidence",
			1.0
		)


		var score: float = (

			importance * 0.50

			+ emotional_weight * 0.30

			+ confidence * 0.20
		)


		if score > best_score:

			best_score = score

			best_memory = memory


	return best_memory


# ============================================================
# GET MEMORIES ABOUT SUBJECT
# ============================================================

func get_memories_about(
	subject: String
) -> Array[Dictionary]:

	var result: Array[Dictionary] = []


	for memory in memories:

		if memory.get("subject", "") == subject:

			result.append(memory)


	return result


# ============================================================
# GET MEMORIES BY TYPE
# ============================================================

func get_memories_by_type(
	memory_type: String
) -> Array[Dictionary]:

	var result: Array[Dictionary] = []


	for memory in memories:

		if memory.get("type", "") == memory_type:

			result.append(memory)


	return result


# ============================================================
# REMOVE MEMORY
# ============================================================

func remove_memory(
	content: String
) -> void:

	for i in range(memories.size() - 1, -1, -1):

		if memories[i].get("content", "") == content:

			memories.remove_at(i)


# ============================================================
# CLEAR MEMORY
# ============================================================

func clear() -> void:

	memories.clear()

	current_thought = ""

	current_thought_type = ""

	current_thought_strength = 0.0

	current_situation = ""

	current_subject = ""


# ============================================================
# ENFORCE CAPACITY
# ============================================================

func enforce_capacity() -> void:

	while memories.size() > capacity:

		var weakest_index := 0

		var weakest_score := INF


		for i in range(memories.size()):

			var memory: Dictionary = memories[i]

			var importance: float = memory.get(
				"importance",
				0.0
			)

			var emotional_weight: float = memory.get(
				"emotional_weight",
				0.0
			)

			var confidence: float = memory.get(
				"confidence",
				1.0
			)


			var score: float = (

				importance * 0.50

				+ emotional_weight * 0.30

				+ confidence * 0.20
			)


			if score < weakest_score:

				weakest_score = score

				weakest_index = i


		memories.remove_at(
			weakest_index
		)


# ============================================================
# MEMORY COUNT
# ============================================================

func get_memory_count() -> int:

	return memories.size()


# ============================================================
# DEBUG SUMMARY
# ============================================================

func get_summary() -> String:

	return (

		"Current thought: %s | "

		+ "Thought type: %s | "

		+ "Thought strength: %.2f | "

		+ "Situation: %s | "

		+ "Subject: %s | "

		+ "Memory count: %d/%d"

	) % [

		current_thought,

		current_thought_type,

		current_thought_strength,

		current_situation,

		current_subject,

		memories.size(),

		capacity
	]


# ============================================================
# DEBUG MEMORY LIST
# ============================================================

func get_memory_debug_text() -> String:

	var output := ""


	for i in range(memories.size()):

		var memory: Dictionary = memories[i]

		output += (

			"[%d] %s | "

			+ "Type: %s | "

			+ "Subject: %s | "

			+ "Importance: %.2f | "

			+ "Confidence: %.2f | "

			+ "Age: %.1f | "

			+ "Emotion: %.2f\n"

		) % [

			i,

			memory.get(
				"content",
				""
			),

			memory.get(
				"type",
				""
			),

			memory.get(
				"subject",
				""
			),

			memory.get(
				"importance",
				0.0
			),

			memory.get(
				"confidence",
				0.0
			),

			memory.get(
				"age",
				0.0
			),

			memory.get(
				"emotional_weight",
				0.0
			)
		]


	return output
