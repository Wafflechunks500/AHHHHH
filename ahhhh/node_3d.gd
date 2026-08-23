extends Node3D

func _ready() -> void:
	# Put the exact path to your .fbx here
	var packed = load("res://assets/Medea By M. Arrebola.fbx")
	if packed == null:
		print("Failed to load FBX")
		return

	var instance = packed.instantiate()
	add_child(instance)

	var skel = _find_skeleton(instance)
	if skel == null:
		print("No skeleton found")
		return

	var rename_map = {
		"mixamorig_Hips": "Hips",
		"mixamorig_Spine": "Spine",
		"mixamorig_Spine1": "Spine1",
		"mixamorig_Spine2": "Spine2",
		"mixamorig_Neck": "Neck",
		"mixamorig_Head": "Head",
		"mixamorig_LeftShoulder": "LeftShoulder",
		"mixamorig_LeftArm": "LeftArm",
		"mixamorig_LeftForeArm": "LeftForeArm",
		"mixamorig_LeftHand": "LeftHand",
		"mixamorig_RightShoulder": "RightShoulder",
		"mixamorig_RightArm": "RightArm",
		"mixamorig_RightForeArm": "RightForeArm",
		"mixamorig_RightHand": "RightHand",
		"mixamorig_LeftUpLeg": "LeftUpLeg",
		"mixamorig_LeftLeg": "LeftLeg",
		"mixamorig_LeftFoot": "LeftFoot",
		"mixamorig_LeftToeBase": "LeftToeBase",
		"mixamorig_RightUpLeg": "RightUpLeg",
		"mixamorig_RightLeg": "RightLeg",
		"mixamorig_RightFoot": "RightFoot",
		"mixamorig_RightToeBase": "RightToeBase",
	}

	for i in skel.get_bone_count():
		var old = skel.get_bone_name(i)
		if rename_map.has(old):
			skel.set_bone_name(i, rename_map[old])
			print("Renamed ", old, " → ", rename_map[old])

	print("Rename finished. This is only in memory — nothing was saved.")

func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for c in node.get_children():
		var found = _find_skeleton(c)
		if found: return found
	return null
