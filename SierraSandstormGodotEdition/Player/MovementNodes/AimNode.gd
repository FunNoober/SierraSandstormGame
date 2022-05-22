extends Node

func aim_down_sights(is_aiming, aim_tween, camera, hands, original_hand_pos, aim_position):
	if Input.is_action_just_pressed("ads"):
		if is_aiming == true:
			is_aiming = false
			aim_tween.interpolate_property(hands, 'translation', aim_position.translation, original_hand_pos, 1)
			aim_tween.start()
			camera.fov = 90
			return is_aiming
		if is_aiming == false:
			is_aiming = true
			aim_tween.interpolate_property(hands, 'translation', original_hand_pos, aim_position.translation, 1)
			aim_tween.start()
			camera.fov = 50
			return is_aiming
	return is_aiming
