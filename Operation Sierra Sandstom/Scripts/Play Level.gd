extends Control

func _ready():
	$MapTitle.text = MissionSelectionHandler.selected_map_name

func _on_PlayButton_pressed():
	get_tree().change_scene(MissionSelectionHandler.selected_map_path)
