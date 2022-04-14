extends Node

func crouch(is_crouched, body_col, crouch_tween):
	if is_crouched == true:
		#Handling un-crouching behaviour
		tween_the_crouch(3, body_col, crouch_tween)
		crouch_tween.start()
		is_crouched = false
		#End
		#Returning to prevent infinite loop
		return is_crouched
		#End
	if is_crouched == false:
		#Handling crouching behaviour
		tween_the_crouch(1.5, body_col, crouch_tween)
		crouch_tween.start()
		is_crouched = true
		#End
		#Returning to prevent infinite loop
		return is_crouched
		#End
		
func tween_the_crouch(amount, body_col, crouch_tween):
	body_col.shape.height = crouch_tween.interpolate_property(body_col.shape, "height", body_col.shape.height, amount, 0.1, Tween.TRANS_LINEAR)
