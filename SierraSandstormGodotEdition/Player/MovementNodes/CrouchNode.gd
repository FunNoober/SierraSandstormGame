extends Node

func crouch(is_crouched, body_col, crouch_tween):
	if Input.is_action_just_pressed("crouch"):
		if is_crouched == true:
			tween_the_crouch(3, body_col, crouch_tween)
			crouch_tween.start()
			is_crouched = false
			return is_crouched
		if is_crouched == false:
			tween_the_crouch(1.5, body_col, crouch_tween)
			crouch_tween.start()
			is_crouched = true
			return is_crouched
	return is_crouched
		
func tween_the_crouch(amount, body_col, crouch_tween):
	body_col.shape.height = crouch_tween.interpolate_property(body_col.shape, "height", body_col.shape.height, amount, 0.1, Tween.TRANS_LINEAR)
