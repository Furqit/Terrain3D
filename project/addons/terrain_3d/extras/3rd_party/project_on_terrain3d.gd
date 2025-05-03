# Copyright © 2025 Cory Petkovsek, Roope Palmroos, and Contributors.
# This script is an addon for HungryProton's Scatter https://github.com/HungryProton/scatter
# It provides a `Project on Terrain3D` modifier, which allows Scatter 
# to detect the terrain height from Terrain3D without using collision.
#
# Copy this file into /addons/proton_scatter/src/modifiers
# Then uncomment everything below (select, press CTRL+K)
# In the editor, add this modifier to Scatter, then set your Terrain3D node

#@tool
#extends "base_modifier.gd"
#
#
#signal projection_completed
#
#
#@export var terrain_node : NodePath
#@export var align_with_collision_normal := false
#@export_range(0.0, 90.0, 0.1) var max_slope = 90.0
#@export var enable_texture_filtering := false
#@export_range(0, 31) var target_texture_idx := 0
#@export var invert_texture_check := false
#@export_range(0.0, 1.0, 0.01) var texture_threshold := 0.8
#
#var _terrain: Terrain3D
#
#
#func _init() -> void:
	#display_name = "Project On Terrain3D"
	#category = "Edit"
	#can_restrict_height = false
	#global_reference_frame_available = true
	#local_reference_frame_available = true
	#individual_instances_reference_frame_available = true
	#use_global_space_by_default()
#
	#documentation.add_paragraph(
		#"This is a duplicate of `Project on Colliders` that queries the terrain system
		#for height and sets the transform height appropriately.
		#It also includes a texture filtering feature.
#
		#This modifier must have terrain_node set to a Terrain3D node.")
#
	#var p := documentation.add_parameter("Terrain Node")
	#p.set_type("NodePath")
	#p.set_description("Set your Terrain3D node.")
		#
	#p = documentation.add_parameter("Align with collision normal")
	#p.set_type("bool")
	#p.set_description(
		#"Rotate the transform to align it with the collision normal in case
		#the ray cast hit a collider.")
		#
	#p = documentation.add_parameter("Enable Texture Filtering")
	#p.set_type("bool")
	#p.set_description(
		#"If enabled, objects will only be placed based on the texture filtering options.")
		#
	#p = documentation.add_parameter("Target Texture Id")
	#p.set_type("int")
	#p.set_description(
		#"The index of the texture to place objects on (0-31). Objects will only be placed on this texture.")
		#
	#p = documentation.add_parameter("Invert Texture Check")
	#p.set_type("bool") 
	#p.set_description(
		#"If true, objects will be placed on all textures EXCEPT the target texture.")
		#
	#p = documentation.add_parameter("Texture Threshold")
	#p.set_type("float") 
	#p.set_description("How dominant the target texture must be for object placement (0.0-1.0). Lower values allow placement on mixed textured areas.")
#
#func _get_texture_idx(control_value: int) -> int:
	#return (control_value >> 27) & 0x1F
#
#func _get_texture_blend(control_value: int) -> float:
	#return float((control_value >> 14) & 0xFF) / 255.0  
#
#func _process_transforms(transforms, domain, _seed) -> void:
	#if transforms.is_empty():
		#return
#
	#if terrain_node:
		#_terrain = domain.get_root().get_node_or_null(terrain_node)
#
	#if not _terrain:
		#warning += """No Terrain3D node found"""
		#return
#
	#if not _terrain.data:
		#warning += """Terrain3DData is not initialized"""
		#return
#
	## Get global transform
	#var gt: Transform3D = domain.get_global_transform()
	#var gt_inverse := gt.affine_inverse()
	#var new_transforms_array: Array[Transform3D] = []
	#var remapped_max_slope: float = remap(max_slope, 0.0, 90.0, 0.0, 1.0)
	#for i in transforms.list.size():
		#var t: Transform3D = transforms.list[i]
		#
		#var location: Vector3 = (gt * t).origin
		#var height: float = _terrain.data.get_height(location)
		#var normal: Vector3 = _terrain.data.get_normal(location)
		#
		#var texture_match := true
		#if enable_texture_filtering:
			#var control_value: int = _terrain.data.get_control(location)
			#var texture_idx: int = _get_texture_idx(control_value)
			#var blend_value: float = _get_texture_blend(control_value)
			#
			#var is_base_texture_dominant := blend_value <= (1.0 - texture_threshold)
			#
			#var is_target_texture := texture_idx == target_texture_idx
			#if invert_texture_check:
				#is_target_texture = not is_target_texture
				#
			#texture_match = is_target_texture and is_base_texture_dominant
			#
		#if texture_match:
			#if align_with_collision_normal and not is_nan(normal.x):
				#t.basis.y = normal
				#t.basis.x = -t.basis.z.cross(normal)
				#t.basis = t.basis.orthonormalized()
#
			#if abs(Vector3.UP.dot(normal)) >= (1.0 - remapped_max_slope):
				#t.origin.y = gt.origin.y if is_nan(height) else height - gt.origin.y
				#new_transforms_array.push_back(t)
#
	#transforms.list.clear()
	#transforms.list.append_array(new_transforms_array)
#
	#if transforms.is_empty():
		#var message = """All transforms have been removed. Possible reasons include: \n"""
		#if enable_texture_filtering:
			#message += """+ No matching texture found at any position.
			#+ Texture threshold may be too high.
			#"""
		#message += """+ No collider is close enough to the shapes.
		#+ Ray length is too short.
		#+ Ray direction is incorrect.
		#+ Collision mask is not set properly.
		#+ Max slope is too low.
		#"""
		#warning += message
