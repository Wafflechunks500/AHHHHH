class_name CharacterGoals
extends Resource


# ============================================================
# CHARACTER GOALS
#
# Represents things the character currently wants to accomplish.
#
# Goals are different from:
#
#     Physiology:
#         "I am hungry."
#
#     Emotion:
#         "I feel anxious."
#
#     Motivation:
#         "I want to feel safe."
#
#     Goal:
#         "Find somewhere safe."
#
#     Plan:
#         "Walk to the bedroom."
#
#     Decision:
#         "Go through the door."
#
# The goal system stores desired outcomes.
#
# It does NOT decide how to accomplish them.
#
# The planner will eventually use goals to construct plans.
#
# The decision maker will eventually decide which available
# action to perform.
# ============================================================


# ============================================================
# GOAL DATA
# ============================================================

class GoalData:

	## Unique identifier for this goal.
	var goal_id: String = ""

	## Human-readable description.
	var description: String = ""

	## Category of the goal.
	##
	## Examples:
	##
	##     survival
	##     comfort
	##     social
	##     exploration
	##     achievement
	##     relationship
	##     personal
	##     etc.
	var category: String = "general"

	## How important the goal currently is.
	##
	## 0.0 = irrelevant
	## 1.0 = extremely important
	var importance: float = 0.50

	## How urgent the goal currently is.
	##
	## 0.0 = can wait
	## 1.0 = needs attention immediately
	var urgency: float = 0.00

	## How much progress has been made.
	##
	## 0.0 = none
	## 1.0 = completely accomplished
	var progress: float = 0.00

	## Whether this goal is currently active.
	var active: bool = true

	## Whether the goal has been completed.
	var completed: bool = false

	## Whether the goal can be abandoned.
	var interruptible: bool = true

	## Number of times the goal has been pursued.
	var pursuit_count: int = 0

	## Time the goal has existed.
	var age: float = 0.0

	## Optional target character.
	##
	## Empty when the goal does not involve another character.
	var target_character_id: String = ""

	## Optional parent goal.
	##
	## Allows larger goals to eventually contain smaller goals.
	var parent_goal_id: String = ""

	## Last reason the goal changed.
	var last_update_reason: String = ""


	# --------------------------------------------------------
	# INITIALIZATION
	# --------------------------------------------------------

	func _init(
		id: String = "",
		goal_description: String = "",
		goal_category: String = "general"
	) -> void:

		goal_id = id

		description = goal_description

		category = goal_category


	# --------------------------------------------------------
	# GOAL STATE
	# --------------------------------------------------------

	func get_priority() -> float:

		if not active or completed:

			return 0.0


		var remaining := 1.0 - progress


		return clamp(
			(
				importance * 0.50
				+ urgency * 0.30
				+ remaining * 0.20
			),
			0.0,
			1.0
		)


	func is_complete() -> bool:

		return completed or progress >= 1.0


	func mark_complete(
		reason: String = ""
	) -> void:

		progress = 1.0

		completed = true

		active = false

		last_update_reason = reason


	func abandon(
		reason: String = ""
	) -> void:

		if not interruptible:

			return


		active = false

		last_update_reason = reason


	func reactivate() -> void:

		if completed:

			return


		active = true


	func add_progress(
		amount: float,
		reason: String = ""
	) -> void:

		if completed:

			return


		progress = clamp(
			progress + amount,
			0.0,
			1.0
		)

		last_update_reason = reason


		if progress >= 1.0:

			mark_complete(
				reason
			)


# ============================================================
# GOAL STORAGE
# ============================================================

## All goals currently known to the character.

var goals: Dictionary = {}


# ============================================================
# GOAL CREATION
# ============================================================

func create_goal(
	goal_id: String,
	description: String,
	category: String = "general",
	importance: float = 0.50,
	urgency: float = 0.00
) -> GoalData:

	if goal_id.strip_edges() == "":

		push_warning(
			"Cannot create goal with empty ID."
		)

		return null


	if goals.has(goal_id):

		return goals[goal_id]


	var goal := GoalData.new(
		goal_id,
		description,
		category
	)

	goal.importance = clamp(
		importance,
		0.0,
		1.0
	)

	goal.urgency = clamp(
		urgency,
		0.0,
		1.0
	)

	goals[goal_id] = goal

	return goal


func get_goal(
	goal_id: String
) -> GoalData:

	if not goals.has(goal_id):

		return null


	return goals[goal_id]


func has_goal(
	goal_id: String
) -> bool:

	return goals.has(
		goal_id
	)


func remove_goal(
	goal_id: String
) -> void:

	if goals.has(goal_id):

		goals.erase(
			goal_id
		)


# ============================================================
# GOAL ACTIVATION
# ============================================================

func activate_goal(
	goal_id: String
) -> void:

	var goal := get_goal(
		goal_id
	)

	if goal == null:

		return


	goal.reactivate()


func deactivate_goal(
	goal_id: String,
	reason: String = ""
) -> void:

	var goal := get_goal(
		goal_id
	)

	if goal == null:

		return


	goal.abandon(
		reason
	)


# ============================================================
# GOAL PROGRESS
# ============================================================

func update_goal_progress(
	goal_id: String,
	amount: float,
	reason: String = ""
) -> void:

	var goal := get_goal(
		goal_id
	)

	if goal == null:

		return


	goal.add_progress(
		amount,
		reason
	)


func set_goal_progress(
	goal_id: String,
	progress: float,
	reason: String = ""
) -> void:

	var goal := get_goal(
		goal_id
	)

	if goal == null:

		return


	goal.progress = clamp(
		progress,
		0.0,
		1.0
	)

	goal.last_update_reason = reason


	if goal.progress >= 1.0:

		goal.mark_complete(
			reason
		)


# ============================================================
# IMPORTANCE / URGENCY
# ============================================================

func set_goal_importance(
	goal_id: String,
	value: float
) -> void:

	var goal := get_goal(
		goal_id
	)

	if goal == null:

		return


	goal.importance = clamp(
		value,
		0.0,
		1.0
	)


func modify_goal_importance(
	goal_id: String,
	amount: float
) -> void:

	var goal := get_goal(
		goal_id
	)

	if goal == null:

		return


	goal.importance = clamp(
		goal.importance + amount,
		0.0,
		1.0
	)


func set_goal_urgency(
	goal_id: String,
	value: float
) -> void:

	var goal := get_goal(
		goal_id
	)

	if goal == null:

		return


	goal.urgency = clamp(
		value,
		0.0,
		1.0
	)


func modify_goal_urgency(
	goal_id: String,
	amount: float
) -> void:

	var goal := get_goal(
		goal_id
	)

	if goal == null:

		return


	goal.urgency = clamp(
		goal.urgency + amount,
		0.0,
		1.0
	)


# ============================================================
# TARGET CHARACTERS
# ============================================================

func set_goal_target(
	goal_id: String,
	character_id: String
) -> void:

	var goal := get_goal(
		goal_id
	)

	if goal == null:

		return


	goal.target_character_id = character_id


# ============================================================
# PURSUIT
# ============================================================

## Called when the character begins actively pursuing a goal.

func begin_pursuit(
	goal_id: String
) -> void:

	var goal := get_goal(
		goal_id
	)

	if goal == null:

		return


	if goal.completed:

		return


	goal.active = true

	goal.pursuit_count += 1


# ============================================================
# GOAL QUERIES
# ============================================================

## Returns all currently active goals.

func get_active_goals() -> Array[GoalData]:

	var result: Array[GoalData] = []


	for value in goals.values():

		var goal: GoalData = value

		if goal.active and not goal.completed:

			result.append(
				goal
			)


	return result


## Returns all completed goals.

func get_completed_goals() -> Array[GoalData]:

	var result: Array[GoalData] = []


	for value in goals.values():

		var goal: GoalData = value

		if goal.completed:

			result.append(
				goal
			)


	return result


## Returns the highest-priority active goal.

func get_highest_priority_goal() -> GoalData:

	var active_goals := get_active_goals()


	if active_goals.is_empty():

		return null


	var highest: GoalData = active_goals[0]


	for goal in active_goals:

		if goal.get_priority() > highest.get_priority():

			highest = goal


	return highest


## Returns all goals belonging to a category.

func get_goals_by_category(
	category: String
) -> Array[GoalData]:

	var result: Array[GoalData] = []


	for value in goals.values():

		var goal: GoalData = value

		if goal.category == category:

			result.append(
				goal
			)


	return result


## Returns whether the character currently has an active
## goal involving a specific character.

func has_goal_for_character(
	character_id: String
) -> bool:

	for value in goals.values():

		var goal: GoalData = value

		if (
			goal.active
			and not goal.completed
			and goal.target_character_id == character_id
		):

			return true


	return false


# ============================================================
# AUTOMATIC GOALS FROM BASIC NEEDS
#
# These are deliberately simple.
#
# Later, the motivation system can become much more
# sophisticated and decide when needs should generate goals.
# ============================================================

func evaluate_basic_needs(
	hunger: float,
	thirst: float,
	sleepiness: float,
	pain: float,
	stress: float
) -> void:

	# --------------------------------------------------------
	# Hunger
	# --------------------------------------------------------

	if hunger > 0.70:

		if not has_goal("satisfy_hunger"):

			create_goal(
				"satisfy_hunger",
				"Find something to eat.",
				"survival",
				0.75,
				hunger
			)

		else:

			set_goal_urgency(
				"satisfy_hunger",
				hunger
			)

	elif hunger < 0.30:

		if has_goal("satisfy_hunger"):

			var hunger_goal := get_goal(
				"satisfy_hunger"
			)

			if hunger_goal != null:

				hunger_goal.mark_complete(
					"Hunger is sufficiently satisfied."
				)


	# --------------------------------------------------------
	# Thirst
	# --------------------------------------------------------

	if thirst > 0.70:

		if not has_goal("satisfy_thirst"):

			create_goal(
				"satisfy_thirst",
				"Find something to drink.",
				"survival",
				0.80,
				thirst
			)

		else:

			set_goal_urgency(
				"satisfy_thirst",
				thirst
			)

	elif thirst < 0.30:

		if has_goal("satisfy_thirst"):

			var thirst_goal := get_goal(
				"satisfy_thirst"
			)

			if thirst_goal != null:

				thirst_goal.mark_complete(
					"Thirst is sufficiently satisfied."
				)


	# --------------------------------------------------------
	# Sleep
	# --------------------------------------------------------

	if sleepiness > 0.75:

		if not has_goal("rest"):

			create_goal(
				"rest",
				"Find somewhere comfortable to rest.",
				"survival",
				0.80,
				sleepiness
			)

		else:

			set_goal_urgency(
				"rest",
				sleepiness
			)

	elif sleepiness < 0.30:

		if has_goal("rest"):

			var rest_goal := get_goal(
				"rest"
			)

			if rest_goal != null:

				rest_goal.mark_complete(
					"Sleep pressure is sufficiently low."
				)


	# --------------------------------------------------------
	# Pain
	# --------------------------------------------------------

	if pain > 0.50:

		if not has_goal("reduce_pain"):

			create_goal(
				"reduce_pain",
				"Reduce physical pain.",
				"survival",
				0.90,
				pain
			)

		else:

			set_goal_urgency(
				"reduce_pain",
				pain
			)


	# --------------------------------------------------------
	# Stress
	# --------------------------------------------------------

	if stress > 0.70:

		if not has_goal("reduce_stress"):

			create_goal(
				"reduce_stress",
				"Find a way to reduce stress.",
				"comfort",
				0.65,
				stress
			)

		else:

			set_goal_urgency(
				"reduce_stress",
				stress
			)


# ============================================================
# TIME UPDATE
# ============================================================

func update(
	delta: float
) -> void:

	if delta <= 0.0:

		return


	for value in goals.values():

		var goal: GoalData = value

		if goal.active and not goal.completed:

			goal.age += delta


# ============================================================
# DEBUG SUMMARY
# ============================================================

func get_summary() -> String:

	var active := get_active_goals()

	var completed := get_completed_goals()


	if active.is_empty():

		return (
			"Active goals: 0 | "
			+ "Completed goals: %d"
		) % completed.size()


	var highest := get_highest_priority_goal()


	return (
		"Active goals: %d | "
		+ "Completed goals: %d | "
		+ "Highest priority: %s | "
		+ "Priority: %.2f"
	) % [
		active.size(),
		completed.size(),
		highest.description,
		highest.get_priority()
	]


func print_state() -> void:

	print("========================================")
	print("CHARACTER GOALS")
	print("========================================")


	if goals.is_empty():

		print("No goals currently exist.")

	else:

		for value in goals.values():

			var goal: GoalData = value

			print(
				"[%s] %s" %
				[
					goal.goal_id,
					goal.description
				]
			)

			print(
				"  Category: %s | "
				+ "Priority: %.2f | "
				+ "Progress: %.2f | "
				+ "Urgency: %.2f" %
				[
					goal.category,
					goal.get_priority(),
					goal.progress,
					goal.urgency
				]
			)

			print(
				"  Active: %s | "
				+ "Completed: %s | "
				+ "Target: %s" %
				[
					str(goal.active),
					str(goal.completed),
					goal.target_character_id
				]
			)

			print("----------------------------------------")


	print("========================================")
