class_name WeaponController
extends Node3D

var current_weapon : Weapon
var current_weapon_scene : PackedScene
var player : Player
var camera_pivot : Node3D

func equip_weapon(path : String):
	current_weapon_scene = load(path)
	if(!current_weapon_scene):
		print("Null current weapon scene weapon_controller::equip_weapon")
		return
	current_weapon = current_weapon_scene.instantiate() as Weapon
	if(!current_weapon):
		print("Failed to create weapon weapon_controller::equip_weapon")
		return
	
	current_weapon.controller = self
	player.weapon_pivot.add_child(current_weapon)

func fire_pressed():
	if current_weapon:
		current_weapon.fire_pressed = true

func fire_released():
	if current_weapon:
		current_weapon.fire_pressed = false
		
func altfire_pressed():
	if current_weapon:
		current_weapon.ads = true
		
func altfire_released():
	if current_weapon:
		current_weapon.ads = false
