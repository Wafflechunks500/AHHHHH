extends Node

# ============================================================
# CHARACTER + BRAIN INTEGRATION TEST (Clean Version)
# ============================================================

var profile: CharacterProfile
var brain: CharacterBrain
var controller: CharacterController


func _ready() -> void:
	print("\n========== STARTING CHARACTER + BRAIN TEST ==========\n")

	# 1. Build character identity
	profile = _create_mommy_domme_profile()

	# 2. Create ONE brain
	brain = CharacterBrain.new()
	brain.name = "CharacterBrain"
	add_child(brain)
	
	brain.preferences = profile.preferences

	# Make sure the brain knows a person is present
	if brain.perception:
		brain.perception.person_present = true
		brain.perception.observed_interest = 0.60
		brain.perception.observed_nervousness = 0.25
		brain.perception.observed_friendliness = 0.70

	if "focus_person_id" in brain:
		brain.focus_person_id = "player"

	# 3. Create controller and assign the brain BEFORE adding it to the tree
	controller = CharacterController.new()
	controller.name = "CharacterController"

	# Assign first (very important)
	controller.brain = brain
	controller.preferences = profile.preferences

	# Add to tree AFTER assignment
	add_child(controller)

	# 4. Print identity
	_print_character_identity()

	# 5. Initial brain state
	await get_tree().create_timer(0.6).timeout
	_print_brain_snapshot("INITIAL STATE")

	# 6. Intimate interest test
	await get_tree().create_timer(1.0).timeout
	print("\n--- Running intimate interest push ---")
	_apply_intimate_interest()

	await get_tree().create_timer(1.8).timeout
	_print_brain_snapshot("AFTER INTIMATE INTEREST")

	# 7. Positive social test
	await get_tree().create_timer(1.0).timeout
	print("\n--- Running positive social push ---")
	_apply_positive_social()

	await get_tree().create_timer(1.8).timeout
	_print_brain_snapshot("AFTER POSITIVE SOCIAL")

	print("\n========== TEST COMPLETE ==========\n")


# ============================================================
# CHARACTER CREATION
# ============================================================

func _create_mommy_domme_profile() -> CharacterProfile:
	var p := CharacterProfile.new()
	p.character_id = "victoria_01"
	p.profile_description = "Tall, confident, warm but commanding woman."

	# Biography
	var bio := CharacterBiography.new()
	bio.first_name = "Victoria"
	bio.preferred_name = "Victoria"
	bio.age = 32
	bio.occupation = "Psychologist"
	bio.life_summary = "Confident, emotionally intelligent woman who enjoys taking care of people while staying in control."
	p.biography = bio

	# Appearance
	var app := CharacterAppearance.new()
	app.height_cm = 185.0
	app.body_build = "curvaceous and strong"
	app.body_shape = "hourglass"
	app.skin_tone = "fair"
	app.hair_color = "dark brown"
	app.hair_length = "long"
	app.hair_style = "usually worn down or in a loose updo"
	app.eye_color = "hazel"
	app.fashion_style = "elegant, slightly dominant"
	app.visual_impression = "imposing yet warm presence"
	app.appearance_description = "A very tall, curvaceous woman with an elegant and commanding presence."
	p.appearance = app

	# Preferences
	var pref := CharacterPreferences.new()
	pref.emotional_expressiveness = 0.65
	pref.physical_affection_tendency = 0.70
	pref.verbal_affection_tendency = 0.75
	pref.teasing_tendency = 0.60
	pref.initiative_tendency = 0.85

	pref.romantic_style = "warm_dominant"
	pref.attachment_speed = 0.40
	pref.need_for_emotional_safety = 0.35

	pref.sexual_drive_baseline = 0.70
	pref.sex_emotional_linkage = 0.65
	pref.preferred_intensity = 0.70
	pref.preferred_pace = 0.55
	pref.verbal_during_sex = 0.80
	pref.giving_receiving_balance = 0.75

	pref.dominance_interest = 0.90
	pref.submission_interest = 0.15
	pref.switching_interest = 0.25
	pref.psychological_power_interest = 0.85

	p.preferences = pref
	return p


# ============================================================
# TEST ACTIONS
# ============================================================

func _apply_intimate_interest() -> void:
	# Physiology
	if brain.physiology:
		brain.physiology.arousal = min(brain.physiology.arousal + 0.35, 1.0)

	# Emotion
	if brain.emotion:
		brain.emotion.change("affection", 0.18)
		brain.emotion.change("excitement", 0.15)

	# Motivation
	if brain.motivation:
		brain.motivation.push_motivation("intimacy", 0.55, "test_intimate")
		brain.motivation.push_motivation("pleasure", 0.30, "test_intimate")

	# Relationship
	if brain.relationship_manager:
		var rel = brain.relationship_manager.get_or_create_relationship("player", "Player")
		rel.affection = min(rel.affection + 0.18, 1.0)
		rel.trust = min(rel.trust + 0.12, 1.0)
		rel.closeness = min(rel.closeness + 0.15, 1.0)
		rel.comfort = min(rel.comfort + 0.10, 1.0)

	# Make sure she still sees someone
	if brain.perception:
		brain.perception.person_present = true
		brain.perception.observed_interest = 0.70

	print("Intimate interest applied.")


func _apply_positive_social() -> void:
	if brain.relationship_manager:
		brain.relationship_manager.apply_positive_interaction("player", 0.55)

	if brain.emotion:
		brain.emotion.experience_event("pleasant_social_interaction")

	if brain.motivation:
		brain.motivation.push_motivation("social_connection", 0.40, "test_social")
		brain.motivation.push_motivation("attachment", 0.25, "test_social")

	if brain.perception:
		brain.perception.person_present = true

	print("Positive social applied.")


# ============================================================
# PRINT HELPERS
# ============================================================

func _print_character_identity() -> void:
	print("---------- CHARACTER IDENTITY ----------")
	print("Name: ", profile.get_character_name())
	print("Full description:\n", profile.get_character_description())
	print("\nPreferences summary: ", profile.preferences.get_summary())
	print("----------------------------------------\n")


func _print_brain_snapshot(label: String) -> void:
	print("\n========== BRAIN SNAPSHOT: ", label, " ==========")

	if brain.has_method("print_brain_state"):
		brain.print_brain_state()
	else:
		print(brain.get_brain_state())

	# Clean intention print
	var intention = brain.get_current_intention()
	if intention == null:
		print("Current intention: none")
	elif intention.has_method("get_summary"):
		print("Current intention: ", intention.get_summary())
	elif "action" in intention:
		print("Current intention: %s | Framing: %s | Reason: %s" % [
			intention.action,
			intention.framing if "framing" in intention else "?",
			intention.reason if "reason" in intention else "?"
		])
	else:
		print("Current intention: ", intention)

	print("================================================\n")
