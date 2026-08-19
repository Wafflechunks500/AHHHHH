class_name CharacterBrain
extends Node


# ============================================================
# CHARACTER BRAIN
#
# Main controller for the character's internal systems.
#
# IMPORTANT:
#
# The individual brain systems are Resources.
#
# CharacterBrain itself is a Node because it acts as the
# runtime controller / test script.
#
# Current systems:
#
#     Physiology
#     Personality
#     Perception
#     Self Model
#
# Additional systems such as:
#
#     Emotion
#     Memory
#     Relationships
#     Motivation
#     Prediction
#     Planning
#     Learning
#     Goals
#     Decision Making
#
# can be connected here as their APIs are established.
#
# This file deliberately does NOT assume function signatures
# that have not been established.
# ============================================================


# ============================================================
# BRAIN SYSTEMS
# ============================================================

var physiology: CharacterPhysiology
var personality: CharacterPersonality
var perception: CharacterPerception
var self_model: CharacterSelfModel


# ============================================================
# RUNTIME STATE
# ============================================================

var simulation_time: float = 0.0

var brain_enabled: bool = true

var update_count: int = 0


# ============================================================
# INITIALIZATION
# ============================================================

func _ready() -> void:

	# --------------------------------------------------------
	# Create the brain's internal Resources.
	# --------------------------------------------------------

	physiology = CharacterPhysiology.new()

	personality = CharacterPersonality.new()

	perception = CharacterPerception.new()

	self_model = CharacterSelfModel.new()


	# --------------------------------------------------------
	# Initial debug information.
	# --------------------------------------------------------

	print("")
	print("========================================")
	print("CHARACTER BRAIN INITIALIZED")
	print("========================================")

	print("")

	print("PHYSIOLOGY")
	print(
		"Energy: ",
		physiology.energy
	)

	print(
		"Fatigue: ",
		physiology.fatigue
	)

	print(
		"Hunger: ",
		physiology.hunger
	)

	print(
		"Thirst: ",
		physiology.thirst
	)

	print("")

	print("PERSONALITY")
	print(
		personality.get_summary()
	)

	print("")

	print("PERCEPTION")
	print(
		perception.get_summary()
	)

	print("")

	print("SELF MODEL")
	print(
		self_model.get_self_assessment()
	)

	print("")

	print("========================================")


# ============================================================
# MAIN BRAIN UPDATE
# ============================================================

func _process(delta: float) -> void:

	if not brain_enabled:
		return


	simulation_time += delta

	update_count += 1


	# --------------------------------------------------------
	# PHYSIOLOGY
	#
	# CharacterPhysiology.update() accepts exactly one argument:
	#
	#     delta: float
	# --------------------------------------------------------

	physiology.update(delta)


	# --------------------------------------------------------
	# PERCEPTION
	#
	# CharacterPerception.update() also accepts exactly one
	# argument:
	#
	#     delta: float
	# --------------------------------------------------------

	perception.update(delta)


	# --------------------------------------------------------
	# PERSONALITY
	#
	# Personality is a relatively stable Resource.
	#
	# It does NOT have an update() function.
	#
	# The brain reads its values when necessary.
	# --------------------------------------------------------


	# --------------------------------------------------------
	# SELF MODEL
	#
	# The self model does not currently have a time-based
	# update() function.
	#
	# It changes through experiences and learning.
	# --------------------------------------------------------


	# --------------------------------------------------------
	# DEBUG OUTPUT
	#
	# Don't print every frame.
	# --------------------------------------------------------

	if update_count % 300 == 0:

		print_brain_state()


# ============================================================
# BRAIN STATE
# ============================================================

func get_brain_state() -> Dictionary:

	return {

		"simulation_time":
			simulation_time,

		"physiology":
			{

				"energy":
					physiology.energy,

				"fatigue":
					physiology.fatigue,

				"hunger":
					physiology.hunger,

				"thirst":
					physiology.thirst,

				"sleepiness":
					physiology.sleepiness,

				"comfort":
					physiology.comfort,

				"pain":
					physiology.pain,

				"stress":
					physiology.stress,

				"arousal":
					physiology.arousal
			},

		"personality":
			{

				"confidence":
					personality.confidence,

				"empathy":
					personality.empathy,

				"assertiveness":
					personality.assertiveness,

				"curiosity":
					personality.curiosity,

				"openness":
					personality.openness,

				"sociability":
					personality.sociability,

				"caution":
					personality.caution,

				"playfulness":
					personality.playfulness
			},

		"perception":
			{

				"person_present":
					perception.person_present,

				"person_distance":
					perception.person_distance,

				"eye_contact":
					perception.eye_contact,

				"observed_confidence":
					perception.observed_confidence,

				"observed_nervousness":
					perception.observed_nervousness,

				"observed_friendliness":
					perception.observed_friendliness,

				"observed_aggression":
					perception.observed_aggression,

				"observed_interest":
					perception.observed_interest
			},

		"self_model":
			self_model.get_self_state()
	}


# ============================================================
# DEBUG OUTPUT
# ============================================================

func print_brain_state() -> void:

	print("")
	print("========================================")
	print("CHARACTER BRAIN STATE")
	print("========================================")

	print(
		"Simulation time: %.1f"
		% simulation_time
	)

	print("")

	# --------------------------------------------------------
	# PHYSIOLOGY
	# --------------------------------------------------------

	print("PHYSIOLOGY")

	print(
		"  Energy: %.2f"
		% physiology.energy
	)

	print(
		"  Fatigue: %.2f"
		% physiology.fatigue
	)

	print(
		"  Hunger: %.2f"
		% physiology.hunger
	)

	print(
		"  Thirst: %.2f"
		% physiology.thirst
	)

	print(
		"  Sleepiness: %.2f"
		% physiology.sleepiness
	)

	print(
		"  Comfort: %.2f"
		% physiology.comfort
	)

	print(
		"  Pain: %.2f"
		% physiology.pain
	)

	print(
		"  Stress: %.2f"
		% physiology.stress
	)

	print("")

	# --------------------------------------------------------
	# PERSONALITY
	# --------------------------------------------------------

	print("PERSONALITY")

	print(
		"  %s"
		% personality.get_summary()
	)

	print("")

	# --------------------------------------------------------
	# PERCEPTION
	# --------------------------------------------------------

	print("PERCEPTION")

	print(
		"  %s"
		% perception.get_summary()
	)

	print("")

	# --------------------------------------------------------
	# SELF MODEL
	# --------------------------------------------------------

	print("SELF MODEL")

	print(
		"  Assessment: %s"
		% self_model.get_self_assessment()
	)

	print(
		"  Self-confidence: %.2f"
		% self_model.get_self_confidence()
	)

	print(
		"  Social confidence: %.2f"
		% self_model.get_social_confidence()
	)

	print(
		"  Agency: %.2f"
		% self_model.get_agency_strength()
	)

	print(
		"  Self-image vulnerability: %.2f"
		% self_model.get_self_image_vulnerability()
	)

	print("")

	print("========================================")


# ============================================================
# PERCEPTION TESTING
# ============================================================

func test_perceive_person() -> void:

	perception.perceive_person(
		5.0,
		0.80,
		"upright",
		"deliberate",
		"smiling",
		"normal"
	)

	perception.estimate_social_behavior()

	print("")
	print("========================================")
	print("PERCEPTION TEST")
	print("========================================")

	print(
		perception.get_summary()
	)

	print("========================================")


# ============================================================
# SELF MODEL TESTING
# ============================================================

func test_positive_self_event() -> void:

	self_model.apply_positive_self_event(
		"Successfully completed a difficult task.",
		0.75
	)

	print("")
	print("SELF MODEL AFTER POSITIVE EVENT")

	self_model.print_state()


func test_negative_self_event() -> void:

	self_model.apply_negative_self_event(
		"Failed an important task.",
		0.50
	)

	print("")
	print("SELF MODEL AFTER NEGATIVE EVENT")

	self_model.print_state()


# ============================================================
# PHYSIOLOGY TESTING
# ============================================================

func test_eat() -> void:

	physiology.eat(0.25)


func test_drink() -> void:

	physiology.drink(0.25)


func test_sleep() -> void:

	physiology.sleep(0.25)


func test_comfort() -> void:

	physiology.apply_comfort(0.20)


func test_stress() -> void:

	physiology.apply_stress(0.20)


func test_pain() -> void:

	physiology.apply_pain(0.20)


# ============================================================
# BRAIN CONTROL
# ============================================================

func enable_brain() -> void:

	brain_enabled = true


func disable_brain() -> void:

	brain_enabled = false


func toggle_brain() -> void:

	brain_enabled = not brain_enabled


# ============================================================
# RESET
# ============================================================

func reset_brain() -> void:

	physiology = CharacterPhysiology.new()

	personality = CharacterPersonality.new()

	perception = CharacterPerception.new()

	self_model = CharacterSelfModel.new()

	simulation_time = 0.0

	update_count = 0


	print("Character brain reset.")


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
