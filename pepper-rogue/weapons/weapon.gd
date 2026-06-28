class_name Weapon
extends Node3D

var controller : WeaponController

@export var damage = 5.0
@export var fire_rate = 0.5
var fire_delay = 0.0
var can_fire = false
var fire_pressed = false
@export var ads_speed = 5.0
var ads: bool = false
var ads_delta = 0.0


@export_category("Pivots")
@export var ads_node: Node3D
@export var hip_node: Node3D
@export var weapon_mesh: Node3D
@export var recoil_pivot: Node3D
@export var bob_pivot: Node3D
@export var sway_pivot: Node3D
@export var fire_pivot: Node3D


@export_category("Visual Displacement")
@export_group("Sway")
var current_mov = Vector2.ZERO
var target_mov = Vector2.ZERO
@export var max_mov_sway = 3.0

var current_look = Vector2.ZERO
var target_look = Vector2.ZERO
@export var max_look_sway = Vector2(3.0, 6.0)

@export_group("Recoil")
var current_recoil_dir = Vector2.ZERO
var current_recoil_rot = Vector2.ZERO
var target_recoil_dir = Vector2.ZERO
var target_recoil_rot = Vector2.ZERO

@export var recoil_dir = Vector2.ZERO
@export var recoil_rot_multiplier = Vector2.ZERO
@export var max_recoil_dir = Vector2.ZERO
@export var max_recoil_rot = Vector2.ZERO
@export var recoil_apply_speed = Vector2.ZERO
@export var recoil_recov_speed = Vector2.ZERO

@export_group("View Offset")
var current_view_offset = Vector2.ZERO
var target_view_offset = Vector2.ZERO
@export var fire_view_offsets: Array[Vector2] = []
@export var offset_apply_speed = 1.0
@export var offset_recov_speed = 1.0

func _process(delta: float) -> void:
	update_ads(delta)
	update_sway(delta)
	update_recoil(delta)
	update_view_offset(delta)
	if fire_delay < fire_rate:
		fire_delay += delta
	else:
		can_fire = true
		if fire_pressed:
			fire()
	
	
	
func update_ads(delta: float) -> void:
	ads_delta = ads_delta + ads_speed * delta if ads else ads_delta - ads_speed * delta
	ads_delta = clampf(ads_delta, 0, 1)
	weapon_mesh.position = lerp(hip_node.position, ads_node.position, ads_delta)
	weapon_mesh.rotation = lerp(hip_node.rotation, ads_node.rotation, ads_delta)
	
func update_sway(delta: float) -> void:
	var target_look_scaled = Vector2(target_look.x * max_look_sway.x, target_look.y * max_look_sway.y)
	current_look = current_look.move_toward(target_look_scaled, delta * 15.0)
	var target_mov_scaled = target_mov * max_mov_sway
	current_mov = current_mov.move_toward(target_mov_scaled, delta * 15.0)
	sway_pivot.rotation_degrees = Vector3(-current_look.y, -current_look.x, -current_mov.x)
	
func update_recoil(delta: float) -> void:
	current_recoil_dir = current_recoil_dir.move_toward(target_recoil_dir, delta * recoil_apply_speed.x)
	current_recoil_rot = current_recoil_rot.move_toward(target_recoil_rot, delta * recoil_apply_speed.y)
	recoil_pivot.position = Vector3(0.0, current_recoil_dir.x, current_recoil_dir.y)
	recoil_pivot.rotation_degrees = Vector3(-current_recoil_rot.y, -current_recoil_rot.x, 0.0)
	target_recoil_dir = target_recoil_dir.move_toward(Vector2.ZERO, delta * recoil_recov_speed.x)
	target_recoil_rot = target_recoil_rot.move_toward(Vector2.ZERO, delta * recoil_recov_speed.y)
	
func update_view_offset(delta: float) -> void:
	current_view_offset = current_view_offset.move_toward(target_view_offset, delta * offset_apply_speed)
	if controller:
		controller.owner.apply_view_offset(current_view_offset)
	target_view_offset = target_view_offset.move_toward(Vector2.ZERO, delta * offset_recov_speed)
	
func fire() -> void:
	if not controller:
		print("Controller is null weapon::fire")
		return
	
	damage_trace()
	
	fire_delay = 0.0
	can_fire = false
	
	if len(fire_view_offsets) > 0:
		target_view_offset = fire_view_offsets.pick_random()
	
	var recoil_intensity = 1 - (0.5 * ads_delta)
	target_recoil_dir += recoil_dir * recoil_intensity
	#rotation should follow direction of view offset
	target_recoil_rot += target_view_offset * recoil_rot_multiplier * recoil_intensity
	target_recoil_dir.x = clampf(target_recoil_dir.x, -max_recoil_dir.x, max_recoil_dir.x)
	target_recoil_dir.y = clampf(target_recoil_dir.y, -max_recoil_dir.y, max_recoil_dir.y)
	target_recoil_rot.x = clampf(target_recoil_rot.x, -max_recoil_rot.x, max_recoil_rot.x)
	target_recoil_rot.y = clampf(target_recoil_rot.y, -max_recoil_rot.y, max_recoil_rot.y)
	
func damage_trace() -> void:
	if not controller or not controller.camera_pivot or not fire_pivot:
		print("Cannot damage trace weapon::damage_trace")
		return
	var camera_pivot = controller.camera_pivot
	var start = camera_pivot.global_position
	var start_dir = -camera_pivot.global_basis.z
	var end = start + (start_dir * 1000)
	
	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.collide_with_areas = true
	query.exclude = [controller.player]
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if result:
		if result.collider and result.collider.has_method("receive_damage"):
			controller.player.handle_damage_result(result.collider.receive_damage(controller.player.player_allegiance, result.shape, damage))
		DebugDraw3D.draw_line(start, result.position, Color.RED, 0.1)
	
	
	
