extends Node

var shoot_cast
var player

func shoot(ray_range : float):
	var shoot_cast_collider
	if shoot_cast.is_colliding():
		shoot_cast_collider = shoot_cast.get_collider()
		print(shoot_cast_collider)

func is_pressed_hold(input):
	if Input.is_action_pressed(input):
		return true
	else:
		return false

func countdown(value, delta):
	if value > 0:
		value -= delta
	return value
