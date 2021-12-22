extends Spatial

export var max_ammo = 15
export var current_ammo = 15

export var shoot_delay = 0.05
export var reload_delay = 5.0

export var recoil = 1.0

var can_shoot = true
var is_reloading = false

var ammo_counter
var aim_cast_position

onready var shoot_timer = get_node("ShootDelay")
onready var shoot_cast = get_node("ShootCast")

onready var bullet_hole = load("res://Prefabs/Bullet_Hole.tscn")

func _ready():
	current_ammo = max_ammo
	ammo_counter = get_node("../../../../Graphical_User_Interface")
	aim_cast_position = get_parent().translation
	shoot_cast.translation = aim_cast_position
	
	shoot_timer.wait_time = shoot_delay
	$ReloadDelay.wait_time = reload_delay
	
func _physics_process(delta):
	current_ammo = clamp(current_ammo, 0, max_ammo)
	
	
	if is_reloading == true:
		ammo_counter.ammo_counter.text = str("RELOADING...")
		return
	
	if current_ammo <= 0:
		reload_weapon()
	
	if Input.is_action_pressed("action_shoot") and can_shoot == true:
		shoot()

func _on_ShootDelay_timeout():
	can_shoot = true

func shoot():
	if ammo_counter != null:
		ammo_counter.ammo_counter.text = str(str(current_ammo) + "/" + str(max_ammo))
	can_shoot = false
	shoot_cast.enabled = true
	current_ammo -= 1
	shoot_cast.rotation.y = rand_range(-recoil, recoil)
	shoot_cast.rotation.z = rand_range(-recoil, recoil)
	if shoot_cast.is_colliding() == true:
		spawn_bullet_hole()
	shoot_timer.start()

func reload_weapon():
	$ReloadDelay.start()
	is_reloading = true

func _on_ReloadDelay_timeout():
	current_ammo = max_ammo
	is_reloading = false
	if ammo_counter != null:
		ammo_counter.ammo_counter.text = str(str(current_ammo) + "/" + str(max_ammo))
		
func spawn_bullet_hole():
	var new_bullet_hole = bullet_hole.instance()
	get_tree().get_root().add_child(new_bullet_hole)
	new_bullet_hole.translation = shoot_cast.get_collision_point()
	
	var surface_dir_up = Vector3(0,1,0)
	var surface_dir_down = Vector3(0,-1,0)
	
	if shoot_cast.get_collision_normal() == surface_dir_up:
		new_bullet_hole.look_at(shoot_cast.get_collision_point() + shoot_cast.get_collision_normal(), Vector3.RIGHT)
	elif shoot_cast.get_collision_normal() == surface_dir_down:
		new_bullet_hole.look_at(shoot_cast.get_collision_point() + shoot_cast.get_collision_normal(), Vector3.RIGHT)
	else:
		new_bullet_hole.look_at(shoot_cast.get_collision_point() + shoot_cast.get_collision_normal(), Vector3.DOWN)
