class_name Player
extends CharacterBody3D

var player_allegiance : Combatant.Allegiance = Combatant.Allegiance.FRIENDLY 

@export var speed = 10
@export var fall_speed = 75
@export var jump_impulse = 20.0
var vertical_vel = 0.0
@export var sensitivity = 0.01
@export var max_pitch = deg_to_rad(70)
@export var default_weapon_path : String

@onready var camera_pivot : Node3D = $Pivot/CameraPivot
@onready var weapon_pivot : Node3D = $Pivot/CameraPivot/WeaponPivot
@onready var weapon_controller : WeaponController = $Pivot/WeaponController

var pitch = 0.0
var last_mov_alpha = Vector2.ZERO
var last_look_alpha = Vector2.ZERO
var max_look_length = 20.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Pivot/WeaponController.player = self
	$Pivot/WeaponController.camera_pivot = camera_pivot
	$Pivot/WeaponController.equip_weapon(default_weapon_path)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event.is_action_pressed("escape_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event):
	
	if event is InputEventMouseMotion:
		var lookDir = event.relative
		
		last_look_alpha = lookDir
		
		apply_view_offset(lookDir)
	
	if event.is_action_pressed("fire"):
		weapon_controller.fire_pressed()
	elif event.is_action_released("fire"):
		weapon_controller.fire_released()
	
	if event.is_action_pressed("alt_fire"):
		weapon_controller.altfire_pressed()
	elif event.is_action_released("alt_fire"):
		weapon_controller.altfire_released()
		
	
func _physics_process(_delta: float) -> void:
	var moveDir = Vector2.ZERO
	if Input.is_action_pressed("move_fwd"):
		moveDir.y += 1
	if Input.is_action_pressed("move_back"):
		moveDir.y -= 1
	if Input.is_action_pressed("move_left"):
		moveDir.x -= 1
	if Input.is_action_pressed("move_right"):
		moveDir.x += 1
	
	last_mov_alpha = moveDir
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		vertical_vel = jump_impulse
	elif not is_on_floor():
		vertical_vel = vertical_vel - (fall_speed * _delta)
		
	
	var fwd = -$Pivot.global_transform.basis.z
	var right = $Pivot.global_transform.basis.x
	moveDir = (right * moveDir.x + fwd * moveDir.y).normalized()
	velocity = (moveDir * speed) + Vector3(0,vertical_vel,0)
	move_and_slide()
	
func _process(_delta: float) -> void:
	weapon_controller.current_weapon.target_look.x = clamp(last_look_alpha.x / max_look_length, -1.0, 1.0)
	weapon_controller.current_weapon.target_look.y = clamp(last_look_alpha.y / max_look_length, -1.0, 1.0)
	last_look_alpha = Vector2.ZERO
	weapon_controller.current_weapon.target_mov = last_mov_alpha
	
func apply_view_offset(offset: Vector2):
	$Pivot.rotate_y(-offset.x * sensitivity)
	pitch += (-offset.y * sensitivity)
	pitch = clamp(pitch, -max_pitch, max_pitch)
	$Pivot/CameraPivot.rotation.x = pitch
	
func handle_damage_result(damage_result: Array):
	print(damage_result[0])
	print(damage_result[1])
	
	
