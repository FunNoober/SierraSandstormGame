extends KinematicBody

onready var player_pos = get_node("PlayerPos")
onready var turret_base_pivot = get_node("TurretBasePivot")
onready var turret_gun_pivot = get_node("TurretBasePivot/Turret/TurretGunPivot")

export var accuracy : float

var has_seen_player

func _ready() -> void:
	for child in $VisionCasts.get_children():
		child.connect("visible", self, "seen_player")
	
func _process(delta):
	if has_seen_player:
		player_pos.translation = lerp(player_pos.translation, FpsApi.player.translation, delta * accuracy)
		
		turret_base_pivot.look_at(player_pos.translation, Vector3.UP)
		turret_gun_pivot.look_at(player_pos.translation, Vector3.UP)

		turret_base_pivot.rotation_degrees.x = clamp(turret_base_pivot.rotation_degrees.x, 0,0)
		turret_base_pivot.rotation_degrees.z = clamp(turret_base_pivot.rotation_degrees.z, 0,0)
		
		turret_gun_pivot.rotation_degrees.z = clamp(turret_gun_pivot.rotation_degrees.z, 0,0)

func seen_player():
	has_seen_player = true
