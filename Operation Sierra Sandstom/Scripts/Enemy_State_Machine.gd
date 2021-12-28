extends KinematicBody

var enemy_in_vision : bool
var enemy_in_attack : bool

var player : KinematicBody
var nav

var path = []
var path_node = 0

export var speed = 10.0


func _ready():
	player = get_tree().get_root().get_node("Spatial").get_node("Navigation").get_node("FPSBody")
	nav = get_tree().get_root().get_node("Spatial").get_node("Navigation")
	
	enemy_in_attack = false
	enemy_in_vision = false

func _physics_process(delta):
	if path_node < path.size():
		var dir = (path[path_node] - global_transform.origin)
		if dir.length() < 1:
			path_node += 1
		else:
			move_and_slide(dir.normalized() * speed, Vector3.UP)

func _process(delta):	
	if enemy_in_vision == true:
		look_at(player.global_transform.origin, Vector3.UP)
	if enemy_in_attack == true:
		pass
	if enemy_in_attack == false and enemy_in_vision == false:
		pass

func patrol():
	pass

func chase(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0
	
	
func attack():
	pass

func _on_AttackRadius_body_entered(body):
	if body.is_in_group("Player"):
		enemy_in_attack = true


func _on_Vision_body_entered(body):
	if body.is_in_group("Player"):
		enemy_in_vision = true


func _on_AttackRadius_body_exited(body):
	enemy_in_attack = false


func _on_Vision_body_exited(body):
	enemy_in_vision = false


func _on_Timer_timeout():
	if enemy_in_vision == true:
		print(enemy_in_vision)
		chase(player.global_transform.origin)