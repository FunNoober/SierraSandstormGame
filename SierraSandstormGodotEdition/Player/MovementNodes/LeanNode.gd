extends Node

func lean(is_leaning, lean_tween, lean_tween_rot, cam_hold):
	if Input.is_action_just_pressed("lean_left"):
		if is_leaning == false:
			lean_left(lean_tween, lean_tween_rot, cam_hold)
			is_leaning = true
			return is_leaning
		else:
			reset_lean(lean_tween, lean_tween_rot, cam_hold)
			is_leaning = false
			return is_leaning
	if Input.is_action_just_pressed("lean_right"):
		if is_leaning == false:
			lean_right(lean_tween, lean_tween_rot, cam_hold)
			is_leaning = true
			return is_leaning
		else:
			reset_lean(lean_tween, lean_tween_rot, cam_hold)
			is_leaning = false
			return is_leaning
	return is_leaning

func lean_left(lean_tween, lean_tween_rot, cam_hold):
	lean_camera(1, 7.5, lean_tween, lean_tween_rot, cam_hold)
	
func lean_right(lean_tween, lean_tween_rot, cam_hold):
	lean_camera(-1, -7.5, lean_tween, lean_tween_rot, cam_hold)
	
func reset_lean(lean_tween, lean_tween_rot, cam_hold):
	lean_camera(0, 0, lean_tween, lean_tween_rot, cam_hold)
	
func lean_camera(mv_amount, rot_amount, lean_tween, lean_tween_rot, cam_hold):
	lean_tween.interpolate_property(cam_hold, 
	"translation:x", 
	cam_hold.translation.x, 
	mv_amount, 
	0.1, 
	Tween.TRANS_LINEAR)
	lean_tween_rot.interpolate_property(cam_hold, 
	"rotation_degrees:z", 
	cam_hold.rotation_degrees.z, 
	rot_amount, 
	0.1, 
	Tween.TRANS_LINEAR)
	lean_tween.start()
	lean_tween_rot.start()
