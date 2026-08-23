class_name FirstMeeting
extends RefCounted

# Produces a starting social approach from personality values.
# Values are expected to be normalized 0.0-1.0.
static func choose_approach(personality: Dictionary, rng: RandomNumberGenerator = null) -> Dictionary:
	var confidence: float = personality.get("confidence", 0.5)
	var sociability: float = personality.get("sociability", 0.5)
	var assertiveness: float = personality.get("assertiveness", 0.5)
	var caution: float = personality.get("caution", 0.5)
	var curiosity: float = personality.get("curiosity", 0.5)
	var playfulness: float = personality.get("playfulness", 0.5)
	var interest: float = personality.get("initial_interest", 0.5)

	var approach_score := (
		confidence * 0.25
		+ sociability * 0.20
		+ assertiveness * 0.20
		+ curiosity * 0.10
		+ interest * 0.25
		- caution * 0.20
	)

	var roll := randf() if rng == null else rng.randf()
	var result := {
		"type": "observe",
		"initiative": approach_score,
		"intensity": 0.2,
		"dialogue_style": "reserved",
		"physical_contact": false
	}

	# Very low interest/caution-dominant characters are unlikely to initiate.
	if interest < 0.20 and roll > 0.15:
		result.type = "avoid"
		result.dialogue_style = "disinterested"
		return result

	if approach_score < 0.25:
		result.type = "observe"
		result.dialogue_style = "shy"
		return result

	if approach_score < 0.50:
		result.type = "hesitant_approach"
		result.dialogue_style = "reserved"
		result.intensity = 0.35
		return result

	if approach_score < 0.75:
		result.type = "approach"
		result.dialogue_style = "friendly"
		result.intensity = 0.55
		return result

	# High initiative + confidence + assertiveness can produce a very forward opener.
	result.type = "forward_approach"
	result.dialogue_style = "confident"
	result.intensity = clamp(0.65 + playfulness * 0.25, 0.0, 1.0)
	return result

static func describe_approach(approach: Dictionary) -> String:
	match approach.get("type", "observe"):
		"avoid":
			return "She notices you but shows little interest in approaching."
		"observe":
			return "She occasionally glances your way but remains hesitant to approach."
		"hesitant_approach":
			return "She seems interested but approaches cautiously."
		"approach":
			return "She decides to approach you and start a conversation."
		"forward_approach":
			return "She confidently approaches you and takes the initiative."
	return "She remains observant."
