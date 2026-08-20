class_name CharacterAppearance
extends Resource


# ============================================================
# CHARACTER APPEARANCE
#
# Represents the character's physical appearance and current
# visual presentation.
#
# Appearance includes:
#
#     Physical features
#     Hair
#     Face
#     Body
#     Skin
#     Distinguishing features
#     Clothing
#     Accessories
#     Fashion/style
#
# IMPORTANT:
#
# Appearance describes what the character currently looks like.
#
# Preferences describe what she likes.
#
# The brain can eventually decide to change clothing or
# presentation based on:
#
#     Situation
#     Goals
#     Preferences
#     Weather
#     Social context
#     Activity
#     Emotion
#     Relationships
#
# ============================================================


# ============================================================
# BASIC APPEARANCE
# ============================================================

## General description of the character's appearance.

@export_multiline
var appearance_description: String = ""


## Height in centimeters.

@export_range(0.0, 300.0)
var height_cm: float = 170.0


## General body build.

@export var body_build: String = "average"


## General body shape.

@export var body_shape: String = "average"


## Skin tone description.

@export var skin_tone: String = ""


## Skin undertone.

@export var skin_undertone: String = ""


# ============================================================
# FACE
# ============================================================

## General face shape.

@export var face_shape: String = ""


## Eye color.

@export var eye_color: String = ""


## Eye shape or general description.

@export var eye_shape: String = ""


## Eyebrow description.

@export var eyebrows: String = ""


## Nose description.

@export var nose: String = ""


## Lip description.

@export var lips: String = ""


## General facial features.

@export var facial_features: String = ""


## Makeup currently being worn.

@export var makeup: String = ""


# ============================================================
# HAIR
# ============================================================

## Hair color.

@export var hair_color: String = ""


## Hair length.

@export var hair_length: String = ""


## Hair style.

@export var hair_style: String = ""


## Hair texture.

@export var hair_texture: String = ""


## Whether the hair is currently styled.

@export var hair_styling: String = ""


# ============================================================
# BODY FEATURES
# ============================================================

## General description of the character's physique.

@export_multiline
var physique_description: String = ""


## Visible physical characteristics.

var physical_features: Array[String] = []


## Distinguishing marks.

var distinguishing_features: Array[String] = []


## Tattoos.

var tattoos: Array[Dictionary] = []


## Piercings.

var piercings: Array[Dictionary] = []


## Scars.

var scars: Array[Dictionary] = []


# ============================================================
# CLOTHING
#
# Clothing is represented as individual garments so the brain
# can eventually reason about specific pieces.
# ============================================================

## Current garments being worn.

var current_clothing: Array[Dictionary] = []


## Current footwear.

var footwear: Dictionary = {}


## Current accessories.

var accessories: Array[Dictionary] = []


## Current outfit's overall style.

@export var outfit_style: String = ""


## General adjectives describing the current outfit.
##
## Examples:
##
##     casual
##     loose
##     fitted
##     tight
##     athletic
##     formal
##     revealing
##     conservative
##     fashionable
##     practical
##
## These are descriptive tags, not behavioral commands.

var outfit_tags: Array[String] = []


## Main colors currently present in the outfit.

var outfit_colors: Array[String] = []


## General reason for the current outfit.
##
## Examples:
##
##     casual
##     work
##     gym
##     sleep
##     formal_event
##     date
##     weather
##     personal_choice

@export var outfit_context: String = ""


# ============================================================
# FASHION IDENTITY
#
# These describe the character's broader visual style.
#
# They are not necessarily what she is wearing right now.
# ============================================================

## General fashion identity.

@export var fashion_style: String = ""


## Fashion descriptors associated with the character.

var fashion_tags: Array[String] = []


## Colors the character is commonly associated with.

var preferred_fashion_colors: Array[String] = []


## Types of clothing commonly associated with her style.

var signature_clothing: Array[String] = []


## Fashion styles she commonly presents herself with.

var style_identities: Array[String] = []


# ============================================================
# PRESENTATION
# ============================================================

## General description of how the character presents herself.

@export_multiline
var presentation_description: String = ""


## Overall visual impression.

@export var visual_impression: String = ""


## How polished the character currently appears.

@export_range(0.0, 1.0)
var grooming_level: float = 0.75


## How carefully coordinated the current appearance is.

@export_range(0.0, 1.0)
var outfit_coordination: float = 0.70


## How much effort appears to have gone into the current
## presentation.

@export_range(0.0, 1.0)
var presentation_effort: float = 0.60


# ============================================================
# CLOTHING MANAGEMENT
# ============================================================

## Add a garment to the current outfit.
##
## garment_type:
##     shirt
##     pants
##     skirt
##     dress
##     underwear
##     jacket
##     socks
##     etc.
##
## description:
##     Human-readable description of the garment.
##
## color:
##     Primary color.
##
## fit:
##     loose
##     relaxed
##     fitted
##     tight
##     oversized
##
## style:
##     casual
##     athletic
##     formal
##     etc.
##
## tags:
##     Additional descriptive characteristics.

func add_clothing(
	garment_type: String,
	description: String,
	color: String = "",
	fit: String = "",
	style: String = "",
	tags: Array[String] = []
) -> void:

	var garment := {
		"type": garment_type,
		"description": description,
		"color": color,
		"fit": fit,
		"style": style,
		"tags": tags
	}

	current_clothing.append(garment)


## Remove clothing by type.

func remove_clothing_type(
	garment_type: String
) -> void:

	for i in range(current_clothing.size() - 1, -1, -1):

		if current_clothing[i].get("type", "") == garment_type:
			current_clothing.remove_at(i)


## Clear the current outfit.

func clear_clothing() -> void:

	current_clothing.clear()
	footwear.clear()
	accessories.clear()

	outfit_style = ""
	outfit_tags.clear()
	outfit_colors.clear()
	outfit_context = ""


## Set footwear.

func set_footwear(
	description: String,
	color: String = "",
	style: String = "",
	tags: Array[String] = []
) -> void:

	footwear = {
		"description": description,
		"color": color,
		"style": style,
		"tags": tags
	}


## Add an accessory.

func add_accessory(
	accessory_type: String,
	description: String,
	color: String = "",
	tags: Array[String] = []
) -> void:

	var accessory := {
		"type": accessory_type,
		"description": description,
		"color": color,
		"tags": tags
	}

	accessories.append(accessory)


# ============================================================
# FASHION TAGS
# ============================================================

func add_outfit_tag(
	tag: String
) -> void:

	if tag.strip_edges() == "":
		return

	if not outfit_tags.has(tag):
		outfit_tags.append(tag)


func remove_outfit_tag(
	tag: String
) -> void:

	outfit_tags.erase(tag)


func has_outfit_tag(
	tag: String
) -> bool:

	return outfit_tags.has(tag)


func add_fashion_tag(
	tag: String
) -> void:

	if tag.strip_edges() == "":
		return

	if not fashion_tags.has(tag):
		fashion_tags.append(tag)


func remove_fashion_tag(
	tag: String
) -> void:

	fashion_tags.erase(tag)


func has_fashion_tag(
	tag: String
) -> bool:

	return fashion_tags.has(tag)


# ============================================================
# PHYSICAL FEATURES
# ============================================================

func add_physical_feature(
	feature: String
) -> void:

	if feature.strip_edges() == "":
		return

	if not physical_features.has(feature):
		physical_features.append(feature)


func add_distinguishing_feature(
	feature: String
) -> void:

	if feature.strip_edges() == "":
		return

	if not distinguishing_features.has(feature):
		distinguishing_features.append(feature)


# ============================================================
# TATTOOS / PIERCINGS / SCARS
# ============================================================

func add_tattoo(
	description: String,
	location: String,
	visibility: String = "visible"
) -> void:

	tattoos.append({
		"description": description,
		"location": location,
		"visibility": visibility
	})


func add_piercing(
	description: String,
	location: String,
	visibility: String = "visible"
) -> void:

	piercings.append({
		"description": description,
		"location": location,
		"visibility": visibility
	})


func add_scar(
	description: String,
	location: String,
	visibility: String = "visible"
) -> void:

	scars.append({
		"description": description,
		"location": location,
		"visibility": visibility
	})


# ============================================================
# OUTFIT DESCRIPTION
# ============================================================

## Produces a human-readable description of what the character
## is currently wearing.

func get_outfit_description() -> String:

	var parts: Array[String] = []

	for garment in current_clothing:

		var description: String = garment.get(
			"description",
			""
		)

		if description != "":
			parts.append(description)

	if not footwear.is_empty():

		var footwear_description: String = footwear.get(
			"description",
			""
		)

		if footwear_description != "":
			parts.append(footwear_description)

	for accessory in accessories:

		var accessory_description: String = accessory.get(
			"description",
			""
		)

		if accessory_description != "":
			parts.append(accessory_description)

	if parts.is_empty():
		return "No clothing description specified."

	return ", ".join(parts)


# ============================================================
# APPEARANCE DESCRIPTION
# ============================================================

## Produces a human-readable description of the character's
## physical appearance.

func get_physical_description() -> String:

	var parts: Array[String] = []

	if height_cm > 0.0:
		parts.append(
			"%.0f cm tall" % height_cm
		)

	if body_build != "":
		parts.append(body_build + " build")

	if body_shape != "":
		parts.append(body_shape + " body shape")

	if skin_tone != "":
		parts.append(
			skin_tone + " skin"
		)

	if hair_color != "":
		parts.append(
			hair_color + " hair"
		)

	if hair_length != "":
		parts.append(hair_length + " hair")

	if hair_style != "":
		parts.append(
			hair_style + " hairstyle"
		)

	if eye_color != "":
		parts.append(
			eye_color + " eyes"
		)

	if face_shape != "":
		parts.append(
			face_shape + " face"
		)

	if facial_features != "":
		parts.append(facial_features)

	return ", ".join(parts)


# ============================================================
# FULL APPEARANCE DESCRIPTION
# ============================================================

## Produces a description combining physical appearance,
## clothing, fashion, and presentation.

func get_full_appearance_description() -> String:

	var result := ""

	var physical := get_physical_description()

	if physical != "":
		result += physical

	var outfit := get_outfit_description()

	if outfit != "":
		if result != "":
			result += ". "

		result += "Wearing " + outfit

	if fashion_style != "":
		result += ". Fashion style: " + fashion_style

	if outfit_style != "":
		result += ". Current outfit style: " + outfit_style

	if outfit_tags.size() > 0:
		result += ". Outfit descriptors: " \
			+ ", ".join(outfit_tags)

	if presentation_description != "":
		result += ". " + presentation_description

	return result


# ============================================================
# INFORMATION FOR THE CHARACTER SYSTEM
# ============================================================

func get_appearance_state() -> Dictionary:

	return {
		"appearance_description": appearance_description,
		"height_cm": height_cm,
		"body_build": body_build,
		"body_shape": body_shape,
		"skin_tone": skin_tone,
		"skin_undertone": skin_undertone,
		"face_shape": face_shape,
		"eye_color": eye_color,
		"eye_shape": eye_shape,
		"hair_color": hair_color,
		"hair_length": hair_length,
		"hair_style": hair_style,
		"hair_texture": hair_texture,
		"makeup": makeup,
		"current_clothing": current_clothing,
		"footwear": footwear,
		"accessories": accessories,
		"outfit_style": outfit_style,
		"outfit_tags": outfit_tags,
		"outfit_colors": outfit_colors,
		"outfit_context": outfit_context,
		"fashion_style": fashion_style,
		"fashion_tags": fashion_tags,
		"preferred_fashion_colors": preferred_fashion_colors,
		"signature_clothing": signature_clothing,
		"style_identities": style_identities,
		"grooming_level": grooming_level,
		"outfit_coordination": outfit_coordination,
		"presentation_effort": presentation_effort
	}


# ============================================================
# DEBUG SUMMARY
# ============================================================

func get_summary() -> String:

	return (
		"Height: %.0f cm | " +
		"Build: %s | " +
		"Body shape: %s | " +
		"Hair: %s | " +
		"Eyes: %s | " +
		"Clothing pieces: %d | " +
		"Accessories: %d | " +
		"Fashion: %s"
	) % [
		height_cm,
		body_build,
		body_shape,
		hair_color,
		eye_color,
		current_clothing.size(),
		accessories.size(),
		fashion_style
	]


# ============================================================
# DEBUG
# ============================================================

func print_state() -> void:

	print("========================================")
	print("CHARACTER APPEARANCE")
	print("========================================")

	print("Physical appearance:")
	print(get_physical_description())

	print("")
	print("Current outfit:")
	print(get_outfit_description())

	print("")
	print("Fashion style: ", fashion_style)
	print("Fashion tags: ", fashion_tags)
	print("Outfit tags: ", outfit_tags)

	print("")
	print("Grooming: %.2f" % grooming_level)
	print("Coordination: %.2f" % outfit_coordination)
	print("Presentation effort: %.2f" % presentation_effort)

	print("========================================")
