extends Control


var brain: CharacterBrain


func _ready() -> void:

	brain = CharacterBrain.new()

	add_child(brain)


func _process(_delta: float) -> void:

	pass
