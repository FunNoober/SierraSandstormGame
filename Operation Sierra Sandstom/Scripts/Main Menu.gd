extends Control

func _on_PlayButton_button_down():
	get_tree().change_scene("res://Maps/Test Map.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
