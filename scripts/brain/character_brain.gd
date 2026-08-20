class_name CharacterBrain
extends Node


# ============================================================
# CHARACTER BRAIN
#
# Main runtime controller for the character's internal systems.
#
# Individual systems are Resources.
# CharacterBrain is a Node so it can run every frame and act
# as the central orchestrator / test harness.
#
# Update order (high level):
#   1. Physiology
#   2. Perception
#   3. Emotion
#   4. Motivation
#   5. Relationship (light maintenance)
#   6. Decision Maker  ← produces current Intention
#   7. (Future: Planner, Working Memory, Learning, etc.)
# ============================================================


# ============================================================
# BRAIN SYSTEMS
# ============================================================

var physiology: CharacterPhysiology
var personality: CharacterPersonality
var perception: CharacterPerception
var self_model: CharacterSelfModel
var emotion: CharacterEmotion
var motivation: CharacterMotivation
var relationship_manager: CharacterRelationshipManager
var decision_maker: CharacterDecisionMaker

# Still present but not fully driven every frame yet
var memory: CharacterMemory
var working_memory: CharacterWorkingMemory
var goals: CharacterGoals
var attention: CharacterAttention
var prediction: CharacterPrediction
var planner: CharacterPlanner
var learning: CharacterLearning


# ============================================================
# RUNTIME STATE
# ============================================================

var simulation_time: float = 0.0
var brain_enabled: bool = true
var update_count: int = 0

# Simple focus tracking for testing
var focus_person_id: String = "player"
var focus_person_name: String = "Player"


# ============================================================
# INITIALIZATION
# ============================================================

func _ready() -> void:
	# Core systems
	physiology = CharacterPhysiology.new()
	personality = CharacterPersonality.new()
	perception = CharacterPerception.new()
	self_model = CharacterSelfModel.new()
	emotion = CharacterEmotion.new()
	motivation = CharacterMotivation.new()
	relationship_manager = CharacterRelationshipManager.new()
	decision_maker = CharacterDecisionMaker.new()

	# Supporting systems (created so they exist)
	memory = CharacterMemory.new()
	working_memory = CharacterWorkingMemory.new()
	goals = CharacterGoals.new()
	attention = CharacterAttention.new()
	prediction = CharacterPrediction.new()
	planner = CharacterPlanner.new()
	learning = CharacterLearning.new()

	# Ensure a relationship record exists for the default focus
	relationship_manager.get_or_create_relationship(focus_person_id, focus_person_name)

	print("")
	print("========================================")
	print("CHARACTER BRAIN INITIALIZED (FULL)")
	print("========================================")
	print("Systems online: Physiology, Personality, Perception,")
	print("Self Model, Emotion, Motivation, Relationship Manager,")
	print("Decision Maker + supporting systems.")
	print("========================================")
	print("")


# ============================================================
# MAIN BRAIN UPDATE
# ============================================================

func _process(delta: float) -> void:
	if not brain_enabled:
		return

	simulation_time += delta
	update_count += 1

	# --------------------------------------------------------
	# 1. PHYSIOLOGY
	# --------------------------------------------------------
	physiology.update(delta)

	# --------------------------------------------------------
	# 2. PERCEPTION
	# --------------------------------------------------------
	perception.update(delta)

	# --------------------------------------------------------
	# 3. EMOTION
	# --------------------------------------------------------
	emotion.update(delta)

	# --------------------------------------------------------
	# 4. MOTIVATION
	# --------------------------------------------------------
	motivation.update(delta)

	# --------------------------------------------------------
	# 5. RELATIONSHIP (light per-frame maintenance if needed)
	# --------------------------------------------------------
	# Most relationship changes are event-driven.
	# We just make sure the focus person record exists.
	var rel = relationship_manager.get_or_create_relationship(focus_person_id, focus_person_name)

	# --------------------------------------------------------
	# 6. DECISION MAKER
	# Build clean snapshots and let it choose an Intention.
	# --------------------------------------------------------
	var phys_snap := {
		"energy": physiology.energy,
		"fatigue": physiology.fatigue,
		"hunger": physiology.hunger,
		"thirst": physiology.thirst,
		"sleepiness": physiology.sleepiness,
		"comfort": physiology.comfort,
		"pain": physiology.pain,
		"stress": physiology.stress,
		"arousal": physiology.arousal
	}

	var emo_snap := {
		"valence": emotion.valence,
		"arousal": emotion.arousal,
		"happiness": emotion.happiness,
		"sadness": emotion.sadness,
		"anger": emotion.anger,
		"fear": emotion.fear,
		"anxiety": emotion.anxiety,
		"excitement": emotion.excitement,
		"curiosity": emotion.curiosity,
		"affection": emotion.affection,
		"embarrassment": emotion.embarrassment,
		"frustration": emotion.frustration,
		"loneliness": emotion.loneliness,
		"contentment": emotion.contentment
	}

	var mot_snap := {
		"safety": motivation.get_motivation("safety"),
		"comfort": motivation.get_motivation("comfort"),
		"biological_need": motivation.get_motivation("biological_need"),
		"stress_relief": motivation.get_motivation("stress_relief"),
		"social_connection": motivation.get_motivation("social_connection"),
		"curiosity": motivation.get_motivation("curiosity"),
		"pleasure": motivation.get_motivation("pleasure"),
		"autonomy": motivation.get_motivation("autonomy"),
		"achievement": motivation.get_motivation("achievement"),
		"care_for_others": motivation.get_motivation("care_for_others"),
		"attachment": motivation.get_motivation("attachment"),
		"acceptance": motivation.get_motivation("acceptance"),
		"intimacy": motivation.get_motivation("intimacy"),
		"dominant_motivation": motivation.get_dominant_motivation(),
		"dominant_strength": motivation.get_dominant_strength(),
		"overall_drive": motivation.get_overall_drive()
	}

	var pers_snap := {
		"confidence": personality.confidence,
		"empathy": personality.empathy,
		"assertiveness": personality.assertiveness,
		"curiosity": personality.curiosity,
		"openness": personality.openness,
		"sociability": personality.sociability,
		"caution": personality.caution,
		"playfulness": personality.playfulness
	}

	var perc_snap := {
		"person_present": perception.person_present,
		"person_distance": perception.person_distance,
		"eye_contact": perception.eye_contact,
		"observed_confidence": perception.observed_confidence,
		"observed_nervousness": perception.observed_nervousness,
		"observed_friendliness": perception.observed_friendliness,
		"observed_aggression": perception.observed_aggression,
		"observed_interest": perception.observed_interest,
		"focus_person_id": focus_person_id
	}

	var rel_snap := {}
	if rel != null:
		rel_snap = {
			"affection": rel.affection,
			"trust": rel.trust,
			"closeness": rel.closeness,
			"attachment": rel.attachment,
			"comfort": rel.comfort,
			"respect": rel.respect,
			"fear": rel.fear,
			"suspicion": rel.suspicion,
			"importance": rel.importance,
			"relationship_type": rel.relationship_type,
			# These will be filled properly later by perception + inference
			"inferred_comfort": 0.55,
			"inferred_arousal": 0.0,
			"inferred_nervousness": perception.observed_nervousness,
			"inferred_interest": perception.observed_interest
		}

	var self_snap := self_model.get_self_state() if self_model.has_method("get_self_state") else {}

	decision_maker.update(
		delta,
		phys_snap,
		emo_snap,
		mot_snap,
		pers_snap,
		perc_snap,
		rel_snap,
		self_snap,
		[]  # goals array – can be wired later
	)

	# --------------------------------------------------------
	# DEBUG OUTPUT (throttled)
	# --------------------------------------------------------
	if update_count % 300 == 0:
		print_brain_state()


# ============================================================
# BRAIN STATE (for debugging / external systems)
# ============================================================

func get_brain_state() -> Dictionary:
	var rel = relationship_manager.get_relationship(focus_person_id)
	var rel_data := {}
	if rel != null:
		rel_data = {
			"affection": rel.affection,
			"trust": rel.trust,
			"closeness": rel.closeness,
			"attachment": rel.attachment,
			"comfort": rel.comfort,
			"relationship_type": rel.relationship_type
		}

	return {
		"simulation_time": simulation_time,
		"physiology": {
			"energy": physiology.energy,
			"fatigue": physiology.fatigue,
			"hunger": physiology.hunger,
			"thirst": physiology.thirst,
			"comfort": physiology.comfort,
			"stress": physiology.stress,
			"arousal": physiology.arousal
		},
		"emotion": {
			"valence": emotion.valence,
			"arousal": emotion.arousal,
			"happiness": emotion.happiness,
			"anxiety": emotion.anxiety,
			"affection": emotion.affection,
			"curiosity": emotion.curiosity
		},
		"motivation": {
			"dominant": motivation.get_dominant_motivation(),
			"dominant_strength": motivation.get_dominant_strength(),
			"intimacy": motivation.get_motivation("intimacy"),
			"social_connection": motivation.get_motivation("social_connection"),
			"curiosity": motivation.get_motivation("curiosity")
		},
		"relationship": rel_data,
		"current_intention": decision_maker.get_summary() if decision_maker.current_intention else "none",
		"personality": personality.get_summary() if personality.has_method("get_summary") else "",
		"perception": perception.get_summary() if perception.has_method("get_summary") else ""
	}


func print_brain_state() -> void:
	print("")
	print("========================================")
	print("CHARACTER BRAIN STATE  t=%.1f" % simulation_time)
	print("========================================")

	print("PHYSIOLOGY")
	print("  Energy: %.2f  |  Stress: %.2f  |  Arousal: %.2f  |  Comfort: %.2f" % [
		physiology.energy, physiology.stress, physiology.arousal, physiology.comfort
	])

	print("EMOTION")
	print("  Valence: %.2f  |  Arousal: %.2f  |  Happiness: %.2f  |  Anxiety: %.2f  |  Affection: %.2f" % [
		emotion.valence, emotion.arousal, emotion.happiness, emotion.anxiety, emotion.affection
	])

	print("MOTIVATION")
	print("  Dominant: %s (%.2f)  |  Intimacy: %.2f  |  Social: %.2f  |  Curiosity: %.2f" % [
		motivation.get_dominant_motivation(),
		motivation.get_dominant_strength(),
		motivation.get_motivation("intimacy"),
		motivation.get_motivation("social_connection"),
		motivation.get_motivation("curiosity")
	])

	var rel = relationship_manager.get_relationship(focus_person_id)
	if rel:
		print("RELATIONSHIP (%s)" % focus_person_name)
		print("  Affection: %.2f  |  Trust: %.2f  |  Closeness: %.2f  |  Comfort: %.2f" % [
			rel.affection, rel.trust, rel.closeness, rel.comfort
		])

	print("DECISION")
	print("  %s" % decision_maker.get_summary())

	print("========================================")
	print("")


# ============================================================
# TEST / DEBUG HELPERS
# ============================================================

func test_perceive_person() -> void:
	perception.perceive_person(5.0, 0.80, "upright", "deliberate", "smiling", "normal")
	if perception.has_method("estimate_social_behavior"):
		perception.estimate_social_behavior()
	print("Perception test complete.")
	print(perception.get_summary() if perception.has_method("get_summary") else "No summary")


func test_positive_social() -> void:
	relationship_manager.apply_positive_interaction(focus_person_id, 0.6)
	emotion.experience_event("pleasant_social_interaction")
	motivation.push_motivation("social_connection", 0.3, "positive_interaction")
	motivation.push_motivation("attachment", 0.2, "positive_interaction")
	print("Applied positive social interaction.")


func test_intimate_interest() -> void:
	# Simulate rising interest + some trust/closeness
	var rel = relationship_manager.get_or_create_relationship(focus_person_id, focus_person_name)
	rel.affection = min(rel.affection + 0.15, 1.0)
	rel.trust = min(rel.trust + 0.10, 1.0)
	rel.closeness = min(rel.closeness + 0.12, 1.0)
	rel.comfort = min(rel.comfort + 0.08, 1.0)

	physiology.arousal = min(physiology.arousal + 0.25, 1.0)
	emotion.change("affection", 0.15)
	emotion.change("excitement", 0.12)
	motivation.push_motivation("intimacy", 0.45, "test_intimate")
	motivation.push_motivation("pleasure", 0.25, "test_intimate")

	print("Simulated rising intimate interest.")


func test_nervous_partner() -> void:
	# Make the character perceive the partner as nervous
	perception.observed_nervousness = 0.75
	perception.observed_confidence = 0.25
	perception.person_present = true
	print("Partner perceived as nervous.")


func enable_brain() -> void:
	brain_enabled = true


func disable_brain() -> void:
	brain_enabled = false


func toggle_brain() -> void:
	brain_enabled = not brain_enabled


func reset_brain() -> void:
	_ready()  # simplest full reset for now
	simulation_time = 0.0
	update_count = 0
	print("Character brain fully reset.")


# ============================================================
# ACCESSORS
# ============================================================

func get_physiology() -> CharacterPhysiology:
	return physiology

func get_personality() -> CharacterPersonality:
	return personality

func get_perception() -> CharacterPerception:
	return perception

func get_self_model() -> CharacterSelfModel:
	return self_model

func get_emotion() -> CharacterEmotion:
	return emotion

func get_motivation() -> CharacterMotivation:
	return motivation

func get_relationship_manager() -> CharacterRelationshipManager:
	return relationship_manager

func get_decision_maker() -> CharacterDecisionMaker:
	return decision_maker

func get_current_intention():
	return decision_maker.get_current_intention()
