class_name CharacterBiography
extends Resource


# ============================================================
# CHARACTER BIOGRAPHY
#
# Represents the character's persistent personal background.
#
# Biography describes:
#
#     Who she is
#     Where she came from
#     What her life has been like
#     Important formative experiences
#     Her education and work
#     Her family and upbringing
#     Major life circumstances
#
# Biography is NOT:
#
#     Personality
#     Current emotion
#     Current memory
#     Current relationship state
#     Preferences
#     Goals
#
# Those belong to their respective systems.
#
# Biography provides context that those systems can use.
# ============================================================


# ============================================================
# BASIC IDENTITY
# ============================================================

## Character's given name.

@export var first_name: String = "Evelyn"


## Character's middle name, if any.

@export var middle_name: String = ""


## Character's family name.

@export var last_name: String = ""


## Name the character normally uses.

@export var preferred_name: String = "Evelyn"


## Age of the character.

@export_range(18, 150)
var age: int = 25


## Birthplace or general place of origin.

@export var birthplace: String = ""


## Current hometown or place where she considers herself
## to be from.

@export var hometown: String = ""


## Nationality or cultural background as a descriptive field.

@export var cultural_background: String = ""


## Languages the character knows.

@export var languages: Array[String] = [
	"English"
]


# ============================================================
# FAMILY / UPBRINGING
# ============================================================

## General description of the character's childhood.

@export_multiline
var childhood_summary: String = ""


## General description of the character's family environment.

@export_multiline
var family_background: String = ""


## Description of the relationship the character had with
## her family while growing up.

@export_multiline
var family_relationships: String = ""


## Important family members.
##
## These are descriptive records rather than relationship
## objects. Actual relationship state belongs elsewhere.

var family_members: Array[Dictionary] = []


# ============================================================
# EDUCATION
# ============================================================

## Highest level of education.

@export var education_level: String = ""


## School, university, or other educational institutions.

var educational_history: Array[Dictionary] = []


## Subjects or fields the character has studied.

var studied_subjects: Array[String] = []


## Skills acquired through education.

var educational_skills: Array[String] = []


# ============================================================
# CAREER / WORK
# ============================================================

## Current occupation.

@export var occupation: String = ""


## General description of the character's work.

@export_multiline
var occupation_description: String = ""


## Previous occupations or major work experiences.

var employment_history: Array[Dictionary] = []


## Professional skills.

var professional_skills: Array[String] = []


# ============================================================
# LIFE HISTORY
# ============================================================

## Major events that shaped the character's life.
##
## These are historical facts about her biography.
##
## Detailed remembered experiences belong to the memory system.

var formative_events: Array[Dictionary] = []


## Important places where the character has lived.

var places_lived: Array[String] = []


## Important activities the character has participated in.

var life_experiences: Array[String] = []


## Hobbies or activities that have been part of her life.
##
## These are historical/contextual facts.
## Current interest belongs to preferences and brain systems.

var historical_hobbies: Array[String] = []


# ============================================================
# PERSONAL HISTORY
# ============================================================

## General description of the character's life before the
## simulation begins.

@export_multiline
var life_summary: String = ""


## Things the character has historically been known for.

var notable_traits: Array[String] = []


## Important accomplishments.

var accomplishments: Array[String] = []


## Significant failures, setbacks, or difficult experiences.
##
## These are historical facts.
## Their emotional impact belongs to memory/emotion/self-model.

var setbacks: Array[String] = []


# ============================================================
# SOCIAL HISTORY
# ============================================================

## General description of the character's social history.

@export_multiline
var social_history: String = ""


## Important historical friendships.

var past_friendships: Array[String] = []


## Important previous romantic relationships.
##
## Detailed relationship state belongs to the relationship system.

var past_relationships: Array[Dictionary] = []


## General description of previous social environments.

var social_environments: Array[String] = []


# ============================================================
# PERSONAL DEVELOPMENT
# ============================================================

## Things the character learned through life experience.

var learned_lessons: Array[String] = []


## Beliefs that were strongly influenced by her upbringing
## or life history.
##
## Current beliefs may eventually be represented elsewhere.

var formative_beliefs: Array[String] = []


## Habits that developed historically.

var historical_habits: Array[String] = []


## Fears that originated from past experiences.
##
## This is historical context, not current fear intensity.

var historical_fears: Array[String] = []


# ============================================================
# IMPORTANT PEOPLE
# ============================================================

## People who played important roles in the character's life.
##
## These are biography records.
## Current relationships should be handled by the relationship
## system.

var important_people: Array[Dictionary] = []


func add_important_person(
	person_id: String,
	name: String,
	role: String,
	description: String = ""
) -> void:

	if person_id.strip_edges() == "":
		return

	var person := {
		"id": person_id,
		"name": name,
		"role": role,
		"description": description
	}

	important_people.append(person)


func get_important_person(
	person_id: String
) -> Dictionary:

	for person in important_people:

		if person.get("id", "") == person_id:
			return person

	return {}


# ============================================================
# FAMILY
# ============================================================

func add_family_member(
	person_id: String,
	name: String,
	role: String,
	description: String = ""
) -> void:

	if person_id.strip_edges() == "":
		return

	var member := {
		"id": person_id,
		"name": name,
		"role": role,
		"description": description
	}

	family_members.append(member)


func get_family_member(
	person_id: String
) -> Dictionary:

	for member in family_members:

		if member.get("id", "") == person_id:
			return member

	return {}


# ============================================================
# EDUCATION
# ============================================================

func add_education(
	institution: String,
	field: String,
	start_year: int = 0,
	end_year: int = 0,
	description: String = ""
) -> void:

	var record := {
		"institution": institution,
		"field": field,
		"start_year": start_year,
		"end_year": end_year,
		"description": description
	}

	educational_history.append(record)


# ============================================================
# EMPLOYMENT
# ============================================================

func add_employment(
	employer: String,
	position: String,
	start_year: int = 0,
	end_year: int = 0,
	description: String = ""
) -> void:

	var record := {
		"employer": employer,
		"position": position,
		"start_year": start_year,
		"end_year": end_year,
		"description": description
	}

	employment_history.append(record)


# ============================================================
# FORMATIVE EVENTS
# ============================================================

func add_formative_event(
	event_name: String,
	description: String,
	age_at_event: int = -1,
	significance: float = 0.5
) -> void:

	var event := {
		"name": event_name,
		"description": description,
		"age": age_at_event,
		"significance": clamp(significance, 0.0, 1.0)
	}

	formative_events.append(event)


func get_formative_event(
	event_name: String
) -> Dictionary:

	for event in formative_events:

		if event.get("name", "") == event_name:
			return event

	return {}


# ============================================================
# HISTORICAL INFORMATION
# ============================================================

func add_life_experience(
	experience: String
) -> void:

	if experience.strip_edges() == "":
		return

	if not life_experiences.has(experience):
		life_experiences.append(experience)


func add_historical_hobby(
	hobby: String
) -> void:

	if hobby.strip_edges() == "":
		return

	if not historical_hobbies.has(hobby):
		historical_hobbies.append(hobby)


func add_learned_lesson(
	lesson: String
) -> void:

	if lesson.strip_edges() == "":
		return

	if not learned_lessons.has(lesson):
		learned_lessons.append(lesson)


func add_formative_belief(
	belief: String
) -> void:

	if belief.strip_edges() == "":
		return

	if not formative_beliefs.has(belief):
		formative_beliefs.append(belief)


func add_historical_habit(
	habit: String
) -> void:

	if habit.strip_edges() == "":
		return

	if not historical_habits.has(habit):
		historical_habits.append(habit)


func add_historical_fear(
	fear: String
) -> void:

	if fear.strip_edges() == "":
		return

	if not historical_fears.has(fear):
		historical_fears.append(fear)


# ============================================================
# NAME
# ============================================================

func get_full_name() -> String:

	var parts: Array[String] = []

	if first_name.strip_edges() != "":
		parts.append(first_name)

	if middle_name.strip_edges() != "":
		parts.append(middle_name)

	if last_name.strip_edges() != "":
		parts.append(last_name)

	return " ".join(parts)


func get_display_name() -> String:

	if preferred_name.strip_edges() != "":
		return preferred_name

	return get_full_name()


# ============================================================
# AGE
# ============================================================

func get_age_description() -> String:

	return "%d years old" % age


# ============================================================
# BIOGRAPHICAL CONTEXT
# ============================================================

## Returns the most relevant persistent information about the
## character for other systems.

func get_biographical_state() -> Dictionary:

	return {
		"name": get_display_name(),
		"full_name": get_full_name(),
		"age": age,
		"birthplace": birthplace,
		"hometown": hometown,
		"cultural_background": cultural_background,
		"languages": languages,
		"occupation": occupation,
		"education_level": education_level,
		"childhood_summary": childhood_summary,
		"family_background": family_background,
		"life_summary": life_summary
	}


# ============================================================
# CONTEXT DESCRIPTION
# ============================================================

## Produces a compact human-readable description of the
## character's background.
##
## This is intended for higher-level systems and eventually
## language generation.

func get_context_description() -> String:

	var text := ""

	text += "Name: " + get_display_name() + "\n"
	text += "Age: %d\n" % age

	if birthplace != "":
		text += "Birthplace: " + birthplace + "\n"

	if hometown != "":
		text += "Hometown: " + hometown + "\n"

	if cultural_background != "":
		text += "Cultural background: " + cultural_background + "\n"

	if education_level != "":
		text += "Education: " + education_level + "\n"

	if occupation != "":
		text += "Occupation: " + occupation + "\n"

	if childhood_summary != "":
		text += "Childhood: " + childhood_summary + "\n"

	if family_background != "":
		text += "Family background: " + family_background + "\n"

	if life_summary != "":
		text += "Life summary: " + life_summary + "\n"

	if studied_subjects.size() > 0:
		text += "Studied: " + ", ".join(studied_subjects) + "\n"

	if professional_skills.size() > 0:
		text += "Professional skills: " \
			+ ", ".join(professional_skills) + "\n"

	if historical_hobbies.size() > 0:
		text += "Historical hobbies: " \
			+ ", ".join(historical_hobbies) + "\n"

	return text.strip_edges()


# ============================================================
# DEBUG SUMMARY
# ============================================================

func get_summary() -> String:

	return (
		"Name: %s | " +
		"Age: %d | " +
		"Occupation: %s | " +
		"Education: %s | " +
		"Family members: %d | " +
		"Formative events: %d | " +
		"Important people: %d"
	) % [
		get_display_name(),
		age,
		occupation,
		education_level,
		family_members.size(),
		formative_events.size(),
		important_people.size()
	]


# ============================================================
# DEBUG
# ============================================================

func print_state() -> void:

	print("========================================")
	print("CHARACTER BIOGRAPHY")
	print("========================================")

	print("Name: ", get_display_name())
	print("Full name: ", get_full_name())
	print("Age: ", age)

	if birthplace != "":
		print("Birthplace: ", birthplace)

	if hometown != "":
		print("Hometown: ", hometown)

	if occupation != "":
		print("Occupation: ", occupation)

	if education_level != "":
		print("Education: ", education_level)

	print("Family members: ", family_members.size())
	print("Important people: ", important_people.size())
	print("Formative events: ", formative_events.size())
	print("Life experiences: ", life_experiences.size())
	print("Historical hobbies: ", historical_hobbies.size())
	print("Learned lessons: ", learned_lessons.size())

	print("========================================")
