extends Control

onready var ammo_counter = get_node("AmmoCounter")


func _on_Resume_button_down():
	Engine.time_scale = 1
	get_parent().is_paused = false
	$PauseMenu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	return


func _on_MainMenu_button_down():
	Engine.time_scale = 1
	get_tree().change_scene("res://Maps/Main Menu.tscn")


func _on_SaveandQuit_button_down():
	get_tree().quit()
