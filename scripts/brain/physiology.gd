class_name CharacterPhysiology
extends Resource


# ============================================================
# CHARACTER PHYSIOLOGY
#
# Represents the character's current physical state.
#
# This is NOT personality.
#
# Personality:
#     "Evelyn is energetic."
#
# Physiology:
#     "Evelyn is currently tired."
#
# The brain will eventually read these values when deciding
# what the character should do.
# ============================================================


# ============================================================
# ENERGY
# ============================================================

## Available physical energy.
## 1.0 = extremely energetic
## 0.0 = completely exhausted.

@export_range(0.0, 1.0)
var energy: float = 0.85


## Current physical fatigue.
## 0.0 = no fatigue
## 1.0 = extremely fatigued.

@export_range(0.0, 1.0)
var fatigue: float = 0.10


# ============================================================
# BIOLOGICAL NEEDS
# ============================================================

## Hunger level.
## 0.0 = completely satisfied
## 1.0 = extremely hungry.

@export_range(0.0, 1.0)
var hunger: float = 0.15


## Thirst level.
## 0.0 = completely hydrated
## 1.0 = extremely thirsty.

@export_range(0.0, 1.0)
var thirst: float = 0.15


## Sleep pressure.
## 0.0 = fully rested
## 1.0 = desperately sleepy.

@export_range(0.0, 1.0)
var sleepiness: float = 0.10


# ============================================================
# PHYSICAL COMFORT
# ============================================================

## Overall physical comfort.
## 1.0 = extremely comfortable
## 0.0 = extremely uncomfortable.

@export_range(0.0, 1.0)
var comfort: float = 0.80


## Physical pain.
## 0.0 = no pain
## 1.0 = severe pain.

@export_range(0.0, 1.0)
var pain: float = 0.0


## Discomfort caused by temperature.

@export_range(0.0, 1.0)
var temperature_discomfort: float = 0.0


# ============================================================
# STRESS / ACTIVATION
# ============================================================

## General physiological stress.

@export_range(0.0, 1.0)
var stress: float = 0.10


## General physiological activation.
##
## This represents how activated the body is, not a specific
## emotion.

@export_range(0.0, 1.0)
var arousal: float = 0.20


# ============================================================
# UPDATE
# ============================================================

## Update the body's state as time passes.
##
## delta = elapsed simulation time in seconds.

func update(delta: float) -> void:

	# --------------------------------------------------------
	# Biological needs gradually increase.
	# --------------------------------------------------------

	hunger = clamp(
		hunger + delta * 0.002,
		0.0,
		1.0
	)

	thirst = clamp(
		thirst + delta * 0.003,
		0.0,
		1.0
	)

	sleepiness = clamp(
		sleepiness + delta * 0.001,
		0.0,
		1.0
	)


	# --------------------------------------------------------
	# Energy gradually decreases.
	# --------------------------------------------------------

	var energy_drain: float = (
		0.0002
		+ hunger * 0.0001
		+ thirst * 0.0001
	)

	energy = clamp(
		energy - energy_drain * delta,
		0.0,
		1.0
	)


	# --------------------------------------------------------
	# Fatigue emerges from low energy and sleepiness.
	# --------------------------------------------------------

	var target_fatigue: float = clamp(
		(
			(1.0 - energy) * 0.6
			+ sleepiness * 0.4
		),
		0.0,
		1.0
	)

	fatigue = move_toward(
		fatigue,
		target_fatigue,
		delta * 0.02
	)


	# --------------------------------------------------------
	# Stress naturally decreases when comfortable.
	# --------------------------------------------------------

	if comfort > 0.6 and pain < 0.2:

		stress = move_toward(
			stress,
			0.0,
			delta * 0.005
		)


	# --------------------------------------------------------
	# Physical discomfort affects comfort.
	# --------------------------------------------------------

	var discomfort: float = (
		pain * 0.6
		+ temperature_discomfort * 0.4
	)

	var target_comfort: float = 1.0 - discomfort

	comfort = move_toward(
		comfort,
		target_comfort,
		delta * 0.05
	)


# ============================================================
# EXTERNAL EFFECTS
# ============================================================

func apply_stress(amount: float) -> void:

	stress = clamp(
		stress + amount,
		0.0,
		1.0
	)


func apply_pain(amount: float) -> void:

	pain = clamp(
		pain + amount,
		0.0,
		1.0
	)


func apply_comfort(amount: float) -> void:

	comfort = clamp(
		comfort + amount,
		0.0,
		1.0
	)


func restore_energy(amount: float) -> void:

	energy = clamp(
		energy + amount,
		0.0,
		1.0
	)

	fatigue = clamp(
		fatigue - amount,
		0.0,
		1.0
	)


func eat(amount: float) -> void:

	hunger = clamp(
		hunger - amount,
		0.0,
		1.0
	)


func drink(amount: float) -> void:

	thirst = clamp(
		thirst - amount,
		0.0,
		1.0
	)


func sleep(amount: float) -> void:

	sleepiness = clamp(
		sleepiness - amount,
		0.0,
		1.0
	)

	energy = clamp(
		energy + amount * 0.8,
		0.0,
		1.0
	)

	fatigue = clamp(
		fatigue - amount * 0.8,
		0.0,
		1.0
	)


# ============================================================
# INFORMATION FOR THE BRAIN
# ============================================================

## Returns a general measure of physical discomfort.

func get_overall_discomfort() -> float:

	return clamp(
		(
			hunger * 0.15
			+ thirst * 0.15
			+ fatigue * 0.20
			+ pain * 0.30
			+ temperature_discomfort * 0.10
			+ stress * 0.10
		),
		0.0,
		1.0
	)


## Returns the strongest current physical need.

func get_need_pressure() -> float:

	return max(
		hunger,
		thirst,
		sleepiness,
		pain,
		stress
	)
