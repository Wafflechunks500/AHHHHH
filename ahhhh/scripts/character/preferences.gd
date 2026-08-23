class_name CharacterPreferences
extends Resource

# Persistent preferences and enduring tendencies. Current desire, arousal,
# mood and moment-to-moment decisions belong to the brain.

@export_range(0.0, 1.0) var emotional_expressiveness: float = 0.55
@export_range(0.0, 1.0) var physical_affection_tendency: float = 0.50
@export_range(0.0, 1.0) var verbal_affection_tendency: float = 0.60
@export_range(0.0, 1.0) var teasing_tendency: float = 0.45
@export_range(0.0, 1.0) var initiative_tendency: float = 0.50

@export var romantic_style: String = "warm"
@export_range(0.0, 1.0) var attachment_speed: float = 0.45
@export_range(0.0, 1.0) var need_for_emotional_safety: float = 0.60

# Broad relationship tendencies exposed by the character creator.
@export_range(0.0, 1.0) var affection_tendency: float = 0.50
@export_range(0.0, 1.0) var commitment_tendency: float = 0.50
@export_range(0.0, 1.0) var romance_tendency: float = 0.50
@export_range(0.0, 1.0) var social_initiative: float = 0.50

@export_range(0.0, 1.0) var sexual_drive_baseline: float = 0.55
@export_range(0.0, 1.0) var sex_emotional_linkage: float = 0.70
@export_range(0.0, 1.0) var preferred_intensity: float = 0.50
@export_range(0.0, 1.0) var preferred_pace: float = 0.40
@export_range(0.0, 1.0) var verbal_during_sex: float = 0.65
@export_range(0.0, 1.0) var giving_receiving_balance: float = 0.55

@export_range(0.0, 1.0) var dominance_interest: float = 0.45
@export_range(0.0, 1.0) var submission_interest: float = 0.40
@export_range(0.0, 1.0) var switching_interest: float = 0.60
@export_range(0.0, 1.0) var psychological_power_interest: float = 0.55

var sexual_interests: Dictionary = {
	"pegging": {
		"base_tags": ["penetration", "power_exchange", "giving"],
		"personal_meaning": "I like the mix of control and care I can show while doing it.",
		"preferred_framings": ["caring_dominance", "playful", "intimate"],
		"intensity_range": {"min": 0.25, "max": 0.85},
		"pace_preference": "variable", "comfort_with_player": 0.0,
		"interest_level": 0.65, "hard_limit": false
	},
	"gentle_sex": {
		"base_tags": ["sensual", "emotional", "slow"],
		"personal_meaning": "When I feel close to someone, I enjoy slow, attentive intimacy.",
		"preferred_framings": ["loving", "tender", "intimate"],
		"intensity_range": {"min": 0.1, "max": 0.6},
		"pace_preference": "slow", "comfort_with_player": 0.3,
		"interest_level": 0.80, "hard_limit": false
	},
	"rough_sex": {
		"base_tags": ["intense", "physical", "power"],
		"personal_meaning": "I can enjoy intensity when I feel very safe and turned on, but it needs trust first.",
		"preferred_framings": ["passionate", "consensual_intensity"],
		"intensity_range": {"min": 0.5, "max": 0.95},
		"pace_preference": "building", "comfort_with_player": 0.0,
		"interest_level": 0.45, "hard_limit": false
	},
	"oral_giving": {
		"base_tags": ["giving", "service", "intimate"],
		"personal_meaning": "I enjoy the focus and the reactions I can get. It feels generous and teasing.",
		"preferred_framings": ["attentive", "eager", "teasing"],
		"intensity_range": {"min": 0.2, "max": 0.9},
		"pace_preference": "variable", "comfort_with_player": 0.2,
		"interest_level": 0.75, "hard_limit": false
	}
}

@export var hard_limits: Array[String] = []
@export var soft_limits: Array[String] = []
@export var curiosities: Array[String] = []

func set_creator_relationship_value(key: String, value: float) -> void:
	var property_name := ""
	match key:
		"affection": property_name = "affection_tendency"
		"commitment": property_name = "commitment_tendency"
		"romance": property_name = "romance_tendency"
		"social_initiative": property_name = "social_initiative"
		_: return
	set(property_name, clampf(value, 0.0, 1.0))

func get_interest(act_id: String) -> Dictionary:
	return sexual_interests.get(act_id, {})

func get_interest_level(act_id: String) -> float:
	return get_interest(act_id).get("interest_level", 0.0)

func is_hard_limit(act_id: String) -> bool:
	if act_id in hard_limits:
		return true
	return get_interest(act_id).get("hard_limit", false)

func get_personal_meaning(act_id: String) -> String:
	return get_interest(act_id).get("personal_meaning", "")

func get_preferred_framings(act_id: String) -> Array:
	return get_interest(act_id).get("preferred_framings", [])

func raise_comfort_with_player(act_id: String, amount: float) -> void:
	if not sexual_interests.has(act_id):
		return
	var current: float = sexual_interests[act_id].get("comfort_with_player", 0.0)
	sexual_interests[act_id]["comfort_with_player"] = clampf(current + amount, 0.0, 1.0)

func get_summary() -> String:
	return "Romantic style: %s | Affection: %.2f | Commitment: %.2f | Romance: %.2f | Social initiative: %.2f" % [romantic_style, affection_tendency, commitment_tendency, romance_tendency, social_initiative]

func get_llm_description() -> String:
	var text := "Romantic & Sexual Preferences:\n"
	text += "- Romantic style: " + romantic_style + "\n"
	text += "- Emotional expressiveness: %.2f\n" % emotional_expressiveness
	text += "- Needs emotional safety: %.2f\n" % need_for_emotional_safety
	text += "- Baseline sexual drive: %.2f\n" % sexual_drive_baseline
	text += "- Preferred intensity: %.2f | Preferred pace: %.2f\n" % [preferred_intensity, preferred_pace]
	text += "- Dominance interest: %.2f | Submission interest: %.2f | Switching: %.2f\n" % [dominance_interest, submission_interest, switching_interest]
	return text
