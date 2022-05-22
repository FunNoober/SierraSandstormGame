extends Node

func jump(floor_cast, vel, jump_force):
	if floor_cast.is_colliding():
		if Input.is_action_just_pressed("mv_jump"):
			if Cheats.cheats.super_jump == false:
				vel.y = jump_force
			else:
				vel.y = 20
	return vel.y

func move(floor_cast, input_mv_vec):
	if floor_cast.is_colliding():
		if Input.is_action_pressed("mv_forward") or Input.is_action_pressed("mv_back"):
			input_mv_vec.y += Input.get_axis("mv_back", "mv_forward")
		if Input.is_action_pressed("mv_right") or Input.is_action_pressed("mv_left"):
			input_mv_vec.x +=  Input.get_axis("mv_left", "mv_right")
	return input_mv_vec
