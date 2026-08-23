class_name CharacterCreator
extends Control

var profile: CharacterProfile
var archetype_menu: OptionButton
var name_edit: LineEdit
var age_spin: SpinBox
var personality_box: VBoxContainer
var relationship_box: VBoxContainer
var appearance_box: VBoxContainer
var status_label: Label

const PERSONALITY_KEYS := ["confidence", "empathy", "assertiveness", "curiosity", "openness", "sociability", "caution", "playfulness", "resilience", "patience", "independence", "romanticism", "jealousy", "spontaneity"]
const PERSONALITY_LABELS := {"confidence":"Confidence", "empathy":"Empathy", "assertiveness":"Assertiveness", "curiosity":"Curiosity", "openness":"Openness", "sociability":"Sociability", "caution":"Caution", "playfulness":"Playfulness", "resilience":"Resilience", "patience":"Patience", "independence":"Independence", "romanticism":"Romanticism", "jealousy":"Jealousy", "spontaneity":"Spontaneity"}

func _ready() -> void:
	profile = CharacterProfile.new()
	profile.character_id = "character_%d" % Time.get_unix_time_from_system()
	profile.initialize()
	_build_ui()
	_refresh_ui()

func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	add_child(margin)
	var root := VBoxContainer.new()
	margin.add_child(root)
	var title := Label.new()
	title.text = "Character Creator"
	title.add_theme_font_size_override("font_size", 28)
	root.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Archetypes establish starting values. Every value can be fine-tuned."
	root.add_child(subtitle)
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
	age_spin.value = 25
	age_spin.value_changed.connect(_on_age_changed)
	identity.add_child(age_spin)
	archetype_menu = OptionButton.new()
	for name in CharacterArchetypes.NAMES:
		archetype_menu.add_item(name)
	archetype_menu.item_selected.connect(_on_archetype_selected)
	root.add_child(archetype_menu)
	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(tabs)
	personality_box = _make_tab(tabs, "Personality")
	appearance_box = _make_tab(tabs, "Appearance")
	relationship_box = _make_tab(tabs, "Relationship")
	_build_personality()
	_build_appearance()
	_build_relationship()
	var buttons := HBoxContainer.new()
	root.add_child(buttons)
	var randomize := Button.new()
	randomize.text = "Randomize Fine-Tuning"
	randomize.pressed.connect(_randomize)
	buttons.add_child(randomize)
	var save := Button.new()
	save.text = "Save Profile"
	save.pressed.connect(_save)
	buttons.add_child(save)
	status_label = Label.new()
	root.add_child(status_label)

func _make_tab(tabs: TabContainer, title: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = title
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(box)
	return box

func _build_personality() -> void:
	for key in PERSONALITY_KEYS:
		_add_slider(personality_box, key, PERSONALITY_LABELS[key], profile.get_personality_value(key), _on_personality.bind(key))

func _build_appearance() -> void:
	_add_slider(appearance_box, "height", "Height", 0.5, _on_appearance.bind("height"))
	_add_slider(appearance_box, "body_build", "Body Build", 0.5, _on_appearance.bind("body_build"))
	_add_slider(appearance_box, "skin_tone", "Skin Tone", 0.5, _on_appearance.bind("skin_tone"))
	_add_text(appearance_box, "face_id", "Face Asset ID")
	_add_text(appearance_box, "hair_id", "Hair Asset ID")
	_add_text(appearance_box, "voice_id", "Voice Asset ID")

func _build_relationship() -> void:
	_add_slider(relationship_box, "affection_tendency", "Affection", profile.preferences.affection_tendency, _on_relationship.bind("affection_tendency"))
	_add_slider(relationship_box, "commitment_tendency", "Commitment", profile.preferences.commitment_tendency, _on_relationship.bind("commitment_tendency"))
	_add_slider(relationship_box, "romance_tendency", "Romance", profile.preferences.romance_tendency, _on_relationship.bind("romance_tendency"))
	_add_slider(relationship_box, "social_initiative", "Social Initiative", profile.preferences.social_initiative, _on_relationship.bind("social_initiative"))
	_add_slider(relationship_box, "physical_affection_tendency", "Physical Affection", profile.preferences.physical_affection_tendency, _on_relationship.bind("physical_affection_tendency"))
	_add_slider(relationship_box, "teasing_tendency", "Teasing", profile.preferences.teasing_tendency, _on_relationship.bind("teasing_tendency"))
	_add_slider(relationship_box, "initiative_tendency", "Initiative", profile.preferences.initiative_tendency, _on_relationship.bind("initiative_tendency"))

func _add_slider(parent: VBoxContainer, key: String, label_text: String, initial: float, callback: Callable) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 180
	row.add_child(label)
	var slider := HSlider.new()
	slider.name = key
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = initial
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(callback)
	row.add_child(slider)
	var value := Label.new()
	value.name = "Value"
	value.text = "%.2f" % initial
	value.custom_minimum_size.x = 50
	row.add_child(value)
	parent.add_child(row)

func _add_text(parent: VBoxContainer, key: String, label_text: String) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 180
	row.add_child(label)
	var edit := LineEdit.new()
	edit.name = key
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.text_changed.connect(_on_appearance_text.bind(key))
	row.add_child(edit)
	parent.add_child(row)

func _refresh_ui() -> void:
	name_edit.text = profile.get_character_name()
	age_spin.value = profile.get_age()
	var index := CharacterArchetypes.NAMES.find(profile.archetype)
	if index >= 0:
		archetype_menu.select(index)

func _refresh_sliders() -> void:
	for key in PERSONALITY_KEYS:
		var s := personality_box.find_child(key, true, false) as HSlider
		if s: s.value = profile.get_personality_value(key)
	for key in ["affection_tendency", "commitment_tendency", "romance_tendency", "social_initiative", "physical_affection_tendency", "teasing_tendency", "initiative_tendency"]:
		var s := relationship_box.find_child(key, true, false) as HSlider
		if s: s.value = float(profile.preferences.get(key))

func _on_name_changed(value: String) -> void:
	profile.biography.first_name = value
	profile.biography.preferred_name = value

func _on_age_changed(value: float) -> void:
	profile.biography.age = int(value)

func _on_archetype_selected(index: int) -> void:
	profile.archetype = CharacterArchetypes.NAMES[index]
	CharacterArchetypes.apply(profile, profile.archetype)
	_refresh_sliders()
	status_label.text = "Applied %s starting values." % profile.archetype

func _on_personality(value: float, key: String) -> void:
	profile.set_personality(key, value)

func _on_relationship(value: float, key: String) -> void:
	profile.preferences.set(key, value)

func _on_appearance(value: float, key: String) -> void:
	profile.appearance.set(key, value)

func _on_appearance_text(value: String, key: String) -> void:
	profile.appearance.set(key, value)

func _randomize() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for key in PERSONALITY_KEYS:
		profile.set_personality(key, rng.randf())
	for key in ["affection_tendency", "commitment_tendency", "romance_tendency", "social_initiative"]:
		profile.preferences.set(key, rng.randf())
	_refresh_sliders()
	status_label.text = "Fine-tuning randomized; archetype remains %s." % profile.archetype

func _save() -> void:
	DirAccess.make_dir_recursive_absolute("user://characters")
	var path := "user://characters/%s.tres" % profile.character_id
	var result := ResourceSaver.save(profile, path)
	status_label.text = "Saved: %s" % path if result == OK else "Save failed: %s" % result
