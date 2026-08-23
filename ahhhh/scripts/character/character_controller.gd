class_name CharacterController
extends Node


# ============================================================
# CHARACTER CONTROLLER
#
# Runtime bridge between:
#
#     Character Brain
#           ↓
#     Character Controller
#           ↓
#     Physical / audiovisual character
#
# The brain decides what the character wants to do.
#
# The controller is responsible for translating those
# intentions into runtime actions.
#
# IMPORTANT:
#
# This is NOT the decision-making system.
#
# The controller should not decide:
#
#     "I want to hug them."
#
# The brain decides that.
#
# The controller receives that intention and eventually turns
# it into actual movement, posture, gaze, speech, sound,
# facial expression, etc.
#
# The final implementation should allow continuous,
# non-scripted behavior rather than relying exclusively on
# predefined animation loops.
# ============================================================


# ============================================================
# SIGNALS
# ============================================================

## Emitted whenever the controller receives a new intention
## from the brain.
signal intention_changed(intention)


## Emitted when the controller changes a physical action.
signal action_changed(action_name, action_data)


## Emitted when the character wants to speak.
signal speech_requested(text, tone_data)


## Emitted when the character wants to produce a non-verbal
## vocalization.
signal vocalization_requested(vocalization, voice_data)


## Emitted when the controller changes the desired gaze target.
signal gaze_requested(target, gaze_data)


## Emitted whenever the desired body state changes.
signal body_state_changed(body_state)


# ============================================================
# CORE CHARACTER SYSTEMS
# ============================================================

var brain: CharacterBrain


var preferences: CharacterPreferences


# These currently exist as Nodes in the character folder.
#
# They are kept as references rather than being duplicated here.
var appearance: Node
var biography: Node
var character_profile: Node


# ============================================================
# EXTERNAL CHARACTER REPRESENTATION
# ============================================================

## The actual body/character representation.
##
## This can eventually point to the character's model,
## animation rig, physics body, or higher-level character node.

var body: Node


## Optional node responsible for speech.
##
## The controller does not require a specific implementation.
## A future speech system can connect to this.

var speech_system: Node


## Optional node responsible for facial expression.
var expression_system: Node


## Optional node responsible for gaze / eye control.
var gaze_system: Node


## Optional node responsible for locomotion / body movement.
var locomotion_system: Node


## Optional node responsible for procedural or physical
## animation.
var movement_system: Node


# ============================================================
# RUNTIME STATE
# ============================================================

var controller_enabled: bool = true


## Current intention received from the brain.

var current_intention = null


## Current high-level action being carried out.

var current_action: String = "idle"


## Current desired body state.
##
## This describes what the character is trying to physically
## express, rather than specifying a fixed animation.

var desired_body_state: Dictionary = {
	"posture": "neutral",
	"movement": "still",
	"weight_distribution": 0.5,
	"tension": 0.0,
	"energy": 0.5,
	"gesture": "",
	"facial_expression": "neutral",
	"gaze_target": "",
	"gaze_intensity": 0.0
}


## Current desired vocal state.

var desired_voice_state: Dictionary = {
	"tone": "neutral",
	"intensity": 0.5,
	"pace": 0.5,
	"pitch": 0.5,
	"breathiness": 0.0,
	"emotion": "neutral"
}


## Current desired gaze state.

var desired_gaze_state: Dictionary = {
	"target": "",
	"strength": 0.0,
	"duration": 0.0
}


# ============================================================
# INITIALIZATION
# ============================================================

func _ready() -> void:

	# --------------------------------------------------------
	# Brain
	# --------------------------------------------------------
	if brain == null:
		
		brain = get_node_or_null("CharacterBrain") as CharacterBrain

	if brain == null:

		brain = CharacterBrain.new()

		brain.name = "CharacterBrain"

		add_child(brain)


	# --------------------------------------------------------
	# Character data
	# --------------------------------------------------------

	preferences = CharacterPreferences.new()


	appearance = get_node_or_null("Appearance")

	biography = get_node_or_null("Biography")

	character_profile = get_node_or_null("CharacterProfile")


	# --------------------------------------------------------
	# External representation
	# --------------------------------------------------------

	body = get_node_or_null("Body")

	speech_system = get_node_or_null("SpeechSystem")

	expression_system = get_node_or_null("ExpressionSystem")

	gaze_system = get_node_or_null("GazeSystem")

	locomotion_system = get_node_or_null("LocomotionSystem")

	movement_system = get_node_or_null("MovementSystem")


	print("")
	print("========================================")
	print("CHARACTER CONTROLLER INITIALIZED")
	print("========================================")
	print("Brain: ", brain != null)
	print("Preferences: ", preferences != null)
	print("Body connected: ", body != null)
	print("Speech system connected: ", speech_system != null)
	print("Expression system connected: ", expression_system != null)
	print("Gaze system connected: ", gaze_system != null)
	print("Locomotion system connected: ", locomotion_system != null)
	print("Movement system connected: ", movement_system != null)
	print("========================================")
	print("")


# ============================================================
# MAIN UPDATE
# ============================================================

func _process(delta: float) -> void:

	if not controller_enabled:
		return

	if brain == null:
		return


	# --------------------------------------------------------
	# Read the brain's current intention.
	# --------------------------------------------------------

	var new_intention = brain.get_current_intention()


	if new_intention != current_intention:

		current_intention = new_intention

		intention_changed.emit(
			current_intention
		)

		interpret_intention(
			current_intention
		)


	# --------------------------------------------------------
	# Continuously update physical expression.
	#
	# This is intentionally separate from intention changes.
	#
	# The character should be able to continuously adjust:
	#
	#     posture
	#     balance
	#     gaze
	#     tension
	#     movement
	#     facial expression
	#     breathing
	#     small movements
	#
	# without requiring a new high-level decision every frame.
	# --------------------------------------------------------

	update_body_state(
		delta
	)

	update_voice_state(
		delta
	)

	update_gaze_state(
		delta
	)


# ============================================================
# INTENTION INTERPRETATION
# ============================================================

## Receives an intention from the brain.
##
## The controller translates the abstract intention into
## desired physical behavior.
##
## This does NOT perform the final movement itself.
##
## It creates the desired state that the physical systems can
## interpret.

func interpret_intention(intention) -> void:

	if intention == null:

		set_action(
			"idle",
			{}
		)

		return


	# --------------------------------------------------------
	# Extract the action name safely.
	#
	# Different versions of the decision system may return
	# different representations, so keep this deliberately
	# tolerant.
	# --------------------------------------------------------

	var action_name: String = "idle"


	if intention is Dictionary:

		action_name = str(
			intention.get(
				"action",
				intention.get(
					"type",
					intention.get(
						"name",
						"idle"
					)
				)
			)
		)

	elif intention is String:

		action_name = intention

	elif intention is Object:

		if intention.has_method("get_action"):

			action_name = str(
				intention.get_action()
			)

		elif "action" in intention:

			action_name = str(
				intention.action
			)


	# --------------------------------------------------------
	# Normalize empty actions.
	# --------------------------------------------------------

	if action_name.strip_edges() == "":
		action_name = "idle"


	set_action(
		action_name,
		intention_to_action_data(
			intention
		)
	)


# ============================================================
# INTENTION → ACTION DATA
# ============================================================

func intention_to_action_data(intention) -> Dictionary:

	if intention == null:
		return {}


	if intention is Dictionary:

		return intention.duplicate(
			true
		)


	var data: Dictionary = {}


	if intention is Object:

		if intention.has_method("get_summary"):

			data["summary"] = intention.get_summary()


		if "target" in intention:

			data["target"] = intention.target


		if "reason" in intention:

			data["reason"] = intention.reason


		if "priority" in intention:

			data["priority"] = intention.priority


	return data


# ============================================================
# ACTION STATE
# ============================================================

func set_action(
	action_name: String,
	action_data: Dictionary
) -> void:

	current_action = action_name

	action_changed.emit(
		current_action,
		action_data
	)


	# --------------------------------------------------------
	# Convert the high-level action into an initial desired
	# physical state.
	#
	# These are starting states, not fixed animation commands.
	# --------------------------------------------------------

	match action_name:

		"idle":
			desired_body_state["movement"] = "still"


		"approach":
			desired_body_state["movement"] = "walking"


		"leave":
			desired_body_state["movement"] = "walking_away"


		"look":
			desired_body_state["gaze_intensity"] = 1.0


		"talk":
			desired_body_state["gesture"] = "conversational"


		"listen":
			desired_body_state["gesture"] = "attentive"


		"comfort":
			desired_body_state["gesture"] = "comforting"


		"interact":
			desired_body_state["gesture"] = "interactive"


		_:
			desired_body_state["movement"] = "still"


	body_state_changed.emit(
		desired_body_state.duplicate(
			true
		)
	)


# ============================================================
# BODY STATE
# ============================================================

## Continuously updates the desired physical state.
##
## This is where natural small variations can eventually be
## introduced:
##
##     shifting weight
##     posture correction
##     breathing
##     small head movements
##     fidgeting
##     balance corrections
##     eye movement
##     subtle facial changes
##
## These should be generated from the character's current
## state rather than played as a fixed animation loop.

func update_body_state(delta: float) -> void:

	if delta <= 0.0:
		return


	# --------------------------------------------------------
	# Small natural weight redistribution.
	#
	# This is deliberately subtle.
	# --------------------------------------------------------

	var target_weight: float = 0.5


	if desired_body_state.has("weight_distribution"):

		target_weight = float(
			desired_body_state["weight_distribution"]
		)


	var movement_amount: float = min(
		delta * 0.5,
		1.0
	)


	desired_body_state["weight_distribution"] = lerp(
		float(
			desired_body_state["weight_distribution"]
		),
		target_weight,
		movement_amount
	)


	# --------------------------------------------------------
	# Body tension can eventually be driven by emotion,
	# physiology, intention, and personality.
	# --------------------------------------------------------

	if brain != null:

		var tension_target: float = 0.0

		if brain.emotion != null:

			tension_target = clamp(
				brain.emotion.anxiety * 0.6
				+ brain.emotion.fear * 0.4,
				0.0,
				1.0
			)


		desired_body_state["tension"] = move_toward(
			float(
				desired_body_state["tension"]
			),
			tension_target,
			delta * 0.5
		)


	body_state_changed.emit(
		desired_body_state.duplicate(
			true
		)
	)


	# --------------------------------------------------------
	# Forward desired state to the movement system if one
	# exists.
	# --------------------------------------------------------

	if movement_system != null:

		if movement_system.has_method(
			"set_desired_body_state"
		):

			movement_system.set_desired_body_state(
				desired_body_state
			)


# ============================================================
# VOICE
# ============================================================

## Request spoken dialogue from the character.
##
## The actual speech generation is intentionally external.
##
## The controller provides the desired vocal characteristics
## alongside the text.

func speak(
	text: String,
	tone: Dictionary = {}
) -> void:

	if text.strip_edges() == "":
		return


	var final_tone: Dictionary = (
		desired_voice_state.duplicate(
			true
		)
	)


	for key in tone:

		final_tone[key] = tone[key]


	speech_requested.emit(
		text,
		final_tone
	)


	if speech_system != null:

		if speech_system.has_method(
			"speak"
		):

			speech_system.speak(
				text,
				final_tone
			)


# ============================================================
# VOCALIZATION
# ============================================================

## Request a non-verbal vocalization.
##
## Examples of categories the eventual voice system could
## support include:
##
##     laugh
##     sigh
##     gasp
##     hum
##     breath
##     small vocal reaction
##
## The actual sound should come from the voice system rather
## than being hard-coded here.

func vocalize(
	vocalization: String,
	voice_data: Dictionary = {}
) -> void:

	if vocalization.strip_edges() == "":
		return


	var final_voice: Dictionary = (
		desired_voice_state.duplicate(
			true
		)
	)


	for key in voice_data:

		final_voice[key] = voice_data[key]


	vocalization_requested.emit(
		vocalization,
		final_voice
	)


	if speech_system != null:

		if speech_system.has_method(
			"vocalize"
		):

			speech_system.vocalize(
				vocalization,
				final_voice
			)


# ============================================================
# VOICE STATE
# ============================================================

func update_voice_state(delta: float) -> void:

	if delta <= 0.0:
		return


	if brain == null:
		return


	# --------------------------------------------------------
	# Emotional state influences the desired voice state.
	#
	# This does not generate speech.
	# It changes the physical characteristics that speech
	# generation can use.
	# --------------------------------------------------------

	var target_intensity: float = 0.5
	var target_emotion: String = "neutral"


	if brain.emotion != null:

		target_intensity = clamp(
			brain.emotion.arousal,
			0.0,
			1.0
		)


		if brain.emotion.anxiety > 0.65:

			target_emotion = "nervous"

		elif brain.emotion.happiness > 0.65:

			target_emotion = "happy"

		elif brain.emotion.sadness > 0.65:

			target_emotion = "sad"

		elif brain.emotion.anger > 0.65:

			target_emotion = "angry"

		elif brain.emotion.affection > 0.65:

			target_emotion = "affectionate"


	desired_voice_state["intensity"] = move_toward(
		float(
			desired_voice_state["intensity"]
		),
		target_intensity,
		delta * 0.75
	)


	desired_voice_state["emotion"] = target_emotion


# ============================================================
# GAZE
# ============================================================

func request_gaze(
	target: String,
	strength: float = 1.0,
	duration: float = 0.0
) -> void:

	desired_gaze_state["target"] = target

	desired_gaze_state["strength"] = clamp(
		strength,
		0.0,
		1.0
	)

	desired_gaze_state["duration"] = max(
		duration,
		0.0
	)


	gaze_requested.emit(
		target,
		desired_gaze_state.duplicate(
			true
		)
	)


	if gaze_system != null:

		if gaze_system.has_method(
			"look_at"
		):

			gaze_system.look_at(
				target,
				desired_gaze_state["strength"],
				desired_gaze_state["duration"]
			)


func update_gaze_state(delta: float) -> void:

	if delta <= 0.0:
		return


	if desired_gaze_state["duration"] > 0.0:

		desired_gaze_state["duration"] = max(
			0.0,
			float(
				desired_gaze_state["duration"]
			) - delta
		)


# ============================================================
# EXTERNAL INPUT
# ============================================================

## Pass a perceived person into the character's brain.

func perceive_person(
	distance: float,
	eye_contact: float,
	posture: String,
	movement: String,
	expression: String,
	speech: String
) -> void:

	if brain == null:
		return


	brain.perception.perceive_person(
		distance,
		eye_contact,
		posture,
		movement,
		expression,
		speech
	)


	if brain.perception.has_method(
		"estimate_social_behavior"
	):

		brain.perception.estimate_social_behavior()


## Pass an environmental event to the brain.

func perceive_event(
	event_name: String
) -> void:

	if brain == null:
		return


	brain.perception.perceive_event(
		event_name
	)


# ============================================================
# CHARACTER DATA ACCESS
# ============================================================

func get_brain() -> CharacterBrain:
	return brain


func get_preferences() -> CharacterPreferences:
	return preferences


func get_current_intention():
	return current_intention


func get_current_action() -> String:
	return current_action


func get_body_state() -> Dictionary:

	return desired_body_state.duplicate(
		true
	)


func get_voice_state() -> Dictionary:

	return desired_voice_state.duplicate(
		true
	)


func get_gaze_state() -> Dictionary:

	return desired_gaze_state.duplicate(
		true
	)


# ============================================================
# CONTROLLER STATE
# ============================================================

func enable_controller() -> void:

	controller_enabled = true


	if brain != null:

		brain.enable_brain()


func disable_controller() -> void:

	controller_enabled = false


	if brain != null:

		brain.disable_brain()


func toggle_controller() -> void:

	if controller_enabled:

		disable_controller()

	else:

		enable_controller()


func is_controller_enabled() -> bool:

	return controller_enabled


# ============================================================
# DEBUG
# ============================================================

func get_controller_state() -> Dictionary:

	return {
		"enabled": controller_enabled,
		"current_action": current_action,
		"current_intention": current_intention,
		"body_state": desired_body_state.duplicate(true),
		"voice_state": desired_voice_state.duplicate(true),
		"gaze_state": desired_gaze_state.duplicate(true)
	}


func print_controller_state() -> void:

	print("")
	print("========================================")
	print("CHARACTER CONTROLLER")
	print("========================================")

	print(
		"Enabled: ",
		controller_enabled
	)

	print(
		"Current action: ",
		current_action
	)

	print(
		"Body state: ",
		desired_body_state
	)

	print(
		"Voice state: ",
		desired_voice_state
	)

	print(
		"Gaze state: ",
		desired_gaze_state
	)

	print("========================================")
	print("")
