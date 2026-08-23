class_name CharacterEmotion
extends Resource


# ============================================================
# CHARACTER EMOTION SYSTEM
#
# This represents the character's CURRENT emotional state.
#
# Personality is NOT stored here.
#
# Personality describes tendencies such as:
#
#     "Naturally optimistic"
#     "Easily embarrassed"
#     "Emotionally resilient"
#
# Emotion describes what is happening RIGHT NOW:
#
#     "Happy"
#     "Anxious"
#     "Excited"
#     "Afraid"
#
# Emotions can:
#
#     - be triggered by events
#     - influence one another
#     - decay over time
#     - be reinforced by repeated events
#     - eventually be influenced by perception
#     - eventually be influenced by memory
#     - eventually be influenced by relationships
#
# This system DOES NOT decide behavior.
#
# It tells the brain:
#
#     "This is how the character currently feels."
# ============================================================


# ============================================================
# CORE EMOTIONAL DIMENSIONS
# ============================================================

## Overall positive/negative emotional tone.
##
## -1.0 = extremely negative
##  0.0 = neutral
## +1.0 = extremely positive

@export_range(-1.0, 1.0)
var valence: float = 0.20


## Overall emotional activation.
##
## 0.0 = completely calm
## 1.0 = extremely activated

@export_range(0.0, 1.0)
var arousal: float = 0.20


# ============================================================
# INDIVIDUAL EMOTIONS
# ============================================================

@export_range(0.0, 1.0)
var happiness: float = 0.40


@export_range(0.0, 1.0)
var sadness: float = 0.05


@export_range(0.0, 1.0)
var anger: float = 0.05


@export_range(0.0, 1.0)
var fear: float = 0.05


@export_range(0.0, 1.0)
var anxiety: float = 0.10


@export_range(0.0, 1.0)
var excitement: float = 0.20


@export_range(0.0, 1.0)
var curiosity: float = 0.50


@export_range(0.0, 1.0)
var affection: float = 0.10


@export_range(0.0, 1.0)
var embarrassment: float = 0.02


@export_range(0.0, 1.0)
var frustration: float = 0.05


@export_range(0.0, 1.0)
var loneliness: float = 0.15


@export_range(0.0, 1.0)
var contentment: float = 0.50


# ============================================================
# BASELINES
#
# These represent where emotions naturally tend to return
# when the character has time to emotionally settle.
#
# Eventually these values should come from the character's
# personality rather than being hard-coded here.
# ============================================================

var baselines := {

	"happiness": 0.40,

	"sadness": 0.05,

	"anger": 0.05,

	"fear": 0.05,

	"anxiety": 0.10,

	"excitement": 0.20,

	"curiosity": 0.50,

	"affection": 0.10,

	"embarrassment": 0.02,

	"frustration": 0.05,

	"loneliness": 0.15,

	"contentment": 0.50
}


# ============================================================
# DECAY RATES
#
# Higher value = emotion returns toward baseline faster.
#
# These are currently experimental.
#
# Later these can be influenced by personality.
#
# For example:
#
#     emotionally resilient character
#         → anger decays faster
#
#     anxious character
#         → anxiety decays slower
# ============================================================

var decay_rates := {

	"happiness": 0.010,

	"sadness": 0.004,

	"anger": 0.020,

	"fear": 0.030,

	"anxiety": 0.006,

	"excitement": 0.025,

	"curiosity": 0.004,

	"affection": 0.001,

	"embarrassment": 0.035,

	"frustration": 0.018,

	"loneliness": 0.001,

	"contentment": 0.003
}


# ============================================================
# UPDATE
# ============================================================

func update(delta: float) -> void:

	decay_emotions(delta)

	update_derived_state()


# ============================================================
# EMOTIONAL DECAY
# ============================================================

func decay_emotions(delta: float) -> void:

	happiness = decay_toward_baseline(
		happiness,
		baselines["happiness"],
		decay_rates["happiness"],
		delta
	)

	sadness = decay_toward_baseline(
		sadness,
		baselines["sadness"],
		decay_rates["sadness"],
		delta
	)

	anger = decay_toward_baseline(
		anger,
		baselines["anger"],
		decay_rates["anger"],
		delta
	)

	fear = decay_toward_baseline(
		fear,
		baselines["fear"],
		decay_rates["fear"],
		delta
	)

	anxiety = decay_toward_baseline(
		anxiety,
		baselines["anxiety"],
		decay_rates["anxiety"],
		delta
	)

	excitement = decay_toward_baseline(
		excitement,
		baselines["excitement"],
		decay_rates["excitement"],
		delta
	)

	curiosity = decay_toward_baseline(
		curiosity,
		baselines["curiosity"],
		decay_rates["curiosity"],
		delta
	)

	affection = decay_toward_baseline(
		affection,
		baselines["affection"],
		decay_rates["affection"],
		delta
	)

	embarrassment = decay_toward_baseline(
		embarrassment,
		baselines["embarrassment"],
		decay_rates["embarrassment"],
		delta
	)

	frustration = decay_toward_baseline(
		frustration,
		baselines["frustration"],
		decay_rates["frustration"],
		delta
	)

	loneliness = decay_toward_baseline(
		loneliness,
		baselines["loneliness"],
		decay_rates["loneliness"],
		delta
	)

	contentment = decay_toward_baseline(
		contentment,
		baselines["contentment"],
		decay_rates["contentment"],
		delta
	)


func decay_toward_baseline(
	value: float,
	baseline: float,
	rate: float,
	delta: float
) -> float:

	return move_toward(
		value,
		baseline,
		rate * delta
	)


# ============================================================
# DERIVED EMOTIONAL STATE
# ============================================================

func update_derived_state() -> void:

	# --------------------------------------------------------
	# POSITIVE EMOTIONAL CONTRIBUTION
	# --------------------------------------------------------

	var positive: float = (

		happiness * 0.25

		+ excitement * 0.15

		+ affection * 0.20

		+ curiosity * 0.10

		+ contentment * 0.30
	)


	# --------------------------------------------------------
	# NEGATIVE EMOTIONAL CONTRIBUTION
	# --------------------------------------------------------

	var negative: float = (

		sadness * 0.20

		+ anger * 0.15

		+ fear * 0.20

		+ anxiety * 0.15

		+ embarrassment * 0.05

		+ frustration * 0.15

		+ loneliness * 0.10
	)


	# --------------------------------------------------------
	# VALENCE
	# --------------------------------------------------------

	valence = clamp(

		positive - negative,

		-1.0,

		1.0
	)


	# --------------------------------------------------------
	# AROUSAL
	# --------------------------------------------------------

	arousal = clamp(

		(
			excitement * 0.20

			+ fear * 0.20

			+ anger * 0.15

			+ anxiety * 0.15

			+ frustration * 0.10

			+ curiosity * 0.10

			+ happiness * 0.05

			+ embarrassment * 0.05
		),

		0.0,

		1.0
	)


# ============================================================
# CHANGE AN EMOTION
# ============================================================

func change(
	emotion_name: String,
	amount: float
) -> void:

	match emotion_name:

		"happiness":

			happiness = clamp(
				happiness + amount,
				0.0,
				1.0
			)


		"sadness":

			sadness = clamp(
				sadness + amount,
				0.0,
				1.0
			)


		"anger":

			anger = clamp(
				anger + amount,
				0.0,
				1.0
			)


		"fear":

			fear = clamp(
				fear + amount,
				0.0,
				1.0
			)


		"anxiety":

			anxiety = clamp(
				anxiety + amount,
				0.0,
				1.0
			)


		"excitement":

			excitement = clamp(
				excitement + amount,
				0.0,
				1.0
			)


		"curiosity":

			curiosity = clamp(
				curiosity + amount,
				0.0,
				1.0
			)


		"affection":

			affection = clamp(
				affection + amount,
				0.0,
				1.0
			)


		"embarrassment":

			embarrassment = clamp(
				embarrassment + amount,
				0.0,
				1.0
			)


		"frustration":

			frustration = clamp(
				frustration + amount,
				0.0,
				1.0
			)


		"loneliness":

			loneliness = clamp(
				loneliness + amount,
				0.0,
				1.0
			)


		"contentment":

			contentment = clamp(
				contentment + amount,
				0.0,
				1.0
			)


		_:

			push_warning(
				"Unknown emotion: " + emotion_name
			)


	update_derived_state()


# ============================================================
# EMOTIONAL EVENTS
#
# These are currently test events.
#
# Eventually these should be generated by the larger
# perception/event system.
# ============================================================

func experience_event(event_name: String) -> void:

	match event_name:

		# ----------------------------------------------------
		# PLEASANT SOCIAL INTERACTION
		# ----------------------------------------------------

		"pleasant_social_interaction":

			change("happiness", 0.15)

			change("affection", 0.08)

			change("loneliness", -0.10)

			change("contentment", 0.10)

			change("anxiety", -0.03)


		# ----------------------------------------------------
		# INSULT
		# ----------------------------------------------------

		"insult":

			change("happiness", -0.10)

			change("sadness", 0.10)

			change("anger", 0.20)

			change("frustration", 0.15)

			change("embarrassment", 0.08)


		# ----------------------------------------------------
		# REJECTION
		# ----------------------------------------------------

		"rejection":

			change("happiness", -0.20)

			change("sadness", 0.20)

			change("anxiety", 0.15)

			change("embarrassment", 0.15)

			change("loneliness", 0.15)

			change("affection", -0.03)


		# ----------------------------------------------------
		# SUCCESS
		# ----------------------------------------------------

		"success":

			change("happiness", 0.20)

			change("excitement", 0.15)

			change("contentment", 0.08)

			change("anxiety", -0.05)


		# ----------------------------------------------------
		# FAILURE
		# ----------------------------------------------------

		"failure":

			change("happiness", -0.10)

			change("sadness", 0.10)

			change("frustration", 0.20)

			change("anxiety", 0.10)


		# ----------------------------------------------------
		# SURPRISE
		# ----------------------------------------------------

		"surprise":

			change("excitement", 0.15)

			change("curiosity", 0.20)

			change("anxiety", 0.05)


		# ----------------------------------------------------
		# FRIGHTENING EVENT
		# ----------------------------------------------------

		"frightening_event":

			change("happiness", -0.15)

			change("fear", 0.35)

			change("anxiety", 0.20)

			change("contentment", -0.05)


		# ----------------------------------------------------
		# COMFORTING EVENT
		# ----------------------------------------------------

		"comforting_event":

			change("anxiety", -0.15)

			change("fear", -0.10)

			change("contentment", 0.15)

			change("happiness", 0.05)


		# ----------------------------------------------------
		# UNKNOWN EVENT
		# ----------------------------------------------------

		_:

			push_warning(
				"Unknown emotional event: " + event_name
			)


# ============================================================
# DOMINANT EMOTION
#
# We don't simply ask:
#
#     "Which emotion has the highest number?"
#
# because a character might have:
#
#     Contentment = 0.50
#     Fear       = 0.40
#
# while fear is actually the emotion currently affecting
# her behavior.
#
# Instead we measure how far each emotion has moved from
# its normal baseline.
# ============================================================

func get_dominant_emotion() -> String:

	var emotions := {

		"happiness": happiness,

		"sadness": sadness,

		"anger": anger,

		"fear": fear,

		"anxiety": anxiety,

		"excitement": excitement,

		"curiosity": curiosity,

		"affection": affection,

		"embarrassment": embarrassment,

		"frustration": frustration,

		"loneliness": loneliness,

		"contentment": contentment
	}


	var strongest_name := "neutral"

	var strongest_change := 0.0


	for emotion_name in emotions:

		var current_value: float = (
			emotions[emotion_name]
		)

		var baseline_value: float = (
			baselines[emotion_name]
		)

		var emotional_change: float = (
			current_value - baseline_value
		)


		if emotional_change > strongest_change:

			strongest_change = emotional_change

			strongest_name = emotion_name


	return strongest_name


# ============================================================
# GET INDIVIDUAL EMOTION
# ============================================================

func get_emotion(
	emotion_name: String
) -> float:

	match emotion_name:

		"happiness":
			return happiness

		"sadness":
			return sadness

		"anger":
			return anger

		"fear":
			return fear

		"anxiety":
			return anxiety

		"excitement":
			return excitement

		"curiosity":
			return curiosity

		"affection":
			return affection

		"embarrassment":
			return embarrassment

		"frustration":
			return frustration

		"loneliness":
			return loneliness

		"contentment":
			return contentment


	return 0.0


# ============================================================
# GET EMOTIONAL CHANGE
#
# Returns how far an emotion is above/below its baseline.
# ============================================================

func get_emotional_change(
	emotion_name: String
) -> float:

	var current := get_emotion(
		emotion_name
	)


	if not baselines.has(emotion_name):

		return 0.0


	return (
		current
		- baselines[emotion_name]
	)


# ============================================================
# SUMMARY
# ============================================================

func get_summary() -> String:

	return (

		"Dominant: %s | "

		+ "Valence: %.2f | "

		+ "Arousal: %.2f | "

		+ "Happiness: %.2f | "

		+ "Sadness: %.2f | "

		+ "Anxiety: %.2f | "

		+ "Fear: %.2f | "

		+ "Excitement: %.2f | "

		+ "Affection: %.2f | "

		+ "Contentment: %.2f"

	) % [

		get_dominant_emotion(),

		valence,

		arousal,

		happiness,

		sadness,

		anxiety,

		fear,

		excitement,

		affection,

		contentment
	]
