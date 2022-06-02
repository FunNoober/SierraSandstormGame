extends Node

var is_aiming : bool

var starndard_hands_pos
var aim_pos
var hands

func _ready() -> void:
	starndard_hands_pos = get_node("../CameraHolder/Camera/HandsPosNormal")
	aim_pos = get_node("../CameraHolder/Camera/AimPosition")
	hands = get_node("../CameraHolder/Camera/Hands")

func _process(delta: float) -> void:
	if is_aiming == true:
		hands.translation.z = lerp(hands.translation.z, aim_pos.translation.z, delta * 3)
	else:
		hands.translation.z = lerp(hands.translation.z, starndard_hands_pos.translation.z, delta * 3)
