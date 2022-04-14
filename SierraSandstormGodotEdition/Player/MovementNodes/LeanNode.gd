extends Node

func lean_left(lean_tween, lean_tween_rot, cam_hold):
	lean_camera(1, 7.5, lean_tween, lean_tween_rot, cam_hold)
	
func lean_right(lean_tween, lean_tween_rot, cam_hold):
	lean_camera(-1, -7.5, lean_tween, lean_tween_rot, cam_hold)
	
func reset_lean(lean_tween, lean_tween_rot, cam_hold):
	lean_camera(0, 0, lean_tween, lean_tween_rot, cam_hold)
	
func lean_camera(mv_amount, rot_amount, lean_tween, lean_tween_rot, cam_hold):
	#Moving The Camera When Leaning
	lean_tween.interpolate_property(cam_hold, 
	"translation:x", 
	cam_hold.translation.x, 
	mv_amount, 
	0.1, 
	Tween.TRANS_LINEAR)
	#End
	
	#Rotation The Camera When Leaning
	lean_tween_rot.interpolate_property(cam_hold, 
	"rotation_degrees:z", 
	cam_hold.rotation_degrees.z, 
	rot_amount, 
	0.1, 
	Tween.TRANS_LINEAR)
	#End
	
	#Starting the tweens
	lean_tween.start()
	lean_tween_rot.start()
	#End
