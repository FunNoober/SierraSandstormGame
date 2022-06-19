extends KinematicBody

export var accuracy : float
export var damage : float

onready var player_pos = get_node("PlayerPos")
onready var turret_base_pivot = get_node("TurretBasePivot")
onready var turret_gun_pivot = get_node("TurretBasePivot/Turret/TurretGunPivot")

var player_in_vision_cone : bool = false
var player_seen : bool = false
var can_shoot : bool = true

var player : Spatial
	
func _process(delta):
	player_pos.translation = lerp(player_pos.translation, FpsApi.player.translation, delta * accuracy)
	if player_in_vision_cone == true:
		$VisionCast.look_at(player.translation, Vector3.UP)
	if $VisionCast.is_colliding():
		if $VisionCast.get_collider().is_in_group("Player"):
			player_seen = true
	if player_seen:
		turret_base_pivot.look_at(player_pos.translation, Vector3.UP)
		turret_gun_pivot.look_at(player_pos.translation, Vector3.UP)

		turret_base_pivot.rotation_degrees.x = 0
		turret_base_pivot.rotation_degrees.z = 0
		
		turret_gun_pivot.rotation_degrees.z = 0
		
		if can_shoot:
			shoot()
			$ShootTimer.start()
	
func shoot():
	var shoot_cast_collider : Node
	if $TurretBasePivot/Turret/TurretGunPivot/TurretGun/ShootCast.is_colliding():
		shoot_cast_collider = $TurretBasePivot/Turret/TurretGunPivot/TurretGun/ShootCast.get_collider()
		if shoot_cast_collider.is_in_group("Player"):
			shoot_cast_collider.take_damage(damage)
	can_shoot = false

func _on_ShootTimer_timeout() -> void:
	can_shoot = true

func _on_VisionCone_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player_in_vision_cone = true
		player = body
