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
		hands.translation = lerp(hands.translation, aim_pos.translation, delta * 3)

	else:
		hands.translation = lerp(hands.translation, starndard_hands_pos.translation, delta * 3)
