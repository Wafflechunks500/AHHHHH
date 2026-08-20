class_name CharacterMemory
extends Resource


# ============================================================
# CHARACTER LONG-TERM MEMORY
# ============================================================

@export
var maximum_memories: int = 1000

var memories: Array[Dictionary] = []


# ============================================================
# MEMORY TYPES
# ============================================================

const TYPE_FACT := "fact"
const TYPE_EVENT := "event"
const TYPE_PERSON := "person"
const TYPE_RELATIONSHIP := "relationship"
const TYPE_SKILL := "skill"
const TYPE_PREFERENCE := "preference"
const TYPE_EMOTIONAL := "emotional"
const TYPE_PLACE := "place"
const TYPE_OBJECT := "object"


# ============================================================
# ADD MEMORY
# ============================================================

func add_memory(
	content: String,
	memory_type: String = TYPE_EVENT,
	subject: String = "",
	importance: float = 0.5,
	confidence: float = 0.8,
	emotional_weight: float = 0.0,
	emotional_valence: float = 0.0,
	source: String = "personal_experience"
) -> Dictionary:

	var existing: Dictionary = find_similar_memory(
		content,
		subject
	)

	if not existing.is_empty():

		existing["importance"] = clamp(
			float(existing.get("importance", 0.5))
			+ importance * 0.15,
			0.0,
			1.0
		)

		existing["confidence"] = clamp(
			float(existing.get("confidence", 0.5))
			+ confidence * 0.10,
			0.0,
			1.0
		)

		existing["emotional_weight"] = clamp(
			max(
				float(existing.get("emotional_weight", 0.0)),
				emotional_weight
			),
			0.0,
			1.0
		)

		existing["recall_count"] = (
			int(existing.get("recall_count", 0)) + 1
		)

		existing["age"] = 0.0

		return existing


	var memory: Dictionary = {

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

		"emotional_weight": clamp(
			emotional_weight,
			0.0,
			1.0
		),

		"emotional_valence": clamp(
			emotional_valence,
			-1.0,
			1.0
		),

		"source": source,

		"age": 0.0,

		"recall_count": 0,

		"created_time": Time.get_ticks_msec()
	}


	memories.append(memory)


	if memories.size() > maximum_memories:

		remove_weakest_memory()


	return memory


# ============================================================
# FIND SIMILAR MEMORY
# ============================================================

func find_similar_memory(
	content: String,
	subject: String = ""
) -> Dictionary:

	for memory: Dictionary in memories:

		if memory.get("content", "") == content:

			if (
				subject.is_empty()
				or memory.get("subject", "") == subject
			):

				return memory


	return {}


# ============================================================
# RECALL MEMORY
# ============================================================

func recall_memory(
	memory: Dictionary
) -> Dictionary:

	if memory.is_empty():

		return {}


	memory["recall_count"] = (
		int(memory.get("recall_count", 0)) + 1
	)


	memory["confidence"] = clamp(
		float(memory.get("confidence", 0.5))
		+ 0.02,
		0.0,
		1.0
	)


	memory["age"] = 0.0


	return memory


# ============================================================
# FIND MEMORIES ABOUT SUBJECT
# ============================================================

func get_memories_about(
	subject: String
) -> Array[Dictionary]:

	var result: Array[Dictionary] = []


	for memory: Dictionary in memories:

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


	for memory: Dictionary in memories:

		if memory.get("type", "") == memory_type:

			result.append(memory)


	return result


# ============================================================
# GET STRONGEST MEMORIES
# ============================================================

func get_strongest_memories(
	count: int = 5
) -> Array[Dictionary]:

	var result: Array[Dictionary] = memories.duplicate()


	result.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:

			return get_memory_strength(a) > get_memory_strength(b)
	)


	if result.size() > count:

		result.resize(count)


	return result


# ============================================================
# MEMORY STRENGTH
# ============================================================

func get_memory_strength(
	memory: Dictionary
) -> float:

	var importance: float = float(
		memory.get("importance", 0.5)
	)

	var confidence: float = float(
		memory.get("confidence", 0.5)
	)

	var emotional_weight: float = float(
		memory.get("emotional_weight", 0.0)
	)

	var age: float = float(
		memory.get("age", 0.0)
	)

	var recall_count: int = int(
		memory.get("recall_count", 0)
	)


	var strength: float = (
		importance * 0.40
		+ confidence * 0.25
		+ emotional_weight * 0.20
	)


	var recall_bonus: float = min(
		float(recall_count) * 0.02,
		0.15
	)


	strength += recall_bonus


	var age_penalty: float = min(
		age * 0.00001,
		0.25
	)


	strength -= age_penalty


	return clamp(
		strength,
		0.0,
		1.0
	)


# ============================================================
# UPDATE
# ============================================================

func update(delta: float) -> void:

	for memory: Dictionary in memories:

		memory["age"] = (
			float(memory.get("age", 0.0))
			+ delta
		)


		var importance: float = float(
			memory.get("importance", 0.5)
		)

		var emotional_weight: float = float(
			memory.get("emotional_weight", 0.0)
		)

		var recall_count: int = int(
			memory.get("recall_count", 0)
		)


		if (
			importance < 0.5
			and emotional_weight < 0.3
			and recall_count == 0
		):

			memory["confidence"] = move_toward(
				float(memory.get("confidence", 0.5)),
				0.0,
				delta * 0.00001
			)


	for i in range(
		memories.size() - 1,
		-1,
		-1
	):

		var memory: Dictionary = memories[i]

		if get_memory_strength(memory) < 0.02:

			memories.remove_at(i)


# ============================================================
# REMOVE WEAKEST MEMORY
# ============================================================

func remove_weakest_memory() -> void:

	if memories.is_empty():

		return


	var weakest_index: int = 0

	var weakest_strength: float = (
		get_memory_strength(
			memories[0]
		)
	)


	for i in range(
		1,
		memories.size()
	):

		var strength: float = (
			get_memory_strength(
				memories[i]
			)
		)


		if strength < weakest_strength:

			weakest_strength = strength
			weakest_index = i


	memories.remove_at(
		weakest_index
	)


# ============================================================
# FORGET MEMORY
# ============================================================

func forget_memory(
	memory: Dictionary
) -> void:

	if memory.is_empty():

		return


	var index: int = memories.find(
		memory
	)


	if index >= 0:

		memories.remove_at(index)


# ============================================================
# MEMORY COUNT
# ============================================================

func get_memory_count() -> int:

	return memories.size()


# ============================================================
# CLEAR
# ============================================================

func clear() -> void:

	memories.clear()


# ============================================================
# DEBUG SUMMARY
# ============================================================

func get_summary() -> String:

	return (
		"Memories: %d/%d | Strongest: %d"
	) % [
		memories.size(),
		maximum_memories,
		min(
			5,
			memories.size()
		)
	]


# ============================================================
# DEBUG MEMORY LIST
# ============================================================

func get_memory_debug_text() -> String:

	if memories.is_empty():

		return "No long-term memories."


	var output: String = ""


	for i in range(
		memories.size()
	):

		var memory: Dictionary = memories[i]

		var strength: float = get_memory_strength(
			memory
		)


		output += (
			"[%d] %s | "
			+ "Type: %s | "
			+ "Subject: %s | "
			+ "Strength: %.2f | "
			+ "Importance: %.2f | "
			+ "Confidence: %.2f | "
			+ "Emotion: %.2f | "
			+ "Age: %.1f | "
			+ "Recalls: %d\n"
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

			strength,

			memory.get(
				"importance",
				0.0
			),

			memory.get(
				"confidence",
				0.0
			),

			memory.get(
				"emotional_weight",
				0.0
			),

			memory.get(
				"age",
				0.0
			),

			memory.get(
				"recall_count",
				0
			)
		]


	return output
