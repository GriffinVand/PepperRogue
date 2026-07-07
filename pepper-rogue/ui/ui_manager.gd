extends Node

const master_ui_path : String = "res://ui/master_ui.tscn"
var master_ui : CanvasLayer
var hud_layer : Control
var menu_layer : Control
var system_layer : Control

func _ready() -> void:
	call_deferred("create_master_ui")
		
func create_master_ui() -> void:
	master_ui = preload(master_ui_path).instantiate()
	if not master_ui:
		print("Failed to create master ui ui_manager::ready")
		return
	get_tree().root.add_child(master_ui)
