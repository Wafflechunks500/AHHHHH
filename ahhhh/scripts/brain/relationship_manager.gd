class_name CharacterRelationshipManager
extends Resource


# ============================================================
# CHARACTER RELATIONSHIP MANAGER
#
# Stores the character's internal relationships with other
# individuals.
#
# IMPORTANT:
#
# A relationship is NOT the same thing as objective reality.
#
# Example:
#
#     Objective:
#         Alice is friendly.
#
#     Character's relationship model:
#         "I trust Alice."
#         "I feel close to Alice."
#         "I am somewhat attached to Alice."
#
# These values represent the character's current internal
# relationship model.
#
# Relationships can change through:
#
#     - interactions
#     - memories
#     - positive experiences
#     - negative experiences
#     - trust violations
#     - emotional support
#     - shared experiences
#     - time
#
# Each individual gets their own relationship record.
# ============================================================


# ============================================================
# RELATIONSHIP DATA
# ============================================================

class RelationshipData:

	# --------------------------------------------------------
	# IDENTIFICATION
	# --------------------------------------------------------

	var character_id: String = ""

	var display_name: String = ""


	# --------------------------------------------------------
	# BASIC SOCIAL VALUES
	# --------------------------------------------------------

	## How much the character currently likes this person.

	var affection: float = 0.50


	## How much the character trusts this person.

	var trust: float = 0.50


	## How emotionally close the character feels to this person.

	var closeness: float = 0.00


	## How emotionally attached the character is.

	var attachment: float = 0.00


	## How comfortable the character feels around this person.

	var comfort: float = 0.50


	## How much respect the character has for this person.

	var respect: float = 0.50


	## How much the character fears this person.

	var fear: float = 0.00


	## How suspicious the character is of this person.

	var suspicion: float = 0.00


	## How dependent the character feels on this person.

	var dependence: float = 0.00


	# --------------------------------------------------------
	# SOCIAL IMPORTANCE
	# --------------------------------------------------------

	## How important this person currently is to the character.

	var importance: float = 0.00


	## How frequently the character interacts with this person.

	var interaction_frequency: float = 0.00


	## How recently the character interacted with this person.

	var time_since_interaction: float = 0.0


	# --------------------------------------------------------
	# RELATIONSHIP TYPE
	# --------------------------------------------------------

	## Broad relationship classification.
	##
	## Examples:
	##
	## "stranger"
	## "acquaintance"
	## "friend"
	## "close_friend"
	## "family"
	## "romantic"
	## "partner"
	## "rival"
	## "enemy"

	var relationship_type: String = "stranger"


	# --------------------------------------------------------
	# HISTORY
	# --------------------------------------------------------

	## Number of meaningful positive interactions.

	var positive_interactions: int = 0


	## Number of meaningful negative interactions.

	var negative_interactions: int = 0


	## Number of significant trust violations.

	var trust_violations: int = 0


	## Number of times this person provided meaningful support.

	var support_events: int = 0


	# --------------------------------------------------------
	# CURRENT STATE
	# --------------------------------------------------------

	## Whether the person is currently nearby.

	var currently_present: bool = false


	## Whether the character is currently interacting with them.

	var currently_interacting: bool = false


	## Most recent significant relationship event.

	var recent_event: String = ""


	## Strength of the most recent relationship event.

	var recent_event_strength: float = 0.0


	# --------------------------------------------------------
	# CONSTRUCTOR
	# --------------------------------------------------------

	func _init(
		new_character_id: String = "",
		new_display_name: String = ""
	) -> void:

		character_id = new_character_id

		display_name = new_display_name


	# --------------------------------------------------------
	# DERIVED VALUES
	# --------------------------------------------------------

	## General positive relationship quality.

	func get_relationship_quality() -> float:

		return clamp(
			(
				affection * 0.25
				+ trust * 0.25
				+ closeness * 0.20
				+ comfort * 0.15
				+ respect * 0.15
			),
			0.0,
			1.0
		)


	## Overall emotional attachment.

	func get_emotional_attachment() -> float:

		return clamp(
			(
				attachment * 0.55
				+ closeness * 0.25
				+ importance * 0.20
			),
			0.0,
			1.0
		)


	## How socially threatening the relationship currently feels.

	func get_relationship_threat() -> float:

		return clamp(
			(
				fear * 0.40
				+ suspicion * 0.30
				+ (1.0 - trust) * 0.30
			),
			0.0,
			1.0
		)


	## How strongly this person currently matters to the
	## character.

	func get_social_importance() -> float:

		return clamp(
			(
				importance * 0.40
				+ attachment * 0.25
				+ closeness * 0.20
				+ interaction_frequency * 0.15
			),
			0.0,
			1.0
		)


	## Returns a simple relationship classification based on
	## the current numerical state.

	func get_derived_relationship_type() -> String:

		if fear > 0.75 and suspicion > 0.65:
			return "feared"

		if affection < 0.20 and trust < 0.20:
			return "hostile"

		if affection < 0.35 and trust < 0.35:
			return "distrusted"

		if attachment > 0.75 and closeness > 0.70:
			return "deeply_attached"

		if affection > 0.70 and closeness > 0.65:
			return "close_friend"

		if affection > 0.60 and trust > 0.60:
			return "friend"

		if trust > 0.40 or affection > 0.40:
			return "acquaintance"

		return "stranger"


# ============================================================
# RELATIONSHIP STORAGE
# ============================================================

var relationships: Dictionary = {}


# ============================================================
# CREATE / ACCESS RELATIONSHIPS
# ============================================================

## Creates a relationship record if one does not already exist.

func add_relationship(
	character_id: String,
	display_name: String = ""
) -> RelationshipData:

	if character_id.is_empty():
		return null


	if relationships.has(character_id):

		var existing: RelationshipData = relationships[
			character_id
		]

		if display_name != "":
			existing.display_name = display_name

		return existing


	var relationship := RelationshipData.new(
		character_id,
		display_name
	)

	relationships[character_id] = relationship

	return relationship


## Returns a relationship if it exists.

func get_relationship(
	character_id: String
) -> RelationshipData:

	if not relationships.has(character_id):
		return null

	return relationships[character_id]


## Creates a relationship if necessary and returns it.

func get_or_create_relationship(
	character_id: String,
	display_name: String = ""
) -> RelationshipData:

	var relationship := get_relationship(
		character_id
	)

	if relationship != null:
		return relationship

	return add_relationship(
		character_id,
		display_name
	)


## Removes a relationship.

func remove_relationship(
	character_id: String
) -> void:

	relationships.erase(
		character_id
	)


## Returns whether a relationship exists.

func has_relationship(
	character_id: String
) -> bool:

	return relationships.has(
		character_id
	)


# ============================================================
# RELATIONSHIP EVENTS
# ============================================================

## Apply a positive interaction.
##
## Examples:
##
##     friendly conversation
##     helping the character
##     spending enjoyable time together
##     emotional support

func apply_positive_interaction(
	character_id: String,
	strength: float
) -> void:

	var relationship := get_or_create_relationship(
		character_id
	)

	if relationship == null:
		return

	strength = clamp(
		strength,
		0.0,
		1.0
	)

	relationship.affection = clamp(
		relationship.affection
		+ strength * 0.08,
		0.0,
		1.0
	)

	relationship.trust = clamp(
		relationship.trust
		+ strength * 0.06,
		0.0,
		1.0
	)

	relationship.closeness = clamp(
		relationship.closeness
		+ strength * 0.08,
		0.0,
		1.0
	)

	relationship.comfort = clamp(
		relationship.comfort
		+ strength * 0.05,
		0.0,
		1.0
	)

	relationship.importance = clamp(
		relationship.importance
		+ strength * 0.03,
		0.0,
		1.0
	)

	relationship.positive_interactions += 1

	relationship.recent_event = "positive_interaction"

	relationship.recent_event_strength = strength


## Apply a negative interaction.
##
## Examples:
##
##     argument
##     insult
##     rejection
##     betrayal
##     harmful behavior

func apply_negative_interaction(
	character_id: String,
	strength: float
) -> void:

	var relationship := get_or_create_relationship(
		character_id
	)

	if relationship == null:
		return

	strength = clamp(
		strength,
		0.0,
		1.0
	)

	relationship.affection = clamp(
		relationship.affection
		- strength * 0.10,
		0.0,
		1.0
	)

	relationship.trust = clamp(
		relationship.trust
		- strength * 0.08,
		0.0,
		1.0
	)

	relationship.closeness = clamp(
		relationship.closeness
		- strength * 0.05,
		0.0,
		1.0
	)

	relationship.comfort = clamp(
		relationship.comfort
		- strength * 0.08,
		0.0,
		1.0
	)

	relationship.suspicion = clamp(
		relationship.suspicion
		+ strength * 0.08,
		0.0,
		1.0
	)

	relationship.negative_interactions += 1

	relationship.recent_event = "negative_interaction"

	relationship.recent_event_strength = strength


## Apply a major trust violation.

func apply_trust_violation(
	character_id: String,
	strength: float
) -> void:

	var relationship := get_or_create_relationship(
		character_id
	)

	if relationship == null:
		return

	strength = clamp(
		strength,
		0.0,
		1.0
	)

	relationship.trust = clamp(
		relationship.trust
		- strength * 0.30,
		0.0,
		1.0
	)

	relationship.suspicion = clamp(
		relationship.suspicion
		+ strength * 0.25,
		0.0,
		1.0
	)

	relationship.affection = clamp(
		relationship.affection
		- strength * 0.15,
		0.0,
		1.0
	)

	relationship.trust_violations += 1

	relationship.recent_event = "trust_violation"

	relationship.recent_event_strength = strength


## Apply emotional support from another person.

func apply_support(
	character_id: String,
	strength: float
) -> void:

	var relationship := get_or_create_relationship(
		character_id
	)

	if relationship == null:
		return

	strength = clamp(
		strength,
		0.0,
		1.0
	)

	relationship.trust = clamp(
		relationship.trust
		+ strength * 0.10,
		0.0,
		1.0
	)

	relationship.closeness = clamp(
		relationship.closeness
		+ strength * 0.12,
		0.0,
		1.0
	)

	relationship.attachment = clamp(
		relationship.attachment
		+ strength * 0.08,
		0.0,
		1.0
	)

	relationship.comfort = clamp(
		relationship.comfort
		+ strength * 0.08,
		0.0,
		1.0
	)

	relationship.support_events += 1

	relationship.recent_event = "received_support"

	relationship.recent_event_strength = strength


# ============================================================
# PRESENCE
# ============================================================

## Mark a person as currently present.

func set_person_present(
	character_id: String,
	present: bool
) -> void:

	var relationship := get_or_create_relationship(
		character_id
	)

	if relationship == null:
		return

	relationship.currently_present = present


## Mark whether the character is currently interacting with
## someone.

func set_interacting(
	character_id: String,
	interacting: bool
) -> void:

	var relationship := get_or_create_relationship(
		character_id
	)

	if relationship == null:
		return

	relationship.currently_interacting = interacting


# ============================================================
# TIME UPDATE
# ============================================================

## Update relationship-related time values.
##
## This does NOT dramatically decay relationships.
##
## Long-term relationships should persist unless experiences
## actively change them.

func update(delta: float) -> void:

	if delta <= 0.0:
		return


	for character_id in relationships:

		var relationship: RelationshipData = relationships[
			character_id
		]

		relationship.time_since_interaction += delta


		# ----------------------------------------------------
		# Interaction frequency slowly settles toward zero
		# when interaction stops.
		# ----------------------------------------------------

		relationship.interaction_frequency = move_toward(
			relationship.interaction_frequency,
			0.0,
			delta * 0.0005
		)


		# ----------------------------------------------------
		# Temporary presence state does not automatically
		# change the underlying relationship.
		# ----------------------------------------------------


# ============================================================
# INTERACTION RECORDING
# ============================================================

func record_interaction(
	character_id: String
) -> void:

	var relationship := get_or_create_relationship(
		character_id
	)

	if relationship == null:
		return

	relationship.time_since_interaction = 0.0

	relationship.interaction_frequency = clamp(
		relationship.interaction_frequency + 0.05,
		0.0,
		1.0
	)


# ============================================================
# RELATIONSHIP QUERIES
# ============================================================

## Returns the character with whom the character currently
## has the strongest emotional bond.

func get_most_attached_person() -> RelationshipData:

	var result: RelationshipData = null

	var highest_attachment := -1.0


	for character_id in relationships:

		var relationship: RelationshipData = relationships[
			character_id
		]

		var attachment_value := (
			relationship.get_emotional_attachment()
		)

		if attachment_value > highest_attachment:

			highest_attachment = attachment_value

			result = relationship


	return result


## Returns the person the character trusts most.

func get_most_trusted_person() -> RelationshipData:

	var result: RelationshipData = null

	var highest_trust := -1.0


	for character_id in relationships:

		var relationship: RelationshipData = relationships[
			character_id
		]

		if relationship.trust > highest_trust:

			highest_trust = relationship.trust

			result = relationship


	return result


## Returns the person currently considered most important.

func get_most_important_person() -> RelationshipData:

	var result: RelationshipData = null

	var highest_importance := -1.0


	for character_id in relationships:

		var relationship: RelationshipData = relationships[
			character_id
		]

		var importance_value := (
			relationship.get_social_importance()
		)

		if importance_value > highest_importance:

			highest_importance = importance_value

			result = relationship


	return result


## Return all currently present people.

func get_present_people() -> Array[RelationshipData]:

	var result: Array[RelationshipData] = []


	for character_id in relationships:

		var relationship: RelationshipData = relationships[
			character_id
		]

		if relationship.currently_present:

			result.append(
				relationship
			)


	return result


# ============================================================
# RELATIONSHIP COUNT
# ============================================================

func get_relationship_count() -> int:

	return relationships.size()


# ============================================================
# DEBUG
# ============================================================

func print_relationship(
	character_id: String
) -> void:

	var relationship := get_relationship(
		character_id
	)

	if relationship == null:

		print(
			"No relationship found for: ",
			character_id
		)

		return


	print("========================================")
	print("RELATIONSHIP")
	print("========================================")

	print(
		"ID: ",
		relationship.character_id
	)

	print(
		"Name: ",
		relationship.display_name
	)

	print(
		"Type: ",
		relationship.relationship_type
	)

	print(
		"Derived type: ",
		relationship.get_derived_relationship_type()
	)

	print(
		"Affection: %.2f"
		% relationship.affection
	)

	print(
		"Trust: %.2f"
		% relationship.trust
	)

	print(
		"Closeness: %.2f"
		% relationship.closeness
	)

	print(
		"Attachment: %.2f"
		% relationship.attachment
	)

	print(
		"Comfort: %.2f"
		% relationship.comfort
	)

	print(
		"Respect: %.2f"
		% relationship.respect
	)

	print(
		"Fear: %.2f"
		% relationship.fear
	)

	print(
		"Suspicion: %.2f"
		% relationship.suspicion
	)

	print(
		"Dependence: %.2f"
		% relationship.dependence
	)

	print(
		"Importance: %.2f"
		% relationship.importance
	)

	print(
		"Relationship quality: %.2f"
		% relationship.get_relationship_quality()
	)

	print(
		"Emotional attachment: %.2f"
		% relationship.get_emotional_attachment()
	)

	print(
		"Relationship threat: %.2f"
		% relationship.get_relationship_threat()
	)

	print("Recent event: ", relationship.recent_event)

	print("========================================")


func print_all_relationships() -> void:

	print("========================================")
	print("ALL RELATIONSHIPS")
	print("========================================")

	print(
		"Relationship count: ",
		relationships.size()
	)

	for character_id in relationships:

		print_relationship(
			character_id
		)


	print("========================================")


# ============================================================
# RESET
# ============================================================

func clear_relationships() -> void:

	relationships.clear()
