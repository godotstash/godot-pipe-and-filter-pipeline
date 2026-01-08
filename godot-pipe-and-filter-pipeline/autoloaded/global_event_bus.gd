extends Node


@warning_ignore("unused_signal")
signal sync_ui_state(pipeline_payload:Dictionary)

@warning_ignore("unused_signal")
signal sync_state(pipeline_payload:Dictionary)

func _on_sync_state(pipeline_payload:Dictionary)-> void:
	emit_signal("sync_ui_state",pipeline_payload)


signal start_event_pipeline(pipeline_payload:Dictionary)

func _on_start_event_pipeline(_pipeline_payload:Dictionary)-> void:
	#We will use this later...
	emit_signal("run_event_pipeline",_pipeline_payload)


## we expect at least two keys:
## pipeline_payload = {
## "pipeline:[{
##   "event_to_emit":"event_name", <- just a signal name
##	"event_payload": {
## 		"var_name":"var_value"
## 		} <- We will merge with the global..
## 	}],
## "global_payload:{}
##}	
## 

signal run_event_pipeline(pipeline_payload:Dictionary)
func _on_run_event_pipeline(_pipeline_payload:Dictionary)-> void:
	var active_pipeline = _pipeline_payload.get("pipeline",[])
	if not active_pipeline.is_empty():
		var global_payload:Dictionary = _pipeline_payload.get("global_payload",{})
		## lets pop_front an event
		var event_to_emit = active_pipeline.pop_front()
		var event_payload:Dictionary= event_to_emit.get("event_payload",{})
		var event_name = event_to_emit.get('event_to_emit',"devnull") ## just to allow 
		var next_global_payload: Dictionary = event_payload
		next_global_payload.merge(global_payload)## order here is important..
		var next_pipeline_payload = {}
		next_pipeline_payload["pipeline"] = active_pipeline ## we already pop the first in line
		next_pipeline_payload["global_payload"]= next_global_payload
		if has_signal(event_name):
			## if a signal exists...
			emit_signal(event_name, next_global_payload)
		else:
			## pass downstream the payload
			emit_signal("run_event_pipeline", next_global_payload)

func _ready() -> void:
	connect("sync_state",_on_sync_state)
	connect("start_event_pipeline",_on_start_event_pipeline)
	connect("run_event_pipeline", _on_run_event_pipeline)
