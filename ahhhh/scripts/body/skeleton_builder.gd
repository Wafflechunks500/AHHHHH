class_name SkeletonBuilder
extends Node


# ============================================================
# SKELETON BUILDER
#
# Creates a clean, empty Skeleton3D with a realistic humanoid
# hierarchy + sexual anatomy bones.
#
# Naming convention is strict and consistent so the brain and
# body systems can always find bones by name.
# ============================================================


## Call this to create a full skeleton.
## Returns a ready-to-use Skeleton3D node.
static func create_humanoid_skeleton() -> Skeleton3D:
	var skeleton := Skeleton3D.new()
	skeleton.name = "Skeleton3D"

	# --------------------------------------------------------
	# ROOT & HIPS
	# --------------------------------------------------------
	var root := _add_bone(skeleton, "Root", -1)
	var hips := _add_bone(skeleton, "Hips", root)

	# --------------------------------------------------------
	# SPINE CHAIN
	# --------------------------------------------------------
	var spine := _add_bone(skeleton, "Spine", hips)
	var spine1 := _add_bone(skeleton, "Spine1", spine)
	var spine2 := _add_bone(skeleton, "Spine2", spine1)
	var spine3 := _add_bone(skeleton, "Spine3", spine2)

	# --------------------------------------------------------
	# HEAD
	# --------------------------------------------------------
	var neck := _add_bone(skeleton, "Neck", spine3)
	var head := _add_bone(skeleton, "Head", neck)

	# --------------------------------------------------------
	# LEFT ARM
	# --------------------------------------------------------
	var left_shoulder := _add_bone(skeleton, "LeftShoulder", spine3)
	var left_arm := _add_bone(skeleton, "LeftArm", left_shoulder)
	var left_forearm := _add_bone(skeleton, "LeftForeArm", left_arm)
	var left_hand := _add_bone(skeleton, "LeftHand", left_forearm)

	_add_fingers(skeleton, left_hand, "Left")

	# --------------------------------------------------------
	# RIGHT ARM
	# --------------------------------------------------------
	var right_shoulder := _add_bone(skeleton, "RightShoulder", spine3)
	var right_arm := _add_bone(skeleton, "RightArm", right_shoulder)
	var right_forearm := _add_bone(skeleton, "RightForeArm", right_arm)
	var right_hand := _add_bone(skeleton, "RightHand", right_forearm)

	_add_fingers(skeleton, right_hand, "Right")

	# --------------------------------------------------------
	# LEFT LEG
	# --------------------------------------------------------
	var left_up_leg := _add_bone(skeleton, "LeftUpLeg", hips)
	var left_leg := _add_bone(skeleton, "LeftLeg", left_up_leg)
	var left_foot := _add_bone(skeleton, "LeftFoot", left_leg)
	var left_toe := _add_bone(skeleton, "LeftToeBase", left_foot)

	# --------------------------------------------------------
	# RIGHT LEG
	# --------------------------------------------------------
	var right_up_leg := _add_bone(skeleton, "RightUpLeg", hips)
	var right_leg := _add_bone(skeleton, "RightLeg", right_up_leg)
	var right_foot := _add_bone(skeleton, "RightFoot", right_leg)
	var right_toe := _add_bone(skeleton, "RightToeBase", right_foot)

	# --------------------------------------------------------
	# BREASTS
	# --------------------------------------------------------
	var breast_left := _add_bone(skeleton, "BreastLeft", spine3)
	_add_bone(skeleton, "BreastLeft1", breast_left)
	_add_bone(skeleton, "BreastLeft2", breast_left)

	var breast_right := _add_bone(skeleton, "BreastRight", spine3)
	_add_bone(skeleton, "BreastRight1", breast_right)
	_add_bone(skeleton, "BreastRight2", breast_right)

	# --------------------------------------------------------
	# GENITALIA
	# --------------------------------------------------------
	var genital_root := _add_bone(skeleton, "GenitalRoot", hips)

	# Male-oriented chain (can be hidden/disabled on female characters)
	_add_bone(skeleton, "PenisBase", genital_root)
	var shaft1 := _add_bone(skeleton, "PenisShaft1", genital_root)
	var shaft2 := _add_bone(skeleton, "PenisShaft2", shaft1)
	var shaft3 := _add_bone(skeleton, "PenisShaft3", shaft2)
	_add_bone(skeleton, "PenisTip", shaft3)

	# Female-oriented bones
	_add_bone(skeleton, "Clitoris", genital_root)
	_add_bone(skeleton, "LabiaLeft", genital_root)
	_add_bone(skeleton, "LabiaRight", genital_root)
	_add_bone(skeleton, "VaginalEntry", genital_root)

	# Optional soft tissue
	_add_bone(skeleton, "ButtLeft", hips)
	_add_bone(skeleton, "ButtRight", hips)

	# Force the skeleton to update rest pose
	skeleton.reset_bone_poses()

	print("SkeletonBuilder: Created humanoid skeleton with ", skeleton.get_bone_count(), " bones.")
	return skeleton


# ============================================================
# INTERNAL HELPERS
# ============================================================

static func _add_bone(skeleton: Skeleton3D, bone_name: String, parent_idx: int) -> int:
	var idx := skeleton.get_bone_count()
	skeleton.add_bone(bone_name)
	if parent_idx >= 0:
		skeleton.set_bone_parent(idx, parent_idx)

	# Give every bone a small default rest offset so the hierarchy is visible in the editor
	var rest := Transform3D.IDENTITY
	rest.origin = _default_offset(bone_name)
	skeleton.set_bone_rest(idx, rest)

	return idx


static func _add_fingers(skeleton: Skeleton3D, hand_idx: int, side: String) -> void:
	var fingers := ["Thumb", "Index", "Middle", "Ring", "Pinky"]
	for finger in fingers:
		var parent := hand_idx
		for i in range(1, 4):  # 1, 2, 3
			var bone_name := "%sHand%s%d" % [side, finger, i]
			parent = _add_bone(skeleton, bone_name, parent)


static func _default_offset(bone_name: String) -> Vector3:
	# Very simple default offsets just so the bones aren't all stacked on top of each other
	# These are only placeholders — real rest poses will come from a proper rig later.
	match bone_name:
		"Hips":
			return Vector3(0, 1.0, 0)
		"Spine", "Spine1", "Spine2", "Spine3":
			return Vector3(0, 0.15, 0)
		"Neck":
			return Vector3(0, 0.12, 0)
		"Head":
			return Vector3(0, 0.15, 0)
		"LeftShoulder":
			return Vector3(-0.15, 0.1, 0)
		"RightShoulder":
			return Vector3(0.15, 0.1, 0)
		"LeftArm", "RightArm":
			return Vector3(0, -0.25, 0)
		"LeftForeArm", "RightForeArm":
			return Vector3(0, -0.25, 0)
		"LeftHand", "RightHand":
			return Vector3(0, -0.15, 0)
		"LeftUpLeg", "RightUpLeg":
			return Vector3(0, -0.4, 0)
		"LeftLeg", "RightLeg":
			return Vector3(0, -0.4, 0)
		"LeftFoot", "RightFoot":
			return Vector3(0, -0.1, 0.05)
		"BreastLeft":
			return Vector3(-0.12, 0.05, 0.1)
		"BreastRight":
			return Vector3(0.12, 0.05, 0.1)
		"GenitalRoot":
			return Vector3(0, -0.05, 0.08)
		"PenisBase", "PenisShaft1", "PenisShaft2", "PenisShaft3", "PenisTip":
			return Vector3(0, -0.04, 0.06)
		_:
			return Vector3(0, 0.05, 0)


# ============================================================
# UTILITY: Print all bone names (useful for debugging)
# ============================================================

static func print_bone_list(skeleton: Skeleton3D) -> void:
	print("=== Skeleton Bone List (%d bones) ===" % skeleton.get_bone_count())
	for i in skeleton.get_bone_count():
		var parent = skeleton.get_bone_parent(i)
		var parent_name = skeleton.get_bone_name(parent) if parent >= 0 else "None"
		print("%3d | %-20s | parent: %s" % [i, skeleton.get_bone_name(i), parent_name])
	print("=====================================")
