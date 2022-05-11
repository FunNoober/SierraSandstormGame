extends Node

var shoot_cast
var player
var time : float
var cur_delta : float

func _process(delta: float) -> void:
	time += delta
	cur_delta = delta

func throw_ray(ray_range : float):
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

func create_tween(object, property, start, end, time : float, destroy_on_finish : bool, tween_node):
	add_child(tween_node)
	tween_node.interpolate_property(
		object,
		property,
		start,
		end,
		time
	)
	tween_node.start()
	yield(tween_node, "tween_completed")
	
	if destroy_on_finish == true:
		tween_node.queue_free()
