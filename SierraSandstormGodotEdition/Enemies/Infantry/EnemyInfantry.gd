extends KinematicBody

export var mov_speed : float = 10
export var look_speed : float = 5
export var damage : float = 10

onready var player_pos = get_node("PlayerPos")
onready var vision_cast = get_node("VisionCast")
onready var nav = get_parent()

var can_shoot : bool
var seen_player : bool
var should_pathfind : bool
var is_currently_pathfinding : bool
var health : int = 100
var player : KinematicBody

var path = []
var cur_path_i = 0
var target = null
var vel = Vector3.ZERO

enum TYPE {defensive, offensive}
export(TYPE) var type = TYPE.defensive

func _ready() -> void:
	can_shoot = true
	health = 100

func _process(delta: float) -> void:
	if should_pathfind and is_currently_pathfinding == false:
		$PathResetTimer.start()
		is_currently_pathfinding = true
	if player != null:
		$VisionCast.look_at(player.translation, Vector3.UP)
	if $VisionCast.is_colliding() && $VisionCast.get_collider().is_in_group("Player"):
		seen_player = true
		
	if seen_player:
		$PlayerPos.translation = lerp($PlayerPos.translation, player.global_transform.origin, look_speed * delta)
		var player_center = Vector3($PlayerPos.translation.x, $PlayerPos.translation.y + 1.5, $PlayerPos.translation.z)
		look_at($PlayerPos.translation, Vector3.UP)
		$Weapon.look_at(player_center, Vector3.UP)
		self.rotation_degrees.x = 0
		if can_shoot == true:
			shoot()
		
		if type == TYPE.offensive:
			move_to_target()
		if global_transform.origin.distance_to(player.global_transform.origin) < 15:
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
	path = nav.get_simple_path(translation, target_pos)
	cur_path_i = 0
	is_currently_pathfinding = false
	
func shoot():
	if $Weapon/ShootCast.is_colliding() and $Weapon/ShootCast.get_collider().is_in_group("Player"):
		$Weapon/ShootCast.get_collider().take_damage(damage)
	$Weapon/ShootParticles.emitting = true
	can_shoot = false
	$ShootTimer.start()

func _on_ShootTimer_timeout() -> void:
	can_shoot = true

func _on_BroadVisionCheck_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body

func _on_PathResetTimer_timeout() -> void:
	if seen_player:
		get_target_path(player.global_transform.origin)

func take_damage(amount):
	health -= amount
	print("ouch")
	if health <= 0:
		die()

func die():
	queue_free()
	#TODO: add falling animation or ragdolling
