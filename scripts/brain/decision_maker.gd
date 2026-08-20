class_name CharacterDecisionMaker
extends Resource


# ============================================================
# CHARACTER DECISION MAKER
#
# Turns the character's current internal state into a concrete
# high-level decision / intention.
#
# This system does NOT execute actions.
# It does NOT generate dialogue or animation.
#
# It answers:
#     "Given everything I currently feel, want, believe, and
#      perceive — what should I do right now, and why?"
#
# The output is an Intention that the planner / body / expression
# systems can later realize.
# ============================================================


# ============================================================
# INTENTION STRUCTURE
# ============================================================

class Intention:
	var id: String = ""					# unique-ish identifier
	var action: String = "none"			# high-level action type
	var target_id: String = ""			# who/what the action is directed at
	var priority: float = 0.0			# 0–1 how strongly she wants this
	var urgency: float = 0.0			# 0–1 time pressure
	var confidence: float = 0.5			# how sure she is this is a good idea
	var intensity: float = 0.5			# general intensity / commitment
	var framing: String = "neutral"		# emotional/relational framing
	var reason: String = ""				# human-readable "why"
	var tags: Array[String] = []		# semantic tags (social, intimate, dominant, caring, etc.)
	var parameters: Dictionary = {}		# free-form extra data (pace, location, etc.)

	func _init(
		p_action: String = "none",
		p_target_id: String = "",
		p_priority: float = 0.0
	) -> void:
		action = p_action
		target_id = p_target_id
		priority = clamp(p_priority, 0.0, 1.0)
		id = action + "_" + str(Time.get_ticks_msec())


# ============================================================
# CURRENT DECISION STATE
# ============================================================

var current_intention: Intention = null
var previous_intention: Intention = null

var decision_cooldown: float = 0.0
var min_decision_interval: float = 0.8		# seconds between major re-evaluations

# Last known inputs (set by the brain each update)
var last_physiology: Dictionary = {}
var last_emotion: Dictionary = {}
var last_motivation: Dictionary = {}
var last_personality: Dictionary = {}
var last_perception: Dictionary = {}
var last_relationship: Dictionary = {}		# relationship data for the current focus person
var last_self_model: Dictionary = {}
var last_goals: Array = []


# ============================================================
# MAIN ENTRY POINT
# ============================================================

## Called by CharacterBrain every frame / tick with the latest
## state snapshots from the other systems.
func update(
	delta: float,
	physiology: Dictionary = {},
	emotion: Dictionary = {},
	motivation: Dictionary = {},
	personality: Dictionary = {},
	perception: Dictionary = {},
	relationship: Dictionary = {},
	self_model: Dictionary = {},
	goals: Array = []
) -> void:

	last_physiology = physiology
	last_emotion = emotion
	last_motivation = motivation
	last_personality = personality
	last_perception = perception
	last_relationship = relationship
	last_self_model = self_model
	last_goals = goals

	decision_cooldown = max(decision_cooldown - delta, 0.0)

	# Only re-decide when cooldown is finished or the situation
	# has changed significantly.
	if decision_cooldown <= 0.0 or _situation_changed_significantly():
		var new_intention := _select_intention()
		if new_intention != null:
			_commit_intention(new_intention)
			decision_cooldown = min_decision_interval


# ============================================================
# INTENTION SELECTION
# ============================================================

func _select_intention() -> Intention:
	var candidates: Array[Intention] = []

	# 1. Safety / comfort overrides
	candidates.append_array(_generate_safety_intentions())

	# 2. Social / relational intentions
	candidates.append_array(_generate_social_intentions())

	# 3. Intimate / romantic / sexual intentions
	candidates.append_array(_generate_intimate_intentions())

	# 4. Curiosity / exploration
	candidates.append_array(_generate_curiosity_intentions())

	# 5. Goal-driven intentions
	candidates.append_array(_generate_goal_intentions())

	# 6. Idle / recovery intentions
	candidates.append_array(_generate_idle_intentions())

	if candidates.is_empty():
		return _make_intention("idle", "", 0.1, "neutral", "Nothing particular feels pressing.")

	# Score and pick the best
	var best: Intention = null
	var best_score: float = -1.0

	for candidate in candidates:
		var score := _score_intention(candidate)
		if score > best_score:
			best_score = score
			best = candidate

	return best


# ============================================================
# CANDIDATE GENERATORS
# ============================================================

func _generate_safety_intentions() -> Array[Intention]:
	var results: Array[Intention] = []

	var stress: float = last_physiology.get("stress", 0.0)
	var fear: float = last_emotion.get("fear", 0.0)
	var anxiety: float = last_emotion.get("anxiety", 0.0)
	var comfort: float = last_physiology.get("comfort", 0.5)

	if stress > 0.65 or fear > 0.55 or anxiety > 0.7:
		var strength = max(stress, fear, anxiety)
		results.append(_make_intention(
			"withdraw",
			last_perception.get("focus_person_id", ""),
			strength,
			"self_protective",
			"I feel overwhelmed / unsafe and need space.",
			["safety", "withdrawal"]
		))

	if comfort < 0.3 and stress > 0.4:
		results.append(_make_intention(
			"seek_comfort",
			last_perception.get("focus_person_id", ""),
			0.6,
			"vulnerable",
			"I want to feel safer and more comfortable.",
			["comfort", "support"]
		))

	return results


func _generate_social_intentions() -> Array[Intention]:
	var results: Array[Intention] = []

	var social_drive: float = last_motivation.get("social_connection", 0.0)
	var attachment: float = last_motivation.get("attachment", 0.0)
	var affection: float = last_relationship.get("affection", 0.5)
	var trust: float = last_relationship.get("trust", 0.5)
	var person_present: bool = last_perception.get("person_present", false)

	if not person_present:
		return results

	if social_drive > 0.45 or attachment > 0.4:
		results.append(_make_intention(
			"engage_socially",
			last_perception.get("focus_person_id", ""),
			(social_drive + attachment) * 0.5,
			"friendly",
			"I want connection and interaction.",
			["social", "connection"]
		))

	if affection > 0.65 and trust > 0.55:
		results.append(_make_intention(
			"express_affection",
			last_perception.get("focus_person_id", ""),
			affection * 0.7,
			"warm",
			"I feel close to them and want to show it.",
			["affection", "bonding"]
		))

	return results


func _generate_intimate_intentions() -> Array[Intention]:
	var results: Array[Intention] = []

	var intimacy_drive: float = last_motivation.get("intimacy", 0.0)
	var pleasure: float = last_motivation.get("pleasure", 0.0)
	var arousal: float = last_physiology.get("arousal", 0.0)
	var affection: float = last_relationship.get("affection", 0.0)
	var trust: float = last_relationship.get("trust", 0.0)
	var closeness: float = last_relationship.get("closeness", 0.0)
	var comfort_with_them: float = last_relationship.get("comfort", 0.5)

	# Inferred state of the other person (these keys should be
	# populated by perception + relationship_manager later)
	var their_comfort: float = last_relationship.get("inferred_comfort", 0.5)
	var their_arousal: float = last_relationship.get("inferred_arousal", 0.0)
	var their_nervousness: float = last_relationship.get("inferred_nervousness", 0.0)
	var their_interest: float = last_relationship.get("inferred_interest", 0.5)

	var person_present: bool = last_perception.get("person_present", false)
	if not person_present:
		return results

	# Base willingness to be intimate
	var willingness: float = (
		intimacy_drive * 0.35
		+ pleasure * 0.15
		+ arousal * 0.20
		+ affection * 0.15
		+ trust * 0.10
		+ closeness * 0.05
	)
	willingness = clamp(willingness, 0.0, 1.0)

	# Strongly reduced if she thinks the other person is uncomfortable
	if their_comfort < 0.4 or their_nervousness > 0.65:
		willingness *= 0.35

	if willingness < 0.28:
		return results

	# --- Possible intimate intentions ---

	# Soft / caring intimacy
	if willingness > 0.35 and their_comfort > 0.45:
		var framing := "caring"
		if their_nervousness > 0.4:
			framing = "gentle_reassuring"
		results.append(_make_intention(
			"intimate_soft",
			last_perception.get("focus_person_id", ""),
			willingness * 0.75,
			framing,
			"I want closeness and to make them feel safe and desired.",
			["intimate", "caring", "soft", "affectionate"],
			{"pace": "slow", "check_in": true}
		))

	# Playful / teasing
	if willingness > 0.4 and last_personality.get("playfulness", 0.3) > 0.45:
		results.append(_make_intention(
			"intimate_playful",
			last_perception.get("focus_person_id", ""),
			willingness * 0.7,
			"playful",
			"I feel like teasing and playing with them.",
			["intimate", "playful", "teasing"],
			{"pace": "variable"}
		))

	# More intense / dominant-leaning (only if trust and inferred interest are high)
	if willingness > 0.55 and trust > 0.65 and their_interest > 0.55 and their_comfort > 0.55:
		var intensity_mod: float = lerp(0.45, 0.85, arousal)
		results.append(_make_intention(
			"intimate_intense",
			last_perception.get("focus_person_id", ""),
			willingness * 0.8,
			"confident",
			"I want to take the lead and go further with them.",
			["intimate", "intense", "dominant_leaning"],
			{"pace": "building", "intensity": intensity_mod}
		))

	# Explicit check-in / consent-oriented pause
	if their_nervousness > 0.5 or their_comfort < 0.55:
		results.append(_make_intention(
			"intimate_check_in",
			last_perception.get("focus_person_id", ""),
			0.7,
			"attentive",
			"I want to make sure they're still comfortable and wanting this.",
			["intimate", "caring", "check_in", "consent"],
			{"verbal": true}
		))

	return results


func _generate_curiosity_intentions() -> Array[Intention]:
	var results: Array[Intention] = []
	var curiosity: float = last_motivation.get("curiosity", 0.0)

	if curiosity > 0.55:
		results.append(_make_intention(
			"explore",
			"",
			curiosity * 0.6,
			"curious",
			"I want to understand or try something new.",
			["curiosity", "exploration"]
		))

	return results


func _generate_goal_intentions() -> Array[Intention]:
	var results: Array[Intention] = []
	# Placeholder — later this will read actual goal objects
	# and convert high-priority goals into intentions.
	return results


func _generate_idle_intentions() -> Array[Intention]:
	return [_make_intention(
		"idle",
		"",
		0.15,
		"neutral",
		"Nothing is strongly driving me right now.",
		["idle"]
	)]


# ============================================================
# SCORING
# ============================================================

func _score_intention(intention: Intention) -> float:
	var score: float = intention.priority

	# Personality modulation examples
	var playfulness: float = last_personality.get("playfulness", 0.3)
	var caution: float = last_personality.get("caution", 0.4)
	var empathy: float = last_personality.get("empathy", 0.5)

	if "playful" in intention.tags:
		score *= (0.7 + playfulness * 0.6)

	if "safety" in intention.tags or "withdrawal" in intention.tags:
		score *= (0.6 + caution * 0.7)

	if "caring" in intention.tags or "check_in" in intention.tags:
		score *= (0.7 + empathy * 0.5)

	# Strongly prefer intentions that match dominant motivation
	var dominant: String = last_motivation.get("dominant_motivation", "")
	if dominant == "intimacy" and "intimate" in intention.tags:
		score *= 1.35
	elif dominant == "safety" and "safety" in intention.tags:
		score *= 1.4
	elif dominant == "social_connection" and "social" in intention.tags:
		score *= 1.25

	# Slight inertia — prefer continuing a similar intention
	if previous_intention != null and previous_intention.action == intention.action:
		score *= 1.12

	return clamp(score, 0.0, 1.5)


# ============================================================
# HELPERS
# ============================================================

func _make_intention(
	action: String,
	target_id: String,
	priority: float,
	framing: String,
	reason: String,
	tags: Array[String] = [],
	parameters: Dictionary = {}
) -> Intention:
	var intention := Intention.new(action, target_id, priority)
	intention.framing = framing
	intention.reason = reason
	intention.tags = tags
	intention.parameters = parameters
	intention.confidence = clamp(priority * 0.9 + 0.1, 0.0, 1.0)
	intention.intensity = clamp(priority, 0.2, 1.0)
	return intention


func _commit_intention(intention: Intention) -> void:
	previous_intention = current_intention
	current_intention = intention


func _situation_changed_significantly() -> bool:
	# Simple version — can be made smarter later
	if current_intention == null:
		return true
	var current_arousal: float = last_physiology.get("arousal", 0.0)
	var current_anxiety: float = last_emotion.get("anxiety", 0.0)
	# Add more change detection as needed
	return false


# ============================================================
# PUBLIC ACCESSORS
# ============================================================

func get_current_intention() -> Intention:
	return current_intention


func get_current_action() -> String:
	if current_intention == null:
		return "none"
	return current_intention.action


func get_current_reason() -> String:
	if current_intention == null:
		return ""
	return current_intention.reason


func get_summary() -> String:
	if current_intention == null:
		return "No current intention."
	return "Action: %s | Priority: %.2f | Framing: %s | Reason: %s" % [
		current_intention.action,
		current_intention.priority,
		current_intention.framing,
		current_intention.reason
	]
