extends Node


var emotions: CharacterEmotion


func _ready() -> void:

	emotions = CharacterEmotion.new()

	print("")
	print("========================================")
	print("EMOTION SYSTEM TEST")
	print("========================================")

	print(emotions.get_summary())

	print("")
	print("Testing pleasant social interaction...")

	emotions.experience_event(
		"pleasant_social_interaction"
	)

	print(emotions.get_summary())

	print("")
	print("Testing rejection...")

	emotions.experience_event(
		"rejection"
	)

	print(emotions.get_summary())

	print("")
	print("Testing frightening event...")

	emotions.experience_event(
		"frightening_event"
	)

	print(emotions.get_summary())

	print("")
	print("========================================")
	print("TEST COMPLETE")
	print("========================================")
