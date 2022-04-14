extends Node

func flash_light(flash_enabled, light):
	if flash_enabled == true:
		light.hide()
		flash_enabled = false
		return flash_enabled
	else:
		light.show()
		flash_enabled = true
		return flash_enabled
