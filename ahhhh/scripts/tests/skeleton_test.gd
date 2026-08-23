extends Node

# ============================================================
# SKELETON TEST
# Creates a pure bone skeleton and prints the full bone list
# ============================================================

func _ready() -> void:
	print("\n========== SKELETON TEST ==========\n")

	# Create the skeleton
	var skeleton := SkeletonBuilder.create_humanoid_skeleton()
	skeleton.name = "TestSkeleton"
	add_child(skeleton)

	# Print every bone so you can verify the hierarchy
	SkeletonBuilder.print_bone_list(skeleton)

	print("\nSkeleton created successfully.")
	print("You can select the Skeleton3D node in the Remote / Scene tree to inspect it.")
	print("====================================\n")
