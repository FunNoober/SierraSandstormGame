extends KinematicBody

export var mov_speed : float
export var look_speed : float

onready var player_pos = get_node("PlayerPos")
onready var vision_cast = get_node("VisionCast")
onready var nav = get_parent()

var can_shoot : bool
var seen_player : bool
var player : KinematicBody

var path = []
var cur_path_i = 0
var target = null
var vel = Vector3.ZERO

enum TYPE {defensive, offensive}
export(TYPE) var type = TYPE.defensive

func _process(delta: float) -> void:
	if player != null:
		$VisionCast.look_at(player.translation, Vector3.UP)
	if $VisionCast.is_colliding() && $VisionCast.get_collider().is_in_group("Player"):
		seen_player = true
		
	if seen_player:
		$PlayerPos.translation = lerp($PlayerPos.translation, player.translation, look_speed * delta)
		look_at($PlayerPos.translation, Vector3.UP)
		self.rotation_degrees.x = 0
	if seen_player: move_to_target()
		
func move_to_target():
	if cur_path_i < path.size():
		var dir = (path[cur_path_i] - global_transform.origin)
		if dir.length() < 1:
			cur_path_i += 1
		else:
			move_and_slide(dir.normalized() * mov_speed)
		
func get_target_path(target_pos):
	path = nav.get_simple_path(translation, target_pos)
	cur_path_i = 0

func _on_ShootTimer_timeout() -> void:
	pass # Replace with function body.

func _on_BroadVisionCheck_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body

func _on_PathResetTimer_timeout() -> void:
	if seen_player:
		get_target_path(player.global_transform.origin)
