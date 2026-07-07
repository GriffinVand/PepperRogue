class_name Enemy
extends CharacterBody3D

@export var collision_dict : Dictionary[String, Array] = {"None" : [0.0, Combatant.DamageResult.NONE]}
@export var allegiance : Combatant.Allegiance = Combatant.Allegiance.ENEMY
@export var health : float = 10.0
var current_health = health

func _ready() -> void:
	current_health = health

func receive_damage(other_allegiance : Combatant.Allegiance, shape : int, damage : float) -> Array:
	var damage_result : Array = [Combatant.DamageResult.NONE, 0.0]
	if other_allegiance == allegiance:
		return damage_result
	var index = shape_find_owner(shape)
	var collider = shape_owner_get_owner(index)
	
	if collider:
		print(collider.name)
		var modified_damage = damage * collision_dict[collider.name][0]
		damage_result[0] = collision_dict[collider.name][1]
		damage_result[1] = modified_damage
		current_health -= modified_damage
		current_health = clamp(current_health, 0, health)
		if current_health <= 0:
			damage_result[0] = Combatant.DamageResult.KILL
			die()
	return damage_result
	
func die():
	queue_free()
	
