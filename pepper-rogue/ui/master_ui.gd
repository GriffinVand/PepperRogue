extends CanvasLayer

func _ready() -> void:
	UiManager.hud_layer = $Global_Root/HUD_Layer
	UiManager.menu_layer = $Global_Root/Menu_Layer
	UiManager.system_layer = $Global_Root/System_Layer
