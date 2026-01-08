extends Node3D
var boot_payload:Dictionary= {}



func _on_boot(_boot_payload:Dictionary)->void:
	boot_payload.merge(_boot_payload)

func _ready() -> void:
	GlobalEventBus.connect("on_boot", _on_boot)
	
	
	
