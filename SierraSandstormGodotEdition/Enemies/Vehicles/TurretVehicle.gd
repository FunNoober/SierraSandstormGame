extends KinematicBody

export var map_name : String
export var accuracy : float
export var damage : float

onready var player_pos = get_node("PlayerPos")
onready var turret_base_pivot = get_node("TurretBasePivot")
onready var turret_gun_pivot = get_node("TurretBasePivot/Turret/TurretGunPivot")
onready var player = get_tree().get_root().get_node(map_name).get_node("Player")

var has_seen_player : bool
var can_shoot : bool = true

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
		
		if can_shoot:
			shoot()
			$ShootTimer.start()

func seen_player():
	has_seen_player = true
	
func shoot():
	var shoot_cast_collider : Node
	if $TurretBasePivot/Turret/TurretGunPivot/TurretGun/ShootCast.is_colliding():
		shoot_cast_collider = $TurretBasePivot/Turret/TurretGunPivot/TurretGun/ShootCast.get_collider()
		if shoot_cast_collider.is_in_group("Player"):
			shoot_cast_collider.take_damage(damage)
	can_shoot = false


func _on_ShootTimer_timeout() -> void:
	can_shoot = true
