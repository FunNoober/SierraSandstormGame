extends KinematicBody

onready var turret_base = get_node("Vehicle/TurretHolder")
onready var turret_gun = get_node("Vehicle/TurretHolder/Turret/GunHolder")

var player
var enemy_sighted = false

func _ready():
	pass # Replace with function body

func _physics_process(delta):
	if enemy_sighted == true:
		turret_base.rotation.y = lerp_angle(turret_base.rotation.y, atan2(turret_base.rotation.x, turret_base.rotation.y), delta * 5)

func _on_VisionArea_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		enemy_sighted = true
