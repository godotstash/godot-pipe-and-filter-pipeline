extends Label
var boot_payload:Dictionary= {}


@export 
var key_name:String

@export 
var default_value:String

func _on_boot(_boot_payload:Dictionary)->void:
	boot_payload.merge(_boot_payload)

func _on_sync_ui_state(state_payload:Dictionary)-> void:
	## here we get only the key we need
	var key_value = state_payload.get(key_name,default_value)
	text = str(key_value)
	
func _ready() -> void:
	GlobalEventBus.connect("on_boot", _on_boot)
	GlobalEventBus.connect("sync_ui_state", _on_sync_ui_state)	
