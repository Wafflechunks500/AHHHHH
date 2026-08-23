class_name LocationManager
extends Node

signal travel_started(from_location: LocationDefinition, to_location: LocationDefinition)
signal location_changed(location: LocationDefinition)

var locations: Dictionary = {}
var current_location_id: String = ""
var pending_destination_id: String = ""

func register_location(location: LocationDefinition) -> void:
	if location.location_id.is_empty():
		push_warning("Cannot register a location without an ID.")
		return
	locations[location.location_id] = location

func register_locations(location_list: Array[LocationDefinition]) -> void:
	for location in location_list:
		register_location(location)

func get_location(location_id: String) -> LocationDefinition:
	return locations.get(location_id, null)

func set_initial_location(location_id: String) -> bool:
	if not locations.has(location_id):
		return false
	current_location_id = location_id
	location_changed.emit(locations[location_id])
	return true

func request_travel(destination_id: String) -> bool:
	var destination := get_location(destination_id)
	if destination == null or not destination.available:
		return false
	if destination_id == current_location_id:
		return false

	pending_destination_id = destination_id
	return true

func confirm_travel() -> bool:
	if pending_destination_id.is_empty():
		return false

	var destination := get_location(pending_destination_id)
	if destination == null or not destination.available:
		pending_destination_id = ""
		return false

	var from_location := get_location(current_location_id)
	travel_started.emit(from_location, destination)

	# The actual door animation/loading can be handled by the scene controller.
	# Once the destination scene is ready, call complete_travel().
	return true

func cancel_travel() -> void:
	pending_destination_id = ""

func complete_travel() -> bool:
	if pending_destination_id.is_empty():
		return false

	var destination := get_location(pending_destination_id)
	if destination == null:
		pending_destination_id = ""
		return false

	current_location_id = destination.location_id
	pending_destination_id = ""
	location_changed.emit(destination)
	return true

func get_current_location() -> LocationDefinition:
	return get_location(current_location_id)
