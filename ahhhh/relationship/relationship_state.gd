class_name RelationshipState
extends Resource

# Controls how an existing character relationship is initialized.
enum StartMode {
	FIRST_MEETING,
	LOAD_SAVED,
	RESTART_FRESH,
	CUSTOM
}

@export var character_id: String = ""
@export var start_mode: StartMode = StartMode.FIRST_MEETING
@export var relationship_score: float = 0.0
@export var familiarity: float = 0.0
@export var trust: float = 0.0
@export var attraction: float = 0.0
@export var affection: float = 0.0
@export var history: Array[String] = []

func reset_to_first_meeting() -> void:
	relationship_score = 0.0
	familiarity = 0.0
	trust = 0.0
	attraction = 0.0
	affection = 0.0
	history.clear()
	start_mode = StartMode.FIRST_MEETING

func reset_fresh() -> void:
	reset_to_first_meeting()
	start_mode = StartMode.RESTART_FRESH

func add_history_event(event_text: String) -> void:
	if not event_text.is_empty():
		history.append(event_text)
