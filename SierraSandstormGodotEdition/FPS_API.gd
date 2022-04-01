extends Node

var shoot_cast
var player

func shoot(ray_range : float, ray_accuracy : Vector2):
	var shoot_cast_collider
	shoot_cast.rotation_degrees = weapon_accuracy(shoot_cast, ray_accuracy)
	if shoot_cast.is_colliding():
		shoot_cast_collider = shoot_cast.get_collider()
		print(shoot_cast_collider)
		
func weapon_accuracy(ray_cast : RayCast, ray_accuracy : Vector2):
	var rng = RandomNumberGenerator.new()
	ray_cast.rotation_degrees.x = rand_range(-ray_accuracy.x, ray_accuracy.x)
	ray_cast.rotation_degrees.y = rand_range(-ray_accuracy.y, ray_accuracy.y)
	return ray_cast.rotation_degrees

func is_pressed_hold(input):
	if Input.is_action_pressed(input):
		return true
	else:
		return false

func countdown(value, delta):
	if value > 0:
		value -= delta
	return value
