class_name CharacterPreferences
extends Resource


# ============================================================
# CHARACTER PREFERENCES
#
# This is the character's enduring tastes, tendencies, and
# boundaries.
#
# It answers questions like:
#   - How does she tend to express affection?
#   - What kind of romantic dynamic feels natural to her?
#   - What sexual acts/dynamics is she drawn to, and why?
#   - What are her soft and hard limits?
#   - How does she usually like things to feel (pace, intensity, emotional framing)?
#
# This is NOT her current temporary state.
# Current desire, arousal, and mood live in the brain systems.
# ============================================================


# ============================================================
# GENERAL PERSONALITY EXPRESSION
# ============================================================

## How openly she tends to show emotion (0 = very reserved, 1 = very expressive)
@export_range(0.0, 1.0) var emotional_expressiveness: float = 0.55

## How physically affectionate she tends to be
@export_range(0.0, 1.0) var physical_affection_tendency: float = 0.50

## How verbally affectionate / complimentary she tends to be
@export_range(0.0, 1.0) var verbal_affection_tendency: float = 0.60

## How much she enjoys teasing / playfulness in relationships
@export_range(0.0, 1.0) var teasing_tendency: float = 0.45

## How much she likes taking the lead vs following
@export_range(0.0, 1.0) var initiative_tendency: float = 0.50


# ============================================================
# ROMANTIC STYLE
# ============================================================

## Preferred overall romantic tone
## Examples: "warm", "playful", "intense", "gentle", "reserved", "passionate"
@export var romantic_style: String = "warm"

## How quickly she tends to develop emotional attachment
@export_range(0.0, 1.0) var attachment_speed: float = 0.45

## How much emotional safety she needs before opening up
@export_range(0.0, 1.0) var need_for_emotional_safety: float = 0.60


# ============================================================
# SEXUAL CORE
# ============================================================

## Overall sexual appetite / drive baseline (not current arousal)
@export_range(0.0, 1.0) var sexual_drive_baseline: float = 0.55

## How strongly sex is linked to emotional intimacy for her
@export_range(0.0, 1.0) var sex_emotional_linkage: float = 0.70

## Preferred general intensity
@export_range(0.0, 1.0) var preferred_intensity: float = 0.50

## Preferred pace (0 = very slow/sensual, 1 = fast/urgent)
@export_range(0.0, 1.0) var preferred_pace: float = 0.40

## How much she likes verbal communication during sex
@export_range(0.0, 1.0) var verbal_during_sex: float = 0.65

## How much she likes giving vs receiving (0 = strongly prefers receiving, 1 = strongly prefers giving)
@export_range(0.0, 1.0) var giving_receiving_balance: float = 0.55


# ============================================================
# POWER DYNAMIC TENDENCIES
# ============================================================

## Comfort / interest in being dominant
@export_range(0.0, 1.0) var dominance_interest: float = 0.45

## Comfort / interest in being submissive
@export_range(0.0, 1.0) var submission_interest: float = 0.40

## Interest in switching
@export_range(0.0, 1.0) var switching_interest: float = 0.60

## How much she enjoys power exchange as emotional/psychological vs purely physical
@export_range(0.0, 1.0) var psychological_power_interest: float = 0.55


# ============================================================
# KINK / ACT KNOWLEDGE
# ============================================================

## Structured data about specific acts and dynamics.
## Each entry contains:
##   - base semantic associations
##   - her personal meaning / "why"
##   - preferred framings
##   - intensity comfort range
##   - current comfort level with the player (dynamic)
##
## This allows the same act (e.g. pegging) to be understood
## as dominant, caring, playful, intense, etc. depending on context.

var sexual_interests: Dictionary = {
	# Example structure — expand this over time
	"pegging": {
		"base_tags": ["penetration", "power_exchange", "giving"],
		"personal_meaning": "I like the mix of control and care I can show while doing it. It can feel powerful but also intimate.",
		"preferred_framings": ["caring_dominance", "playful", "intimate"],
		"intensity_range": {"min": 0.25, "max": 0.85},
		"pace_preference": "variable",
		"comfort_with_player": 0.0,          # rises with positive experiences
		"interest_level": 0.65,
		"hard_limit": false
	},
	"gentle_sex": {
		"base_tags": ["sensual", "emotional", "slow"],
		"personal_meaning": "When I feel close to someone, I really enjoy slow, attentive sex that feels connected.",
		"preferred_framings": ["loving", "tender", "intimate"],
		"intensity_range": {"min": 0.1, "max": 0.6},
		"pace_preference": "slow",
		"comfort_with_player": 0.3,
		"interest_level": 0.80,
		"hard_limit": false
	},
	"rough_sex": {
		"base_tags": ["intense", "physical", "power"],
		"personal_meaning": "I can enjoy intensity when I feel very safe and turned on, but it needs trust first.",
		"preferred_framings": ["passionate", "consensual_intensity"],
		"intensity_range": {"min": 0.5, "max": 0.95},
		"pace_preference": "building",
		"comfort_with_player": 0.0,
		"interest_level": 0.45,
		"hard_limit": false
	},
	"oral_giving": {
		"base_tags": ["giving", "service", "intimate"],
		"personal_meaning": "I enjoy the focus and the reactions I can get. It feels generous and hot.",
		"preferred_framings": ["attentive", "eager", "teasing"],
		"intensity_range": {"min": 0.2, "max": 0.9},
		"pace_preference": "variable",
		"comfort_with_player": 0.2,
		"interest_level": 0.75,
		"hard_limit": false
	}
	# Add more acts/kinks over time following the same structure
}


# ============================================================
# LIMITS & BOUNDARIES
# ============================================================

## Hard limits (things she will not do)
@export var hard_limits: Array[String] = [
	# e.g. "scat", "extreme_pain", "non_con", etc.
]

## Soft limits (possible with high trust / specific framing)
@export var soft_limits: Array[String] = [
	# e.g. "light_pain", "degradation", etc.
]

## Things she is curious about but hasn't tried or decided on yet
@export var curiosities: Array[String] = []


# ============================================================
# HELPER METHODS
# ============================================================

func get_interest(act_id: String) -> Dictionary:
	if sexual_interests.has(act_id):
		return sexual_interests[act_id]
	return {}


func get_interest_level(act_id: String) -> float:
	var data = get_interest(act_id)
	return data.get("interest_level", 0.0)


func is_hard_limit(act_id: String) -> bool:
	if act_id in hard_limits:
		return true
	var data = get_interest(act_id)
	return data.get("hard_limit", false)


func get_personal_meaning(act_id: String) -> String:
	var data = get_interest(act_id)
	return data.get("personal_meaning", "")


func get_preferred_framings(act_id: String) -> Array:
	var data = get_interest(act_id)
	return data.get("preferred_framings", [])


func raise_comfort_with_player(act_id: String, amount: float) -> void:
	if not sexual_interests.has(act_id):
		return
	var current = sexual_interests[act_id].get("comfort_with_player", 0.0)
	sexual_interests[act_id]["comfort_with_player"] = clamp(current + amount, 0.0, 1.0)


func get_summary() -> String:
	return "Romantic style: %s | Sexual drive: %.2f | Dominance interest: %.2f | Submission interest: %.2f | Preferred intensity: %.2f" % [
		romantic_style,
		sexual_drive_baseline,
		dominance_interest,
		submission_interest,
		preferred_intensity
	]


func get_llm_description() -> String:
	# Clean text block specifically for sending to an LLM
	var text := "Romantic & Sexual Preferences:\n"
	text += "- Romantic style: " + romantic_style + "\n"
	text += "- Emotional expressiveness: %.2f\n" % emotional_expressiveness
	text += "- Needs emotional safety: %.2f\n" % need_for_emotional_safety
	text += "- Baseline sexual drive: %.2f\n" % sexual_drive_baseline
	text += "- Sex linked to emotion: %.2f\n" % sex_emotional_linkage
	text += "- Preferred intensity: %.2f | Preferred pace: %.2f\n" % [preferred_intensity, preferred_pace]
	text += "- Dominance interest: %.2f | Submission interest: %.2f | Switching: %.2f\n" % [
		dominance_interest, submission_interest, switching_interest
	]

	text += "\nSpecific Interests:\n"
	for act_id in sexual_interests:
		var data = sexual_interests[act_id]
		text += "- " + act_id + ": " + data.get("personal_meaning", "") + "\n"

	if hard_limits.size() > 0:
		text += "\nHard limits: " + ", ".join(hard_limits) + "\n"

	return text
