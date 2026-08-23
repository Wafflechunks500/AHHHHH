class_name CharacterArchetypes
extends RefCounted

# Archetypes are starting configurations, not permanent personality types.
# Applying one establishes defaults that the creator can then fine-tune.

const NAMES := [
	"Balanced",
	"Loving Caring GF",
	"Mommy Domme",
	"Bimbo",
	"Party Girl",
	"Brat",
	"Shy Romantic",
	"Confident Flirt",
	"Independent Career Woman",
	"Nurturing",
	"Playful",
	"Tsundere"
]

const PERSONALITY_KEYS := [
	"confidence", "empathy", "assertiveness", "curiosity", "openness",
	"sociability", "caution", "playfulness", "resilience", "patience",
	"independence", "romanticism", "jealousy", "spontaneity"
]

static func apply(profile: CharacterProfile, archetype_name: String) -> void:
	profile.initialize()
	var values := values_for(archetype_name)
	for key in values:
		profile.set_personality(key, values[key])

	# Archetypes can also establish broad relationship tendencies.
	var relationship := relationship_values_for(archetype_name)
	for key in relationship:
		profile.preferences.set_creator_relationship_value(key, relationship[key])

static func values_for(archetype_name: String) -> Dictionary:
	var v := {}
	for key in PERSONALITY_KEYS:
		v[key] = 0.5

	match archetype_name:
		"Loving Caring GF":
			v.merge({"confidence":0.55,"empathy":0.90,"assertiveness":0.45,"sociability":0.65,"playfulness":0.70,"patience":0.80,"romanticism":0.95,"jealousy":0.30})
		"Mommy Domme":
			v.merge({"confidence":0.88,"empathy":0.78,"assertiveness":0.95,"sociability":0.65,"patience":0.75,"independence":0.75,"playfulness":0.65})
		"Bimbo":
			v.merge({"confidence":0.70,"empathy":0.55,"assertiveness":0.60,"curiosity":0.65,"openness":0.85,"sociability":0.90,"caution":0.25,"playfulness":0.95,"spontaneity":0.90})
		"Party Girl":
			v.merge({"confidence":0.75,"sociability":0.98,"openness":0.85,"caution":0.20,"playfulness":0.90,"spontaneity":0.95,"independence":0.70})
		"Brat":
			v.merge({"confidence":0.75,"assertiveness":0.85,"empathy":0.45,"sociability":0.70,"playfulness":0.95,"patience":0.25,"spontaneity":0.80})
		"Shy Romantic":
			v.merge({"confidence":0.28,"empathy":0.75,"assertiveness":0.20,"sociability":0.28,"caution":0.85,"patience":0.75,"romanticism":0.90,"playfulness":0.45})
		"Confident Flirt":
			v.merge({"confidence":0.92,"assertiveness":0.75,"sociability":0.88,"caution":0.20,"playfulness":0.85,"openness":0.75,"spontaneity":0.75})
		"Independent Career Woman":
			v.merge({"confidence":0.80,"assertiveness":0.75,"empathy":0.60,"sociability":0.50,"caution":0.60,"patience":0.70,"independence":0.95,"conscientiousness":0.90})
		"Nurturing":
			v.merge({"confidence":0.55,"empathy":0.98,"assertiveness":0.40,"patience":0.95,"romanticism":0.75,"sociability":0.60})
		"Playful":
			v.merge({"confidence":0.65,"sociability":0.78,"playfulness":0.98,"spontaneity":0.88,"curiosity":0.80,"openness":0.82})
		"Tsundere":
			v.merge({"confidence":0.65,"empathy":0.55,"assertiveness":0.75,"sociability":0.45,"caution":0.70,"playfulness":0.65,"romanticism":0.80,"jealousy":0.55})

	return v

static func relationship_values_for(archetype_name: String) -> Dictionary:
	match archetype_name:
		"Loving Caring GF": return {"affection":0.90,"commitment":0.90,"romance":0.95,"social_initiative":0.60}
		"Mommy Domme": return {"affection":0.70,"commitment":0.70,"romance":0.65,"social_initiative":0.85}
		"Party Girl": return {"affection":0.55,"commitment":0.35,"romance":0.55,"social_initiative":0.95}
		"Shy Romantic": return {"affection":0.80,"commitment":0.75,"romance":0.90,"social_initiative":0.20}
		"Confident Flirt": return {"affection":0.55,"commitment":0.40,"romance":0.65,"social_initiative":0.95}
		"Tsundere": return {"affection":0.70,"commitment":0.65,"romance":0.85,"social_initiative":0.30}
		_: return {"affection":0.50,"commitment":0.50,"romance":0.50,"social_initiative":0.50}
