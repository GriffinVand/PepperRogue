class_name WeaponController
extends Node3D

var current_weapon : Weapon
var current_weapon_scene : PackedScene
var player : Player
var camera_pivot : Node3D
var camera : Camera3D

var ads_delta : float = 0.0
var should_ads : bool = false
var should_fire : bool = false
var cooldown_expired : bool = true

func _ready() -> void:
	$Fire_Cooldown.timeout.connect(on_fire_cooldown_expired)

func equip_weapon(path : String):
	current_weapon_scene = load(path)
	if(!current_weapon_scene):
		print("Null current weapon scene weapon_controller::equip_weapon")
		return
	current_weapon = current_weapon_scene.instantiate() as Weapon
	if(!current_weapon):
		print("Failed to create weapon weapon_controller::equip_weapon")
		return
	
	ads_delta = 0.0
	
	current_weapon.controller = self
	player.weapon_pivot.add_child(current_weapon)

func _process(delta: float) -> void:
	update_ads_delta(delta)
	
	if should_fire and cooldown_expired and current_weapon.can_fire():
		cooldown_expired = false
		$Fire_Cooldown.start(current_weapon.fire_rate)
		current_weapon.fire()
	
func on_fire_cooldown_expired():
	cooldown_expired = true

func fire_pressed():
	should_fire = true

func fire_released():
	should_fire = false
		
func altfire_pressed():
		should_ads = true
		
func altfire_released():
		should_ads = false
		
func update_ads_delta(delta: float) -> void:
	var prev = ads_delta
	var ads_speed = current_weapon.ads_speed
	ads_delta = ads_delta + ads_speed * delta if should_ads else ads_delta - ads_speed * delta
	if ads_delta == prev:
		return
	ads_delta = clampf(ads_delta, 0, 1)
	current_weapon.update_ads(ads_delta)
	player.camera.fov = lerp(current_weapon.hip_fov, current_weapon.ads_fov, ads_delta)
