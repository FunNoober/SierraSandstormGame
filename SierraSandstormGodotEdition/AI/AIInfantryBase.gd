extends KinematicBody

export var group_mask = "Player"

export var mov_speed : float = 10
export var look_speed : float = 5
export var damage : float = 10

onready var enemy_pos = get_node("EnemyPos")
onready var vision_cast = get_node("VisionCast")
onready var nav = get_parent()

var can_shoot : bool
var seen_enemy : bool
var should_pathfind : bool
var is_currently_pathfinding : bool
var health : int = 100
var enemy : KinematicBody

var path = []
var cur_path_i = 0
var target = null
var vel = Vector3.ZERO

enum TYPE {defensive, offensive}
export(TYPE) var type = TYPE.defensive

var targets = []

func _ready() -> void:
	can_shoot = true
	health = 100

func _process(delta: float) -> void:
	if targets.size() > 0:
		enemy = targets[targets.size() - 1]
	if should_pathfind and is_currently_pathfinding == false:
		$PathResetTimer.start()
		is_currently_pathfinding = true
	if enemy != null and is_instance_valid(enemy):
		$VisionCast.look_at(enemy.translation, Vector3.UP)
	if $VisionCast.is_colliding() && $VisionCast.get_collider().name.find(group_mask) != -1:
		seen_enemy = true
		
	if seen_enemy and enemy != null and is_instance_valid(enemy):
		$EnemyPos.translation = lerp($EnemyPos.translation, enemy.global_transform.origin, look_speed * delta)
		var player_center = Vector3($EnemyPos.translation.x, $EnemyPos.translation.y + 1.5, $EnemyPos.translation.z)
		look_at($EnemyPos.translation, Vector3.UP)
		$Weapon.look_at(player_center, Vector3.UP)
		self.rotation_degrees.x = 0
		if can_shoot == true:
			shoot()
		
		if type == TYPE.offensive:
			move_to_target()
		if global_transform.origin.distance_to(enemy.global_transform.origin) < 15:
			should_pathfind = false
			path = []
			
		else:
			should_pathfind = true
			
		
func move_to_target():
	if cur_path_i < path.size():
		var dir = (path[cur_path_i] - global_transform.origin)
		if dir.length() < 1:
			cur_path_i += 1
		else:
			move_and_slide(dir.normalized() * mov_speed, Vector3.UP)
		
func get_target_path(target_pos):
	var new_pos = target_pos
	new_pos.x = target_pos.x + rand_range(-2, 2)
	new_pos.z = target_pos.z + rand_range(-2, 2)
	path = nav.get_simple_path(translation, new_pos)
	cur_path_i = 0
	is_currently_pathfinding = false
	
func shoot():
	if $Weapon/ShootCast.is_colliding() and $Weapon/ShootCast.get_collider().name.find(group_mask) != -1:
		$Weapon/ShootCast.get_collider().take_damage(damage)
		if $Weapon/ShootCast.get_collider().health - damage <= 0:
			targets.pop_back()
	$Weapon/ShootParticles.emitting = true
	can_shoot = false
	$ShootTimer.start()

func _on_ShootTimer_timeout() -> void:
	can_shoot = true

func _on_BroadVisionCheck_body_entered(body: Node) -> void:
	if body.name.find(group_mask) != -1:
		targets.append(body)

func _on_PathResetTimer_timeout() -> void:
	if seen_enemy and is_instance_valid(enemy):
		get_target_path(enemy.global_transform.origin)

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()
	#TODO: add falling animation or ragdolling
