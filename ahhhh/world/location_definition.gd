class_name LocationDefinition
extends Resource

@export var location_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var scene_path: String = ""
@export var location_type: String = "home"
@export var owned_by_character_id: String = ""
@export var available: bool = true

func _init(
	p_id: String = "",
	p_name: String = "",
	p_scene_path: String = "",
	p_type: String = "home"
) -> void:
	location_id = p_id
	display_name = p_name
	scene_path = p_scene_path
	location_type = p_type
