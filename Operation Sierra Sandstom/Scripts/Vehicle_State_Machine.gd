extends KinematicBody

export var turret_base_path : NodePath
var turret_base
export var turret_gun_path : NodePath
var turret_gun
export var shoot_handler_path : NodePath
var shoot_handler

var first_sighted_enemy : KinematicBody
var enemy_sighted_broad_check = false
var enemy_sighted = false

func _ready():
	turret_base = get_node(turret_base_path)
	turret_gun = get_node(turret_gun_path)
	shoot_handler = get_node(shoot_handler_path)
	
func _process(delta):
	shoot_handler.enemy_sighted = enemy_sighted

func _physics_process(delta):
	if enemy_sighted_broad_check == true:
		$WallCheckCast.look_at(first_sighted_enemy.translation, Vector3.UP)
		if $WallCheckCast.is_colliding() == true and $WallCheckCast.get_collider().is_in_group("Friendly"):
			enemy_sighted = true
	
	if enemy_sighted == true:
		var true_global_z
		if get_global_z() < 0:
			true_global_z = get_global_z()
		else:
			true_global_z = -get_global_z()
		var z_target = true_global_z
		var z_diff = z_target - turret_gun.global_transform.basis.get_euler().z
		var final_z = sign(z_diff) * min(5 * delta, abs(z_diff))
		turret_gun.rotate_z(final_z)
		turret_gun.rotation_degrees.z = clamp(turret_gun.rotation_degrees.z, -30, 24)
		
		var y_target = get_local_y()
		var final_y = sign(y_target) * min(5 * delta, abs(y_target))
		turret_base.rotate_y(final_y)

func _on_VisionArea_body_entered(body):
	if body.is_in_group("Friendly"):
		first_sighted_enemy = body
		enemy_sighted_broad_check = true

func get_local_y():
	var local_target = turret_base.to_local(first_sighted_enemy.global_transform.origin)
	var y_angle = Vector3.FORWARD.angle_to(local_target * Vector3(1,0,1))
	return y_angle * -sign(local_target.x)

func get_global_z():
	var local_target = first_sighted_enemy.global_transform.origin - turret_gun.global_transform.origin
	return -(local_target * Vector3(1,0,1)).angle_to(local_target) * sign(local_target.x)
