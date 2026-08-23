class_name CharacterCreator
extends Control

var character: CharacterDefinition
var preset_menu: OptionButton
var name_edit: LineEdit
var age_spin: SpinBox
var personality_container: VBoxContainer
var appearance_container: VBoxContainer
var relationship_container: VBoxContainer
var status_label: Label

const PERSONALITY_LABELS := {
	"confidence": "Confidence",
	"empathy": "Empathy",
	"assertiveness": "Assertiveness",
	"curiosity": "Curiosity",
	"openness": "Openness",
	"sociability": "Sociability",
	"caution": "Caution",
	"playfulness": "Playfulness",
	"resilience": "Resilience",
	"patience": "Patience",
	"independence": "Independence",
	"romanticism": "Romanticism",
	"jealousy": "Jealousy",
	"spontaneity": "Spontaneity"
}

func _ready() -> void:
	character = CharacterDefinition.new()
	character.character_id = "character_%s" % Time.get_unix_time_from_system()
	_build_ui()
	_refresh_ui()

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	var title := Label.new()
	title.text = "Character Creator"
	title.add_theme_font_size_override("font_size", 28)
	root.add_child(title)

	var identity := HBoxContainer.new()
	root.add_child(identity)

	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Character name"
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_edit.text_changed.connect(_on_name_changed)
	identity.add_child(name_edit)

	age_spin = SpinBox.new()
	age_spin.min_value = 18
	age_spin.max_value = 100
	age_spin.step = 1
	age_spin.value = 25
	age_spin.value_changed.connect(_on_age_changed)
	identity.add_child(age_spin)

	preset_menu = OptionButton.new()
	for preset_name in CharacterPresets.names():
		preset_menu.add_item(preset_name)
	preset_menu.item_selected.connect(_on_preset_selected)
	root.add_child(preset_menu)

	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(tabs)

	personality_container = VBoxContainer.new()
	personality_container.name = "Personality"
	tabs.add_child(personality_container)

	appearance_container = VBoxContainer.new()
	appearance_container.name = "Appearance"
	tabs.add_child(appearance_container)

	relationship_container = VBoxContainer.new()
	relationship_container.name = "Preferences"
	tabs.add_child(relationship_container)

	_build_personality_controls()
	_build_appearance_controls()
	_build_preference_controls()

	var buttons := HBoxContainer.new()
	root.add_child(buttons)

	var randomize := Button.new()
	randomize.text = "Randomize"
	randomize.pressed.connect(_randomize_character)
	buttons.add_child(randomize)

	var save := Button.new()
	save.text = "Save"
	save.pressed.connect(_save_character)
	buttons.add_child(save)

	var create := Button.new()
	create.text = "Create Character"
	create.pressed.connect(_create_character)
	buttons.add_child(create)

	status_label = Label.new()
	root.add_child(status_label)

func _build_personality_controls() -> void:
	for key in CharacterPresets.PERSONALITY_KEYS:
		var row := HBoxContainer.new()
		var label := Label.new()
		label.text = PERSONALITY_LABELS.get(key, key.capitalize())
		label.custom_minimum_size.x = 150
		row.add_child(label)

		var slider := HSlider.new()
		slider.name = key
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.value_changed.connect(_on_personality_changed.bind(key))
		row.add_child(slider)

		var value := Label.new()
		value.name = "Value"
		value.custom_minimum_size.x = 45
		row.add_child(value)
		personality_container.add_child(row)

func _build_appearance_controls() -> void:
	_add_dictionary_slider(appearance_container, "height", "Height")
	_add_dictionary_slider(appearance_container, "body_build", "Body Build")
	_add_dictionary_slider(appearance_container, "skin_tone", "Skin Tone")
	_add_text_selector(appearance_container, "face_id", "Face Preset")
	_add_text_selector(appearance_container, "hair_id", "Hair Preset")
	_add_text_selector(appearance_container, "voice_id", "Voice")

func _build_preference_controls() -> void:
	_add_dictionary_slider(relationship_container, "affection", "Affection")
	_add_dictionary_slider(relationship_container, "commitment", "Commitment")
	_add_dictionary_slider(relationship_container, "romance", "Romance")
	_add_dictionary_slider(relationship_container, "social_initiative", "Social Initiative")

func _add_dictionary_slider(parent: Control, key: String, label_text: String) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 150
	row.add_child(label)
	var slider := HSlider.new()
	slider.name = key
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(_on_dictionary_slider_changed.bind(key, parent))
	row.add_child(slider)
	var value := Label.new()
	value.name = "Value"
	value.custom_minimum_size.x = 45
	row.add_child(value)
	parent.add_child(row)

func _add_text_selector(parent: Control, key: String, label_text: String) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 150
	row.add_child(label)
	var edit := LineEdit.new()
	edit.name = key
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.text_changed.connect(_on_appearance_text_changed.bind(key))
	row.add_child(edit)
	parent.add_child(row)

func _refresh_ui() -> void:
	name_edit.text = character.display_name
	age_spin.value = character.age
	for row in personality_container.get_children():
		var slider := row.get_node_or_null(row.get_child(1).name) as HSlider
		if slider != null:
			slider.value = character.get_personality(slider.name)
			row.get_node("Value").text = "%.2f" % slider.value

	_refresh_dictionary_container(appearance_container, character.appearance)
	_refresh_dictionary_container(relationship_container, character.relationship_preferences)

func _refresh_dictionary_container(container: Control, values: Dictionary) -> void:
	for row in container.get_children():
		var control := row.get_child(1)
		if control is HSlider and values.has(control.name):
			control.value = values[control.name]
			row.get_node("Value").text = "%.2f" % control.value
		elif control is LineEdit and values.has(control.name):
			control.text = str(values[control.name])

func _on_name_changed(value: String) -> void:
	character.display_name = value

func _on_age_changed(value: float) -> void:
	character.age = int(value)

func _on_personality_changed(value: float, key: String) -> void:
	character.set_personality(key, value)
	var slider := personality_container.find_child(key, true, false) as HSlider
	if slider != null:
		slider.get_parent().get_node("Value").text = "%.2f" % value

func _on_dictionary_slider_changed(value: float, key: String, parent: Control) -> void:
	var dictionary := character.appearance if parent == appearance_container else character.relationship_preferences
	dictionary[key] = value
	var slider := parent.find_child(key, true, false) as HSlider
	if slider != null:
		slider.get_parent().get_node("Value").text = "%.2f" % value

func _on_appearance_text_changed(value: String, key: String) -> void:
	character.appearance[key] = value

func _on_preset_selected(index: int) -> void:
	CharacterPresets.apply_preset(character, preset_menu.get_item_text(index))
	_refresh_ui()

func _randomize_character() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for key in CharacterPresets.PERSONALITY_KEYS:
		character.set_personality(key, rng.randf())
	for key in character.relationship_preferences:
		character.relationship_preferences[key] = rng.randf()
	for key in ["height", "body_build", "skin_tone"]:
		character.appearance[key] = rng.randf()
	_refresh_ui()
	status_label.text = "Character randomized."

func _save_character() -> void:
	var path := "user://characters/%s.json" % character.character_id
	DirAccess.make_dir_recursive_absolute("user://characters")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		status_label.text = "Could not save character."
		return
	file.store_string(JSON.stringify(_to_dictionary()))
	file.close()
	status_label.text = "Saved to %s" % path

func _to_dictionary() -> Dictionary:
	return {
		"character_id": character.character_id,
		"display_name": character.display_name,
		"age": character.age,
		"personality": character.personality.duplicate(true),
		"relationship_preferences": character.relationship_preferences.duplicate(true),
		"intimacy_preferences": character.intimacy_preferences.duplicate(true),
		"appearance": character.appearance.duplicate(true),
		"background": character.background.duplicate(true)
	}

func _create_character() -> void:
	_save_character()
	status_label.text = "%s created." % character.display_name
