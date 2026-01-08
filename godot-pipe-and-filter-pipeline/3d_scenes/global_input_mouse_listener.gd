extends Node3D

var has_changes:bool=false 
var active_mouse_position: Vector2 = Vector2.ZERO
var active_mouse_velocity: Vector2 = Vector2.ZERO

var boot_payload:Dictionary = {} 

func _on_boot(_boot_payload:Dictionary):
	## this way we will consume all keys...
	## not what we want... revisiting later..
	boot_payload.merge(_boot_payload)


func _action_has_physical_key(action_name: StringName, keycode:Key)-> bool:
	for ev in InputMap.action_get_events(action_name):
		if ev is InputEventMouseButton and ev.button_index == keycode:
			return true	
	return false
	
	
func _ensure_click_actions_exists()-> void:
	## lets create input events at runtime..
	var actions = {
		"left_click":[MOUSE_BUTTON_LEFT],
		"right_click":[MOUSE_BUTTON_RIGHT],
		"middle_click":[MOUSE_BUTTON_MIDDLE]
	}
	
	for action_name in actions.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		for keycode in actions[action_name]:
			if not _action_has_physical_key(action_name,keycode):
				var e = InputEventMouseButton.new()
				e.button_index = keycode
				InputMap.action_add_event(action_name,e)
				

##lets propagate over the eventbus to everyone...
func _process(delta: float) -> void:
	active_mouse_position = get_viewport().get_mouse_position()
	active_mouse_velocity = Input.get_last_mouse_velocity()
	##lets sink/emit a signal if any changes 
	## we can do better later..
	## now we just will render something to canvas...
	has_changes = [
		Input.is_action_just_pressed("left_click")
	].has(true)
	
	if has_changes:
		var pipeline_payload = {
			"pipeline" : [			
				{
				"event_to_emit" : "sync_state",
				"event_payload" : {
					"sender":"global input mouse listener",
					"delta":delta,
					"mouse_velocity":active_mouse_velocity,
					"mouse_position":active_mouse_position
				}
				}
			],
			"global_payload":{
				"test_var":"test_value"
			}
			}
		GlobalEventBus.emit_signal("start_event_pipeline",pipeline_payload)
	
	
	
	
	

func _ready() -> void:
	GlobalEventBus.connect("on_boot",_on_boot)
	_ensure_click_actions_exists()
	
	
