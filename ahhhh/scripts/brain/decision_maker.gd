class_name CharacterDecisionMaker
extends Resource


# ============================================================
# CHARACTER DECISION MAKER
#
# Turns the character's current internal state + enduring
# preferences into a concrete high-level intention.
# ============================================================


# ============================================================
# INTENTION STRUCTURE
# ============================================================

class Intention:
	var id: String = ""
	var action: String = "none"
	var target_id: String = ""
	var priority: float = 0.0
	var urgency: float = 0.0
	var confidence: float = 0.5
	var intensity: float = 0.5
	var framing: String = "neutral"
	var reason: String = ""
	var tags: Array[String] = []
	var parameters: Dictionary = {}

	func _init(p_action: String = "none", p_target_id: String = "", p_priority: float = 0.0) -> void:
		action = p_action
		target_id = p_target_id
		priority = clamp(p_priority, 0.0, 1.0)
		id = action + "_" + str(Time.get_ticks_msec())

	func get_summary() -> String:
		return "%s | Framing: %s | Priority: %.2f | Reason: %s" % [action, framing, priority, reason]


# ============================================================
# CURRENT DECISION STATE
# ============================================================

var current_intention: Intention = null
var previous_intention: Intention = null

var decision_cooldown: float = 0.0
var min_decision_interval: float = 0.8

# Last known inputs
var last_physiology: Dictionary = {}
var last_emotion: Dictionary = {}
var last_motivation: Dictionary = {}
var last_personality: Dictionary = {}
var last_perception: Dictionary = {}
var last_relationship: Dictionary = {}
var last_self_model: Dictionary = {}
var last_goals: Array = []
var last_preferences: Dictionary = {}   # ← NEW


# ============================================================
# MAIN ENTRY POINT
# ============================================================

func update(
	delta: float,
	physiology: Dictionary = {},
	emotion: Dictionary = {},
	motivation: Dictionary = {},
	personality: Dictionary = {},
	perception: Dictionary = {},
	relationship: Dictionary = {},
	self_model: Dictionary = {},
	goals: Array = [],
	preferences: Dictionary = {}          # ← NEW
) -> void:

	last_physiology = physiology
	last_emotion = emotion
	last_motivation = motivation
	last_personality = personality
	last_perception = perception
	last_relationship = relationship
	last_self_model = self_model
	last_goals = goals
	last_preferences = preferences

	decision_cooldown = max(decision_cooldown - delta, 0.0)

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

	candidates.append_array(_generate_safety_intentions())
	candidates.append_array(_generate_social_intentions())
	candidates.append_array(_generate_intimate_intentions())
	candidates.append_array(_generate_curiosity_intentions())
	candidates.append_array(_generate_goal_intentions())
	candidates.append_array(_generate_idle_intentions())

	if candidates.is_empty():
		return _make_intention("idle", "", 0.1, "neutral", "Nothing particular feels pressing.")

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

	var initiative: float = last_preferences.get("initiative_tendency", 0.5)
	var verbal_affection: float = last_preferences.get("verbal_affection_tendency", 0.5)

	if not person_present:
		return results

	if social_drive > 0.40 or attachment > 0.35:
		var priority = (social_drive + attachment) * 0.5
		priority *= (0.7 + initiative * 0.5)		# more initiative → more likely to start interaction
		results.append(_make_intention(
			"engage_socially",
			last_perception.get("focus_person_id", ""),
			priority,
			"friendly",
			"I want connection and interaction.",
			["social", "connection"]
		))

	if affection > 0.60 and trust > 0.50:
		var priority = affection * 0.7
		priority *= (0.6 + verbal_affection * 0.6)
		results.append(_make_intention(
			"express_affection",
			last_perception.get("focus_person_id", ""),
			priority,
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

	var their_comfort: float = last_relationship.get("inferred_comfort", 0.5)
	var their_nervousness: float = last_relationship.get("inferred_nervousness", 0.0)
	var their_interest: float = last_relationship.get("inferred_interest", 0.5)

	# Preference values
	var dom_interest: float = last_preferences.get("dominance_interest", 0.45)
	var sub_interest: float = last_preferences.get("submission_interest", 0.40)
	var preferred_intensity: float = last_preferences.get("preferred_intensity", 0.50)
	var preferred_pace: float = last_preferences.get("preferred_pace", 0.40)
	var teasing: float = last_preferences.get("teasing_tendency", 0.45)
	var initiative: float = last_preferences.get("initiative_tendency", 0.50)
	var sex_drive: float = last_preferences.get("sexual_drive_baseline", 0.55)
	var need_safety: float = last_preferences.get("need_for_emotional_safety", 0.60)
	var giving_balance: float = last_preferences.get("giving_receiving_balance", 0.55)

	var person_present: bool = last_perception.get("person_present", false)
	if not person_present:
		return results

	# Base willingness
	var willingness: float = (
		intimacy_drive * 0.30
		+ pleasure * 0.12
		+ arousal * 0.18
		+ affection * 0.15
		+ trust * 0.10
		+ closeness * 0.05
		+ sex_drive * 0.10
	)
	willingness = clamp(willingness, 0.0, 1.0)

	# Reduce if she thinks the other person is uncomfortable
	if their_comfort < 0.4 or their_nervousness > 0.65:
		willingness *= 0.35

	# Characters who need high emotional safety are more cautious
	if need_safety > 0.65 and trust < 0.6:
		willingness *= 0.7

	if willingness < 0.25:
		return results

	# ----- Soft / caring -----
	if willingness > 0.32 and their_comfort > 0.40:
		var framing := "caring"
		if their_nervousness > 0.4:
			framing = "gentle_reassuring"
		var prio = willingness * 0.75
		# Lower dominance characters prefer soft more
		prio *= (1.1 - dom_interest * 0.3)
		results.append(_make_intention(
			"intimate_soft",
			last_perception.get("focus_person_id", ""),
			prio,
			framing,
			"I want closeness and to make them feel safe and desired.",
			["intimate", "caring", "soft", "affectionate"],
			{"pace": "slow" if preferred_pace < 0.45 else "medium", "check_in": true}
		))

	# ----- Playful / teasing -----
	if willingness > 0.38 and teasing > 0.40:
		var prio = willingness * 0.70 * (0.6 + teasing * 0.7)
		results.append(_make_intention(
			"intimate_playful",
			last_perception.get("focus_person_id", ""),
			prio,
			"playful",
			"I feel like teasing and playing with them.",
			["intimate", "playful", "teasing"],
			{"pace": "variable"}
		))

	# ----- Intense / dominant-leaning -----
	if willingness > 0.50 and trust > 0.60 and their_interest > 0.50 and their_comfort > 0.50:
		# Strongly influenced by dominance_interest and preferred_intensity
		var dom_factor = 0.5 + dom_interest * 0.9
		var intensity_factor = 0.6 + preferred_intensity * 0.7
		var prio = willingness * 0.75 * dom_factor * intensity_factor

		if prio > 0.35:		# only generate if it ends up meaningful
			var intensity_mod: float = lerp(0.45, 0.90, (arousal + preferred_intensity) * 0.5)
			results.append(_make_intention(
				"intimate_intense",
				last_perception.get("focus_person_id", ""),
				prio,
				"confident",
				"I want to take the lead and go further with them.",
				["intimate", "intense", "dominant_leaning"],
				{"pace": "building", "intensity": intensity_mod}
			))

	# ----- Check-in (more likely if she needs emotional safety) -----
	if their_nervousness > 0.45 or their_comfort < 0.55 or need_safety > 0.7:
		var prio = 0.55 + need_safety * 0.35
		results.append(_make_intention(
			"intimate_check_in",
			last_perception.get("focus_person_id", ""),
			prio,
			"attentive",
			"I want to make sure they're still comfortable and wanting this.",
			["intimate", "caring", "check_in", "consent"],
			{"verbal": true}
		))

	return results


func _generate_curiosity_intentions() -> Array[Intention]:
	var results: Array[Intention] = []
	var curiosity: float = last_motivation.get("curiosity", 0.0)

	if curiosity > 0.50:
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
	return []


func _generate_idle_intentions() -> Array[Intention]:
	return [_make_intention(
		"idle",
		"",
		0.12,
		"neutral",
		"Nothing is strongly driving me right now.",
		["idle"]
	)]


# ============================================================
# SCORING (heavily influenced by preferences)
# ============================================================

func _score_intention(intention: Intention) -> float:
	var score: float = intention.priority

	var playfulness: float = last_personality.get("playfulness", 0.3)
	var caution: float = last_personality.get("caution", 0.4)
	var empathy: float = last_personality.get("empathy", 0.5)

	# Preference values
	var dom_interest: float = last_preferences.get("dominance_interest", 0.45)
	var sub_interest: float = last_preferences.get("submission_interest", 0.40)
	var teasing: float = last_preferences.get("teasing_tendency", 0.45)
	var preferred_intensity: float = last_preferences.get("preferred_intensity", 0.50)
	var initiative: float = last_preferences.get("initiative_tendency", 0.50)
	var need_safety: float = last_preferences.get("need_for_emotional_safety", 0.60)

	# Tag-based preference modulation
	if "playful" in intention.tags or "teasing" in intention.tags:
		score *= (0.65 + teasing * 0.7 + playfulness * 0.3)

	if "dominant_leaning" in intention.tags or "intense" in intention.tags:
		score *= (0.55 + dom_interest * 0.9)
		score *= (0.7 + preferred_intensity * 0.5)

	if "caring" in intention.tags or "soft" in intention.tags:
		score *= (0.75 + (1.0 - dom_interest) * 0.35)
		score *= (0.8 + need_safety * 0.3)

	if "check_in" in intention.tags or "consent" in intention.tags:
		score *= (0.7 + need_safety * 0.6 + empathy * 0.3)

	if "safety" in intention.tags or "withdrawal" in intention.tags:
		score *= (0.6 + caution * 0.7)

	if "social" in intention.tags:
		score *= (0.75 + initiative * 0.4)

	# Dominant motivation boost
	var dominant: String = last_motivation.get("dominant_motivation", "")
	if dominant == "intimacy" and "intimate" in intention.tags:
		score *= 1.35
	elif dominant == "safety" and "safety" in intention.tags:
		score *= 1.4
	elif dominant == "social_connection" and "social" in intention.tags:
		score *= 1.25

	# Inertia
	if previous_intention != null and previous_intention.action == intention.action:
		score *= 1.12

	return clamp(score, 0.0, 1.6)


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
	intention.intensity = priority
	return intention


func _commit_intention(intention: Intention) -> void:
	previous_intention = current_intention
	current_intention = intention


func _situation_changed_significantly() -> bool:
	# Simple version – can be expanded later
	return false


func get_current_intention() -> Intention:
	return current_intention


func get_summary() -> String:
	if current_intention == null:
		return "none"
	return current_intention.get_summary()
