@tool
extends Skeleton3D

func _ready() -> void:
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
		
		# Fingers - adjust if you want different mapping
		"mixamorig_LeftHandThumb1": "LeftHandThumb1",
		"mixamorig_LeftHandThumb2": "LeftHandThumb2",
		"mixamorig_LeftHandThumb3": "LeftHandThumb3",
		"mixamorig_LeftHandIndex1": "LeftHandIndex1",
		"mixamorig_LeftHandIndex2": "LeftHandIndex2",
		"mixamorig_LeftHandIndex3": "LeftHandIndex3",
		"mixamorig_LeftHandMiddle1": "LeftHandMiddle1",
		"mixamorig_LeftHandMiddle2": "LeftHandMiddle2",
		"mixamorig_LeftHandMiddle3": "LeftHandMiddle3",
		"mixamorig_LeftHandRing1": "LeftHandRing1",
		"mixamorig_LeftHandRing2": "LeftHandRing2",
		"mixamorig_LeftHandRing3": "LeftHandRing3",
		"mixamorig_LeftHandPinky1": "LeftHandPinky1",
		"mixamorig_LeftHandPinky2": "LeftHandPinky2",
		"mixamorig_LeftHandPinky3": "LeftHandPinky3",
		
		"mixamorig_RightHandThumb1": "RightHandThumb1",
		"mixamorig_RightHandThumb2": "RightHandThumb2",
		"mixamorig_RightHandThumb3": "RightHandThumb3",
		"mixamorig_RightHandIndex1": "RightHandIndex1",
		"mixamorig_RightHandIndex2": "RightHandIndex2",
		"mixamorig_RightHandIndex3": "RightHandIndex3",
		"mixamorig_RightHandMiddle1": "RightHandMiddle1",
		"mixamorig_RightHandMiddle2": "RightHandMiddle2",
		"mixamorig_RightHandMiddle3": "RightHandMiddle3",
		"mixamorig_RightHandRing1": "RightHandRing1",
		"mixamorig_RightHandRing2": "RightHandRing2",
		"mixamorig_RightHandRing3": "RightHandRing3",
		"mixamorig_RightHandPinky1": "RightHandPinky1",
		"mixamorig_RightHandPinky2": "RightHandPinky2",
		"mixamorig_RightHandPinky3": "RightHandPinky3",
	}

	for i in get_bone_count():
		var old_name = get_bone_name(i)
		if rename_map.has(old_name):
			set_bone_name(i, rename_map[old_name])
			print("Renamed: ", old_name, " → ", rename_map[old_name])

	print("Done renaming")
