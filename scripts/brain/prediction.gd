class_name CharacterPrediction
extends Resource


# ============================================================
# CHARACTER PREDICTION
#
# Represents what the character currently expects may happen.
#
# Prediction is NOT decision making.
#
# The prediction system answers questions such as:
#
#     "What do I think will happen?"
#     "How likely do I think it is?"
#     "How good or bad do I expect it to be?"
#     "How certain am I?"
#
# Predictions are beliefs, not facts.
#
# The character can therefore:
#
#     predict something incorrectly
#     become surprised
#     compare the prediction against what actually happened
#     learn from the error
# ============================================================


# ============================================================
# ACTIVE PREDICTIONS
# ============================================================

var predictions: Array[Dictionary] = []


# ============================================================
# PREDICTION HISTORY
# ============================================================

var prediction_history: Array[Dictionary] = []


@export
var max_active_predictions: int = 32


@export
var max_prediction_history: int = 100


# ============================================================
# CURRENT EXPECTATION
# ============================================================

## The event the character currently considers most likely.

var strongest_prediction: String = ""


## Probability associated with the strongest prediction.

@export_range(0.0, 1.0)
var strongest_prediction_probability: float = 0.0


## General confidence in the current prediction set.

@export_range(0.0, 1.0)
var prediction_confidence: float = 0.50


## General uncertainty about the immediate future.
##
## 0.0 = very certain
## 1.0 = extremely uncertain

@export_range(0.0, 1.0)
var uncertainty: float = 0.50


# ============================================================
# UPDATE
# ============================================================

func update(delta: float) -> void:

	if delta <= 0.0:
		return


	# --------------------------------------------------------
	# Reduce remaining prediction time.
	# --------------------------------------------------------

	var expired_predictions: Array[Dictionary] = []

	for prediction in predictions:

		if not prediction.has("remaining_time"):
			continue

		var remaining_time: float = float(
			prediction.get(
				"remaining_time",
				0.0
			)
		)

		remaining_time = max(
			remaining_time - delta,
			0.0
		)

		prediction["remaining_time"] = remaining_time

		if remaining_time <= 0.0:
			expired_predictions.append(prediction)


	for prediction in expired_predictions:
		predictions.erase(prediction)


	# --------------------------------------------------------
	# Refresh current strongest prediction.
	# --------------------------------------------------------

	_refresh_strongest_prediction()


	# --------------------------------------------------------
	# Update general uncertainty.
	# --------------------------------------------------------

	var target_uncertainty: float = (
		_calculate_prediction_uncertainty()
	)

	uncertainty = move_toward(
		uncertainty,
		target_uncertainty,
		delta * 0.05
	)


	# --------------------------------------------------------
	# Calculate general confidence from active predictions.
	# --------------------------------------------------------

	if predictions.is_empty():

		prediction_confidence = move_toward(
			prediction_confidence,
			0.0,
			delta * 0.02
		)

	else:

		var total_confidence: float = 0.0

		for prediction in predictions:

			total_confidence += float(
				prediction.get(
					"confidence",
					0.0
				)
			)

		var average_confidence: float = (
			total_confidence
			/ predictions.size()
		)

		prediction_confidence = move_toward(
			prediction_confidence,
			average_confidence,
			delta * 0.05
		)


# ============================================================
# CREATE PREDICTION
# ============================================================

func add_prediction(
	event_name: String,
	probability: float,
	expected_value: float = 0.0,
	confidence: float = 0.50,
	time_horizon: float = 1.0,
	source: String = "unknown"
) -> Dictionary:

	if event_name.strip_edges() == "":
		return {}


	var prediction: Dictionary = {
		"event": event_name,
		"probability": clamp(
			probability,
			0.0,
			1.0
		),
		"expected_value": clamp(
			expected_value,
			-1.0,
			1.0
		),
		"confidence": clamp(
			confidence,
			0.0,
			1.0
		),
		"time_horizon": max(
			time_horizon,
			0.0
		),
		"remaining_time": max(
			time_horizon,
			0.0
		),
		"source": source
	}


	predictions.append(
		prediction
	)


	while predictions.size() > max_active_predictions:

		_remove_weakest_prediction()


	_refresh_strongest_prediction()


	return prediction


# ============================================================
# UPDATE EXISTING PREDICTION
# ============================================================

func update_prediction(
	event_name: String,
	probability: float,
	expected_value: float = 0.0,
	confidence: float = 0.50
) -> bool:

	for prediction in predictions:

		if prediction.get("event", "") != event_name:
			continue


		prediction["probability"] = clamp(
			probability,
			0.0,
			1.0
		)

		prediction["expected_value"] = clamp(
			expected_value,
			-1.0,
			1.0
		)

		prediction["confidence"] = clamp(
			confidence,
			0.0,
			1.0
		)


		_refresh_strongest_prediction()

		return true


	return false


# ============================================================
# REMOVE PREDICTION
# ============================================================

func remove_prediction(
	event_name: String
) -> void:

	for prediction in predictions.duplicate():

		if prediction.get("event", "") == event_name:

			predictions.erase(
				prediction
			)


	_refresh_strongest_prediction()


# ============================================================
# QUERY PREDICTION
# ============================================================

func has_prediction(
	event_name: String
) -> bool:

	for prediction in predictions:

		if prediction.get("event", "") == event_name:

			return true


	return false


func get_prediction(
	event_name: String
) -> Dictionary:

	for prediction in predictions:

		if prediction.get("event", "") == event_name:

			return prediction


	return {}


func get_strongest_prediction() -> Dictionary:

	if predictions.is_empty():
		return {}


	var strongest: Dictionary = predictions[0]


	for prediction in predictions:

		var probability: float = float(
			prediction.get(
				"probability",
				0.0
			)
		)

		var strongest_probability: float = float(
			strongest.get(
				"probability",
				0.0
			)
		)

		if probability > strongest_probability:

			strongest = prediction


	return strongest


# ============================================================
# PROBABILITY
# ============================================================

func get_probability(
	event_name: String
) -> float:

	var prediction: Dictionary = get_prediction(
		event_name
	)


	if prediction.is_empty():
		return 0.0


	return float(
		prediction.get(
			"probability",
			0.0
		)
	)


func get_expected_value(
	event_name: String
) -> float:

	var prediction: Dictionary = get_prediction(
		event_name
	)


	if prediction.is_empty():
		return 0.0


	return float(
		prediction.get(
			"expected_value",
			0.0
		)
	)


func get_confidence(
	event_name: String
) -> float:

	var prediction: Dictionary = get_prediction(
		event_name
	)


	if prediction.is_empty():
		return 0.0


	return float(
		prediction.get(
			"confidence",
			0.0
		)
	)


# ============================================================
# RESOLVE PREDICTION
# ============================================================

func resolve_prediction(
	event_name: String,
	actual_value: float
) -> Dictionary:

	var prediction: Dictionary = get_prediction(
		event_name
	)


	if prediction.is_empty():
		return {}


	actual_value = clamp(
		actual_value,
		-1.0,
		1.0
	)


	var predicted_probability: float = float(
		prediction.get(
			"probability",
			0.0
		)
	)

	var predicted_value: float = float(
		prediction.get(
			"expected_value",
			0.0
		)
	)

	var prediction_confidence_value: float = float(
		prediction.get(
			"confidence",
			0.0
		)
	)


	var value_error: float = abs(
		predicted_value - actual_value
	)


	var outcome_occurred: bool = (
		actual_value > 0.0
	)


	var result: Dictionary = {
		"event": event_name,
		"predicted_probability": predicted_probability,
		"predicted_value": predicted_value,
		"actual_value": actual_value,
		"confidence": prediction_confidence_value,
		"value_error": value_error,
		"outcome_occurred": outcome_occurred
	}


	prediction_history.append(
		result
	)


	while prediction_history.size() > max_prediction_history:

		prediction_history.pop_front()


	predictions.erase(
		prediction
	)


	_refresh_strongest_prediction()


	return result


# ============================================================
# PREDICTION ACCURACY
# ============================================================

func get_prediction_accuracy() -> float:

	if prediction_history.is_empty():
		return 0.50


	var total_error: float = 0.0


	for result in prediction_history:

		total_error += float(
			result.get(
				"value_error",
				0.0
			)
		)


	var average_error: float = (
		total_error
		/ prediction_history.size()
	)


	return clamp(
		1.0 - average_error,
		0.0,
		1.0
	)


# ============================================================
# SURPRISE
# ============================================================

func get_surprise(
	event_name: String
) -> float:

	var prediction: Dictionary = get_prediction(
		event_name
	)


	if prediction.is_empty():
		return 1.0


	var probability: float = float(
		prediction.get(
			"probability",
			0.0
		)
	)


	return clamp(
		1.0 - probability,
		0.0,
		1.0
	)


# ============================================================
# UNCERTAINTY
# ============================================================

func _calculate_prediction_uncertainty() -> float:

	if predictions.is_empty():
		return 1.0


	var total_confidence: float = 0.0


	for prediction in predictions:

		total_confidence += float(
			prediction.get(
				"confidence",
				0.0
			)
		)


	var average_confidence: float = (
		total_confidence
		/ predictions.size()
	)


	return clamp(
		1.0 - average_confidence,
		0.0,
		1.0
	)


# ============================================================
# INTERNAL MANAGEMENT
# ============================================================

func _refresh_strongest_prediction() -> void:

	if predictions.is_empty():

		strongest_prediction = ""
		strongest_prediction_probability = 0.0

		return


	var strongest: Dictionary = get_strongest_prediction()


	strongest_prediction = str(
		strongest.get(
			"event",
			""
		)
	)


	strongest_prediction_probability = float(
		strongest.get(
			"probability",
			0.0
		)
	)


func _remove_weakest_prediction() -> void:

	if predictions.is_empty():
		return


	var weakest_index: int = 0


	var weakest_probability: float = float(
		predictions[0].get(
			"probability",
			0.0
		)
	)


	for index in range(
		1,
		predictions.size()
	):

		var probability: float = float(
			predictions[index].get(
				"probability",
				0.0
			)
		)


		if probability < weakest_probability:

			weakest_probability = probability
			weakest_index = index


	predictions.remove_at(
		weakest_index
	)


# ============================================================
# INFORMATION FOR THE BRAIN
# ============================================================

func get_prediction_state() -> Dictionary:

	return {
		"active_prediction_count": predictions.size(),
		"strongest_prediction": strongest_prediction,
		"strongest_prediction_probability":
			strongest_prediction_probability,
		"prediction_confidence":
			prediction_confidence,
		"uncertainty":
			uncertainty,
		"prediction_accuracy":
			get_prediction_accuracy()
	}


func get_all_predictions() -> Array[Dictionary]:

	return predictions.duplicate()


func get_prediction_history() -> Array[Dictionary]:

	return prediction_history.duplicate()


# ============================================================
# DEBUG
# ============================================================

func get_summary() -> String:

	return (
		"Active predictions: %d | " +
		"Strongest: %s | " +
		"Probability: %.2f | " +
		"Confidence: %.2f | " +
		"Uncertainty: %.2f | " +
		"Accuracy: %.2f"
	) % [
		predictions.size(),
		strongest_prediction,
		strongest_prediction_probability,
		prediction_confidence,
		uncertainty,
		get_prediction_accuracy()
	]


func print_state() -> void:

	print("========================================")
	print("PREDICTION")
	print("========================================")

	print(
		"Active predictions: ",
		predictions.size()
	)

	print(
		"Strongest prediction: ",
		strongest_prediction
	)

	print(
		"Strongest probability: ",
		strongest_prediction_probability
	)

	print(
		"Prediction confidence: ",
		prediction_confidence
	)

	print(
		"Uncertainty: ",
		uncertainty
	)

	print(
		"Historical accuracy: ",
		get_prediction_accuracy()
	)

	print("")

	for prediction in predictions:

		print(
			"  ",
			prediction.get("event", ""),
			" | probability=",
			prediction.get("probability", 0.0),
			" | value=",
			prediction.get("expected_value", 0.0),
			" | confidence=",
			prediction.get("confidence", 0.0)
		)

	print("========================================")
