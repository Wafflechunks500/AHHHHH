class_name CharacterPlanner
extends Resource


# ============================================================
# CHARACTER PLANNER
#
# Converts goals into plans.
#
# Goals:
#     "Find something to eat."
#
# Plan:
#     1. Look for food.
#     2. Move toward food.
#     3. Approach the food.
#     4. Eat.
#
# The planner does NOT directly perform actions.
#
# The decision maker will eventually examine the current plan
# and decide what the character actually does next.
#
# The planner also does NOT determine personality or motivation.
#
# It receives desired outcomes from the goal system and creates
# possible sequences of actions that could accomplish them.
#
# Plans are intentionally flexible.
#
# The character should eventually be able to:
#
#     - abandon a plan
#     - modify a plan
#     - reorder steps
#     - create new steps
#     - react to unexpected events
#     - replan when predictions fail
#     - pursue a different goal
#
# This allows behavior to remain dynamic rather than becoming
# a collection of rigid scripted sequences.
# ============================================================


# ============================================================
# PLAN STEP
# ============================================================

class PlanStep:

	## Unique identifier for the step.
	var step_id: String = ""

	## Human-readable description.
	var description: String = ""

	## Category of action.
	##
	## Examples:
	##
	##     perception
	##     movement
	##     social
	##     communication
	##     interaction
	##     wait
	##     internal
	##     physical
	var category: String = "general"

	## Identifier describing the intended action.
	##
	## This is NOT executed here.
	##
	## The decision/action system can eventually interpret it.
	var action: String = ""

	## Optional target character.
	var target_character_id: String = ""

	## Optional target object.
	var target_object_id: String = ""

	## Estimated amount of time required.
	var estimated_duration: float = 0.0

	## Importance of completing this particular step.
	var importance: float = 0.50

	## Whether the step is currently optional.
	var optional: bool = false

	## Whether the step has been completed.
	var completed: bool = false

	## Whether the step has been interrupted.
	var interrupted: bool = false

	## Number of times this step has been attempted.
	var attempt_count: int = 0

	## Arbitrary information attached to the step.
	var parameters: Dictionary = {}


	func _init(
		id: String = "",
		step_description: String = "",
		step_category: String = "general",
		step_action: String = ""
	) -> void:

		step_id = id
		description = step_description
		category = step_category
		action = step_action


	func mark_complete() -> void:

		completed = true
		interrupted = false


	func interrupt() -> void:

		if completed:
			return

		interrupted = true


	func begin_attempt() -> void:

		if completed:
			return

		interrupted = false
		attempt_count += 1


	func is_finished() -> bool:

		return completed


# ============================================================
# PLAN DATA
# ============================================================

class PlanData:

	## Unique identifier for this plan.
	var plan_id: String = ""

	## Goal this plan is intended to accomplish.
	var goal_id: String = ""

	## Human-readable description.
	var description: String = ""

	## Ordered sequence of steps.
	var steps: Array[PlanStep] = []

	## Whether this plan is currently active.
	var active: bool = false

	## Whether this plan has been completed.
	var completed: bool = false

	## Whether the plan was abandoned.
	var abandoned: bool = false

	## Whether the planner should allow this plan to be
	## interrupted by a higher-priority goal.
	var interruptible: bool = true

	## Number of times the plan has been attempted.
	var attempt_count: int = 0

	## How long this plan has existed.
	var age: float = 0.0

	## How much of the plan has been completed.
	var progress: float = 0.0

	## Optional reason for the most recent plan change.
	var last_update_reason: String = ""


	func _init(
		id: String = "",
		plan_description: String = "",
		associated_goal_id: String = ""
	) -> void:

		plan_id = id
		description = plan_description
		goal_id = associated_goal_id


	func add_step(
		step: PlanStep
	) -> void:

		if step == null:
			return

		steps.append(step)


	func get_current_step() -> PlanStep:

		for step in steps:

			if not step.completed and not step.interrupted:
				return step

		return null


	func get_step(
		step_id: String
	) -> PlanStep:

		for step in steps:

			if step.step_id == step_id:
				return step

		return null


	func get_completed_step_count() -> int:

		var count: int = 0

		for step in steps:

			if step.completed:
				count += 1

		return count


	func update_progress() -> void:

		if steps.is_empty():

			progress = 0.0
			return

		progress = (
			float(get_completed_step_count())
			/ float(steps.size())
		)

		if progress >= 1.0:

			progress = 1.0
			completed = true
			active = false


	func start() -> void:

		if completed or abandoned:
			return

		active = true
		attempt_count += 1


	func abandon(
		reason: String = ""
	) -> void:

		if completed:
			return

		active = false
		abandoned = true
		last_update_reason = reason


	func restart() -> void:

		if completed:
			return

		active = true
		abandoned = false
		progress = 0.0

		for step in steps:

			step.completed = false
			step.interrupted = false

		attempt_count += 1


	func is_finished() -> bool:

		return completed


# ============================================================
# PLANNER STATE
# ============================================================

## All plans currently known to the planner.

var plans: Dictionary = {}


## ID of the currently active plan.

var current_plan_id: String = ""


## Whether the planner currently needs to reconsider the
## current plan.

var needs_replanning: bool = false


## Reason the planner most recently requested replanning.

var replanning_reason: String = ""


## Total amount of simulated time.

var simulation_time: float = 0.0


# ============================================================
# PLAN CREATION
# ============================================================

func create_plan(
	plan_id: String,
	description: String,
	goal_id: String
) -> PlanData:

	if plan_id.strip_edges() == "":

		push_warning(
			"Cannot create plan with empty ID."
		)

		return null


	if plans.has(plan_id):

		return plans[plan_id]


	var plan := PlanData.new(
		plan_id,
		description,
		goal_id
	)

	plans[plan_id] = plan

	return plan


# ============================================================
# PLAN ACCESS
# ============================================================

func get_plan(
	plan_id: String
) -> PlanData:

	if not plans.has(plan_id):
		return null

	return plans[plan_id]


func has_plan(
	plan_id: String
) -> bool:

	return plans.has(plan_id)


func remove_plan(
	plan_id: String
) -> void:

	if current_plan_id == plan_id:

		current_plan_id = ""

	if plans.has(plan_id):

		plans.erase(plan_id)


# ============================================================
# CURRENT PLAN
# ============================================================

func get_current_plan() -> PlanData:

	if current_plan_id == "":
		return null

	return get_plan(
		current_plan_id
	)


func get_current_step() -> PlanStep:

	var plan := get_current_plan()

	if plan == null:
		return null

	return plan.get_current_step()


# ============================================================
# PLAN ACTIVATION
# ============================================================

func activate_plan(
	plan_id: String
) -> void:

	var plan := get_plan(
		plan_id
	)

	if plan == null:
		return

	if plan.completed or plan.abandoned:
		return


	# --------------------------------------------------------
	# Deactivate the previous plan.
	# --------------------------------------------------------

	var previous_plan := get_current_plan()

	if previous_plan != null and previous_plan.plan_id != plan_id:

		previous_plan.active = false


	current_plan_id = plan_id

	plan.start()


# ============================================================
# PLAN DEACTIVATION
# ============================================================

func deactivate_current_plan(
	reason: String = ""
) -> void:

	var plan := get_current_plan()

	if plan == null:
		return


	plan.active = false

	plan.last_update_reason = reason


# ============================================================
# ABANDON PLAN
# ============================================================

func abandon_current_plan(
	reason: String = ""
) -> void:

	var plan := get_current_plan()

	if plan == null:
		return


	plan.abandon(
		reason
	)

	current_plan_id = ""


# ============================================================
# STEP MANAGEMENT
# ============================================================

func add_step(
	plan_id: String,
	step_id: String,
	description: String,
	category: String,
	action: String,
	target_character_id: String = "",
	target_object_id: String = "",
	estimated_duration: float = 0.0,
	importance: float = 0.50
) -> PlanStep:

	var plan := get_plan(
		plan_id
	)

	if plan == null:
		return null


	var step := PlanStep.new(
		step_id,
		description,
		category,
		action
	)

	step.target_character_id = target_character_id
	step.target_object_id = target_object_id

	step.estimated_duration = max(
		estimated_duration,
		0.0
	)

	step.importance = clamp(
		importance,
		0.0,
		1.0
	)

	plan.add_step(
		step
	)

	return step


func complete_current_step(
	reason: String = ""
) -> void:

	var plan := get_current_plan()

	if plan == null:
		return


	var step := plan.get_current_step()

	if step == null:
		plan.update_progress()
		return


	step.mark_complete()

	plan.last_update_reason = reason

	plan.update_progress()


	if plan.completed:

		current_plan_id = ""


# ============================================================
# INTERRUPT CURRENT STEP
# ============================================================

func interrupt_current_step(
	reason: String = ""
) -> void:

	var plan := get_current_plan()

	if plan == null:
		return


	var step := plan.get_current_step()

	if step == null:
		return


	step.interrupt()

	plan.last_update_reason = reason


# ============================================================
# RESUME INTERRUPTED STEP
# ============================================================

func resume_interrupted_step() -> void:

	var plan := get_current_plan()

	if plan == null:
		return


	for step in plan.steps:

		if step.interrupted and not step.completed:

			step.interrupted = false
			return


# ============================================================
# REPLANNING
# ============================================================

func request_replanning(
	reason: String = ""
) -> void:

	needs_replanning = true
	replanning_reason = reason


func clear_replanning_request() -> void:

	needs_replanning = false
	replanning_reason = ""


func is_replanning_required() -> bool:

	return needs_replanning


func get_replanning_reason() -> String:

	return replanning_reason


# ============================================================
# GOAL → PLAN GENERATION
#
# This is deliberately conservative.
#
# The goal system provides the desired outcome.
#
# The planner creates a basic sequence of intended steps.
#
# The decision maker remains responsible for deciding which
# actual action should happen next.
# ============================================================

func generate_plan_for_goal(
	goal: CharacterGoals.GoalData
) -> PlanData:

	if goal == null:
		return null


	var plan_id: String = (
		"plan_"
		+ goal.goal_id
		+ "_"
		+ str(Time.get_ticks_msec())
	)


	var plan_description: String = (
		"Pursue goal: "
		+ goal.description
	)


	var plan := create_plan(
		plan_id,
		plan_description,
		goal.goal_id
	)

	if plan == null:
		return null


	# --------------------------------------------------------
	# Basic survival goals.
	# --------------------------------------------------------

	match goal.goal_id:

		"satisfy_hunger":

			add_step(
				plan_id,
				"observe_food",
				"Look for available food.",
				"perception",
				"search_for_food",
				"",
				"",
				2.0,
				0.70
			)

			add_step(
				plan_id,
				"approach_food",
				"Move toward a suitable source of food.",
				"movement",
				"approach_food",
				"",
				"",
				5.0,
				0.70
			)

			add_step(
				plan_id,
				"eat",
				"Eat the selected food.",
				"physical",
				"eat",
				"",
				"",
				5.0,
				0.90
			)


		"satisfy_thirst":

			add_step(
				plan_id,
				"observe_drink",
				"Look for something to drink.",
				"perception",
				"search_for_drink",
				"",
				"",
				2.0,
				0.70
			)

			add_step(
				plan_id,
				"approach_drink",
				"Move toward a suitable source of water or drink.",
				"movement",
				"approach_drink",
				"",
				"",
				5.0,
				0.70
			)

			add_step(
				plan_id,
				"drink",
				"Drink.",
				"physical",
				"drink",
				"",
				"",
				4.0,
				0.90
			)


		"rest":

			add_step(
				plan_id,
				"find_resting_place",
				"Look for a comfortable place to rest.",
				"perception",
				"search_for_resting_place",
				"",
				"",
				3.0,
				0.70
			)

			add_step(
				plan_id,
				"approach_resting_place",
				"Move toward the selected resting place.",
				"movement",
				"approach_resting_place",
				"",
				"",
				5.0,
				0.70
			)

			add_step(
				plan_id,
				"rest",
				"Rest.",
				"physical",
				"rest",
				"",
				"",
				10.0,
				0.90
			)


		"reduce_pain":

			add_step(
				plan_id,
				"assess_pain",
				"Assess the current physical problem.",
				"internal",
				"assess_pain",
				"",
				"",
				1.0,
				0.80
			)

			add_step(
				plan_id,
				"seek_relief",
				"Look for an appropriate way to reduce the pain.",
				"perception",
				"search_for_pain_relief",
				"",
				"",
				3.0,
				0.90
			)


		"reduce_stress":

			add_step(
				plan_id,
				"assess_environment",
				"Evaluate the current environment for sources of stress.",
				"perception",
				"assess_environment",
				"",
				"",
				2.0,
				0.60
			)

			add_step(
				plan_id,
				"seek_comfort",
				"Find an appropriate way to become more comfortable.",
				"interaction",
				"seek_comfort",
				"",
				"",
				5.0,
				0.70
			)


		_:

			# ------------------------------------------------
			# Generic goal.
			#
			# Unknown goals should not cause the planner to
			# invent a rigid sequence.
			# ------------------------------------------------

			add_step(
				plan_id,
				"consider_goal",
				"Consider how the current goal might be pursued.",
				"internal",
				"consider_goal",
				goal.target_character_id,
				"",
				1.0,
				goal.importance
			)

			add_step(
				plan_id,
				"seek_opportunity",
				"Look for an appropriate opportunity to advance the goal.",
				"perception",
				"seek_opportunity",
				goal.target_character_id,
				"",
				2.0,
				goal.importance
			)


	return plan


# ============================================================
# PLAN SELECTION
# ============================================================

## Returns the plan associated with the highest-priority active
## goal when no current plan exists.
##
## This does NOT make the final behavioral decision.
##
## It only identifies which goal should currently have a plan.

func generate_plan_for_highest_priority_goal(
	goals: CharacterGoals
) -> PlanData:

	if goals == null:
		return null


	var goal := goals.get_highest_priority_goal()

	if goal == null:
		return null


	return generate_plan_for_goal(
		goal
	)


# ============================================================
# PLAN VALIDATION
# ============================================================

func validate_plan(
	plan: PlanData
) -> bool:

	if plan == null:
		return false


	if plan.goal_id.strip_edges() == "":
		return false


	if plan.steps.is_empty():
		return false


	for step in plan.steps:

		if step == null:
			return false

		if step.action.strip_edges() == "":
			return false


	return true


# ============================================================
# PLAN REPLACEMENT
# ============================================================

func replace_current_plan(
	new_plan: PlanData,
	reason: String = ""
) -> void:

	if new_plan == null:
		return


	if not validate_plan(new_plan):
		return


	var old_plan := get_current_plan()

	if old_plan != null:

		old_plan.active = false
		old_plan.last_update_reason = reason


	plans[new_plan.plan_id] = new_plan

	current_plan_id = new_plan.plan_id

	new_plan.last_update_reason = reason

	new_plan.start()


# ============================================================
# PLAN PROGRESS
# ============================================================

func get_current_progress() -> float:

	var plan := get_current_plan()

	if plan == null:
		return 0.0


	plan.update_progress()

	return plan.progress


func get_current_plan_age() -> float:

	var plan := get_current_plan()

	if plan == null:
		return 0.0

	return plan.age


# ============================================================
# TIME UPDATE
# ============================================================

func update(
	delta: float
) -> void:

	if delta <= 0.0:
		return


	simulation_time += delta


	for value in plans.values():

		var plan: PlanData = value

		if plan.active and not plan.completed:

			plan.age += delta

			plan.update_progress()


	# --------------------------------------------------------
	# A plan that has completed should no longer remain the
	# current plan.
	# --------------------------------------------------------

	var current := get_current_plan()

	if current != null and current.completed:

		current_plan_id = ""


# ============================================================
# PLAN QUERIES
# ============================================================

func get_active_plans() -> Array[PlanData]:

	var result: Array[PlanData] = []


	for value in plans.values():

		var plan: PlanData = value

		if plan.active and not plan.completed:

			result.append(plan)


	return result


func get_completed_plans() -> Array[PlanData]:

	var result: Array[PlanData] = []


	for value in plans.values():

		var plan: PlanData = value

		if plan.completed:

			result.append(plan)


	return result


func get_plans_for_goal(
	goal_id: String
) -> Array[PlanData]:

	var result: Array[PlanData] = []


	for value in plans.values():

		var plan: PlanData = value

		if plan.goal_id == goal_id:

			result.append(plan)


	return result


# ============================================================
# DEBUG SUMMARY
# ============================================================

func get_summary() -> String:

	var active := get_active_plans()
	var completed := get_completed_plans()

	var current := get_current_plan()


	if current == null:

		return (
			"Active plans: %d | "
			+ "Completed plans: %d | "
			+ "Current plan: none"
		) % [
			active.size(),
			completed.size()
		]


	var current_step := current.get_current_step()

	var step_name: String = "none"


	if current_step != null:

		step_name = current_step.description


	return (
		"Active plans: %d | "
		+ "Completed plans: %d | "
		+ "Current plan: %s | "
		+ "Progress: %.2f | "
		+ "Current step: %s"
	) % [
		active.size(),
		completed.size(),
		current.description,
		current.progress,
		step_name
	]


# ============================================================
# DEBUG STATE
# ============================================================

func print_state() -> void:

	print("========================================")
	print("CHARACTER PLANNER")
	print("========================================")


	print(
		"Simulation time: %.2f" %
		simulation_time
	)


	print(
		"Plans: %d" %
		plans.size()
	)


	var current := get_current_plan()


	if current == null:

		print("Current plan: NONE")

	else:

		print(
			"Current plan: ",
			current.description
		)

		print(
			"Goal: ",
			current.goal_id
		)

		print(
			"Progress: %.2f" %
			current.progress
		)

		print(
			"Active: ",
			current.active
		)

		print(
			"Completed: ",
			current.completed
		)


		var step_index: int = 0


		for step in current.steps:

			print(
				"  Step %d: %s" %
				[
					step_index + 1,
					step.description
				]
			)

			print(
				"    Action: %s | Category: %s | Completed: %s" %
				[
					step.action,
					step.category,
					str(step.completed)
				]
			)

			step_index += 1


	print(
		"Replanning required: ",
		needs_replanning
	)


	if needs_replanning:

		print(
			"Replanning reason: ",
			replanning_reason
		)


	print("========================================")
