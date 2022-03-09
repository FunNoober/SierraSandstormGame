extends Button

export var mission_path : String
export var mission_name : String

func _ready():
	pass # Replace with function body.


func _on_Button_pressed():
	MissionSelectionHandler.selected_map_path = mission_path
	MissionSelectionHandler.selected_map_name = mission_name
	get_tree().change_scene("res://Maps/Play Level.tscn")
