class_name CharacterCreator
extends Control

var profile: CharacterProfile
var archetype_menu: OptionButton
var name_edit: LineEdit
var age_spin: SpinBox
var personality_box: VBoxContainer
var relationship_box: VBoxContainer
var appearance_box: VBoxContainer
var stat_title: Label
var stat_description: Label
var stat_behavior: Label
var preview_title: Label
var preview_text: Label
var archetype_summary: Label
var status_label: Label
var stat_rows: Dictionary = {}

const PERSONALITY_KEYS := ["confidence", "empathy", "assertiveness", "curiosity", "openness", "sociability", "caution", "playfulness", "resilience", "patience", "independence", "romanticism", "jealousy", "spontaneity"]
const PERSONALITY_LABELS := {"confidence":"Confidence", "empathy":"Empathy", "assertiveness":"Assertiveness", "curiosity":"Curiosity", "openness":"Openness", "sociability":"Sociability", "caution":"Caution", "playfulness":"Playfulness", "resilience":"Resilience", "patience":"Patience", "independence":"Independence", "romanticism":"Romanticism", "jealousy":"Jealousy", "spontaneity":"Spontaneity"}
const STAT_DESCRIPTIONS := {
	"confidence":"How secure she feels in herself and in social situations.",
	"empathy":"How strongly she notices, understands, and responds to other people's emotions.",
	"assertiveness":"How readily she expresses what she wants, disagrees, or takes control.",
	"curiosity":"How strongly she wants to investigate people, ideas, and unfamiliar situations.",
	"openness":"How receptive she is to new experiences, perspectives, and ideas.",
	"sociability":"How strongly she naturally seeks interaction, conversation, and company.",
	"caution":"How strongly she considers risk and consequences before acting.",
	"playfulness":"How much she enjoys humor, teasing, spontaneity, and lighthearted interaction.",
	"resilience":"How well she recovers from setbacks, rejection, stress, or disappointment.",
	"patience":"How willing she is to wait, tolerate frustration, and let things develop.",
	"independence":"How strongly she prefers making her own choices and maintaining autonomy.",
	"romanticism":"How strongly she values romance, emotional closeness, and romantic expression.",
	"jealousy":"How strongly perceived competition or relationship threats affect her emotions.",
	"spontaneity":"How comfortable she is acting on impulse instead of following a plan."
}

func _ready() -> void:
	profile = CharacterProfile.new()
	profile.character_id = "character_%d" % Time.get_unix_time_from_system()
	profile.initialize()
	_build_ui()
	_refresh_ui()

func _panel_style(bg: Color, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(8)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s

func _text(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _build_ui() -> void:
	var bg := Panel.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.add_theme_stylebox_override("panel", _panel_style(Color("15131a")))
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	var header := PanelContainer.new()
	header.custom_minimum_size.y = 76
	header.add_theme_stylebox_override("panel", _panel_style(Color("211c27"), Color("72526e")))
	root.add_child(header)
	var hb := VBoxContainer.new()
	header.add_child(hb)
	hb.add_child(_text("CREATE CHARACTER", 25, Color("e8d8e6")))
	hb.add_child(_text("Build a person. Archetypes are starting points, not boxes.", 13, Color("aaa0ad")))

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	root.add_child(content)

	var left := VBoxContainer.new()
	left.custom_minimum_size.x = 300
	left.add_theme_constant_override("separation", 10)
	content.add_child(left)

	var archetype_panel := PanelContainer.new()
	archetype_panel.add_theme_stylebox_override("panel", _panel_style(Color("211c27"), Color("6d4c67")))
	left.add_child(archetype_panel)
	var ab := VBoxContainer.new()
	archetype_panel.add_child(ab)
	ab.add_child(_text("ARCHETYPE", 11, Color("b995b5")))
	archetype_menu = OptionButton.new()
	for n in CharacterArchetypes.NAMES:
		archetype_menu.add_item(n)
	archetype_menu.custom_minimum_size.y = 40
	archetype_menu.item_selected.connect(_on_archetype_selected)
	ab.add_child(archetype_menu)
	archetype_summary = _text("Choose a starting personality.", 12, Color("b7adb9"))
	archetype_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ab.add_child(archetype_summary)

	var identity := PanelContainer.new()
	identity.add_theme_stylebox_override("panel", _panel_style(Color("1d1a22"), Color("403844")))
	left.add_child(identity)
	var ib := VBoxContainer.new()
	identity.add_child(ib)
	ib.add_child(_text("IDENTITY", 11, Color("b995b5")))
	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Character name"
	name_edit.custom_minimum_size.y = 38
	name_edit.text_changed.connect(_on_name_changed)
	ib.add_child(name_edit)
	var age_row := HBoxContainer.new()
	age_row.add_child(_text("Age", 13, Color("c6bec8")))
	age_spin = SpinBox.new()
	age_spin.min_value = 18
	age_spin.max_value = 100
	age_spin.value = 25
	age_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	age_spin.value_changed.connect(_on_age_changed)
	age_row.add_child(age_spin)
	ib.add_child(age_row)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 10)
	content.add_child(right)

	var preview := PanelContainer.new()
	preview.custom_minimum_size.y = 220
	preview.add_theme_stylebox_override("panel", _panel_style(Color("211c27"), Color("72526e")))
	right.add_child(preview)
	var pb := HBoxContainer.new()
	pb.add_theme_constant_override("separation", 18)
	preview.add_child(pb)
	var placeholder := PanelContainer.new()
	placeholder.custom_minimum_size.x = 220
	placeholder.add_theme_stylebox_override("panel", _panel_style(Color("18161d"), Color("594053")))
	pb.add_child(placeholder)
	var silhouette := _text("◯\n│\n╱│╲\n │\n╱ ╲\n\n3D CHARACTER\nPLACEHOLDER", 28, Color("8d7389"))
	silhouette.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placeholder.add_child(silhouette)
	var pi := VBoxContainer.new()
	pi.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pb.add_child(pi)
	preview_title = _text("Character Preview", 20, Color("e8d8e6"))
	pi.add_child(preview_title)
	preview_text = _text("Your future 3D character will appear here.", 13, Color("b7adb9"))
	preview_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pi.add_child(preview_text)

	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(tabs)
	personality_box = _make_tab(tabs, "Personality")
	appearance_box = _make_tab(tabs, "Appearance")
	relationship_box = _make_tab(tabs, "Preferences")
	_build_personality()
	_build_appearance()
	_build_relationship()

	var inspector := PanelContainer.new()
	inspector.custom_minimum_size.y = 120
	inspector.add_theme_stylebox_override("panel", _panel_style(Color("211c27"), Color("403844")))
	right.add_child(inspector)
	var info := VBoxContainer.new()
	inspector.add_child(info)
	stat_title = _text("Select a trait", 16, Color("e8d8e6"))
	info.add_child(stat_title)
	stat_description = _text("Hover over a personality slider for an explanation.", 12, Color("b7adb9"))
	stat_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(stat_description)
	stat_behavior = _text("", 12, Color("c8b2c4"))
	stat_behavior.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(stat_behavior)

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
	var create := Button.new()
	create.text = "CREATE CHARACTER"
	create.pressed.connect(_save)
	buttons.add_child(create)
	status_label = _text("", 12, Color("aaa0ad"))
	buttons.add_child(status_label)

func _make_tab(tabs: TabContainer, title: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = title
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 5)
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
	var row := PanelContainer.new()
	row.add_theme_stylebox_override("panel", _panel_style(Color("1c1920"), Color("332d37")))
	var box := VBoxContainer.new()
	row.add_child(box)
	var top := HBoxContainer.new()
	box.add_child(top)
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(label)
	var value := Label.new()
	value.name = "Value"
	value.text = "%.2f" % initial
	top.add_child(value)
	var slider := HSlider.new()
	slider.name = key
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = initial
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(callback)
	slider.mouse_entered.connect(_show_stat_info.bind(key))
	slider.focus_entered.connect(_show_stat_info.bind(key))
	box.add_child(slider)
	parent.add_child(row)
	stat_rows[key] = row

func _add_text(parent: VBoxContainer, key: String, label_text: String) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 160
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
	_refresh_sliders()
	_refresh_preview()

func _refresh_sliders() -> void:
	for key in PERSONALITY_KEYS:
		var row: PanelContainer = stat_rows.get(key)
		if row == null: continue
		var s := row.find_child(key, true, false) as HSlider
		if s != null:
			s.set_value_no_signal(profile.get_personality_value(key))
			(row.get_node("VBoxContainer/HBoxContainer/Value") as Label).text = "%.2f" % s.value
	for key in ["affection_tendency", "commitment_tendency", "romance_tendency", "social_initiative", "physical_affection_tendency", "teasing_tendency", "initiative_tendency"]:
		var s := relationship_box.find_child(key, true, false) as HSlider
		if s != null:
			s.set_value_no_signal(float(profile.preferences.get(key)))
			(s.get_parent().get_parent().get_node("HBoxContainer/Value") as Label).text = "%.2f" % s.value

func _refresh_preview() -> void:
	var name := profile.get_character_name()
	preview_title.text = name if not name.is_empty() else "Character Preview"
	preview_text.text = _archetype_summary(profile.archetype)
	archetype_summary.text = _archetype_summary(profile.archetype)

func _archetype_summary(name: String) -> String:
	match name:
		"Loving Caring GF": return "Warm, affectionate, patient, and strongly relationship-oriented."
		"Mommy Domme": return "Confident, assertive, nurturing, and comfortable taking initiative."
		"Bimbo": return "Highly social, playful, spontaneous, and open to novelty."
		"Party Girl": return "Extremely social and spontaneous, energized by activity and company."
		"Brat": return "Playful, assertive, mischievous, and inclined toward teasing and testing."
		"Shy Romantic": return "Cautious and reserved but deeply romantic; may want connection without taking the first step."
		"Confident Flirt": return "Socially bold, playful, spontaneous, and comfortable taking initiative."
		"Independent Career Woman": return "Self-directed, confident, patient, and strongly motivated by autonomy."
		"Nurturing": return "Highly empathetic and patient, naturally attentive to other people's needs."
		"Playful": return "Curious, open, spontaneous, and strongly motivated by humor and novelty."
		"Tsundere": return "Assertive and emotionally guarded, with feelings that may be expressed indirectly."
	return "A balanced starting point with room to shape the personality yourself."

func _show_stat_info(key: String) -> void:
	if not STAT_DESCRIPTIONS.has(key): return
	stat_title.text = PERSONALITY_LABELS.get(key, key)
	stat_description.text = STAT_DESCRIPTIONS[key]
	stat_behavior.text = _behavior_summary(key, profile.get_personality_value(key))

func _behavior_summary(key: String, value: float) -> String:
	var level := "moderate"
	if value < 0.33: level = "low"
	elif value > 0.66: level = "high"
	match key:
		"confidence": return "%s values may correspond to hesitation versus self-assurance." % level.capitalize()
		"empathy": return "%s values may correspond to weaker versus stronger awareness of other people's feelings." % level.capitalize()
		"assertiveness": return "%s values may correspond to indirect versus direct expression of wants." % level.capitalize()
		"curiosity": return "%s values may correspond to less versus more desire to investigate the unfamiliar." % level.capitalize()
		"openness": return "%s values may correspond to resistance versus receptiveness to new experiences." % level.capitalize()
		"sociability": return "%s values may correspond to preferring solitude versus actively seeking company." % level.capitalize()
		"caution": return "%s values may correspond to impulsive action versus deliberate consideration of consequences." % level.capitalize()
		"playfulness": return "%s values may correspond to seriousness versus humor, teasing, and playful behavior." % level.capitalize()
		"resilience": return "%s values may correspond to setbacks lingering versus being recovered from quickly." % level.capitalize()
		"patience": return "%s values may correspond to frustration arriving sooner versus waiting comfortably." % level.capitalize()
		"independence": return "%s values may correspond to relying on herself versus seeking support more readily." % level.capitalize()
		"romanticism": return "%s values may correspond to romance being less central versus highly important." % level.capitalize()
		"jealousy": return "%s values may correspond to relationship threats having less versus more emotional impact." % level.capitalize()
		"spontaneity": return "%s values may correspond to structured planning versus acting on impulse." % level.capitalize()
	return ""

func _on_name_changed(value: String) -> void:
	profile.biography.first_name = value
	profile.biography.preferred_name = value
	_refresh_preview()

func _on_age_changed(value: float) -> void:
	profile.biography.age = int(value)

func _on_archetype_selected(index: int) -> void:
	profile.archetype = CharacterArchetypes.NAMES[index]
	CharacterArchetypes.apply(profile, profile.archetype)
	_refresh_sliders()
	_refresh_preview()
	status_label.text = "Applied %s starting values." % profile.archetype

func _on_personality(value: float, key: String) -> void:
	profile.set_personality(key, value)
	var row: PanelContainer = stat_rows.get(key)
	if row != null:
		(row.get_node("VBoxContainer/HBoxContainer/Value") as Label).text = "%.2f" % value
	_show_stat_info(key)

func _on_relationship(value: float, key: String) -> void:
	profile.preferences.set_creator_relationship_value(key, value)
	var s := relationship_box.find_child(key, true, false) as HSlider
	if s != null:
		(s.get_parent().get_parent().get_node("HBoxContainer/Value") as Label).text = "%.2f" % value

func _on_appearance(value: float, key: String) -> void:
	profile.appearance.set(key, value)
	_refresh_preview()

func _on_appearance_text(value: String, key: String) -> void:
	profile.appearance.set(key, value)

func _randomize() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for key in PERSONALITY_KEYS:
		profile.set_personality(key, rng.randf())
	for key in ["affection_tendency", "commitment_tendency", "romance_tendency", "social_initiative", "physical_affection_tendency", "teasing_tendency", "initiative_tendency"]:
		profile.preferences.set_creator_relationship_value(key, rng.randf())
	_refresh_sliders()
	_refresh_preview()
	status_label.text = "Fine-tuning randomized; archetype remains %s." % profile.archetype

func _save() -> void:
	DirAccess.make_dir_recursive_absolute("user://characters")
	var path := "user://characters/%s.tres" % profile.character_id
	var result := ResourceSaver.save(profile, path)
	status_label.text = "Saved: %s" % path if result == OK else "Save failed: %s" % result
