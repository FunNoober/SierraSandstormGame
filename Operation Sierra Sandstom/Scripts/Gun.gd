extends Spatial

export var reserve_ammo : int = 30
export var current_ammo : int = 30
export var mag_size : int = 30

export var shoot_delay : float = 1.0
export var reload_time : float = 2.0
export var damage : float

var currect_accuracy = Vector2()
export var weapon_accuracy = Vector2(0.0, 0.0)
export var ads_weapon_accuracy = Vector2(0.0, 0.0)

var current_shake = Vector2()
export var shake = Vector2(0,0)
export var ads_shake = Vector2(0,0)
var shoot_timer_time : float
var reload_timer_time : float

var is_reloading : bool
var ready_to_shoot : bool = true

var gui
var ammo_text
var weapon_text
var prime_cam

onready var bullet_hole = load("res://Prefabs/Bullet_Hole.tscn")

onready var shoot_cast : RayCast = $ShootCast

export var weapon_name : String

func can_reload():
	return reserve_ammo > 0
	
func current_ammo_depleted():
	return current_ammo <= 0
	
func reserve_ammo_depleted():
	return reserve_ammo <= 0
	
	
func no_more_ammo():
	if reserve_ammo_depleted() and current_ammo_depleted():
		return true
	else:
		return false
		
func _ready():
	gui = get_parent().get_parent().get_parent().get_parent().get_node("Graphical_User_Interface")
	ammo_text = gui.get_node("HBoxContainer/AmmoCounter")
	weapon_text = gui.get_node("HBoxContainer/WeaponText")
	prime_cam = get_parent().get_parent().get_parent()
	current_ammo = mag_size
	
	shoot_cast.translation = prime_cam.translation
	
	shoot_timer_time = shoot_delay
	reload_timer_time = reload_time
	print(can_reload())
	
func _process(delta):
	weapon_text.text = "Weapon: " + weapon_name
	shoot_cast.translation = prime_cam.translation
	
	if Input.is_action_pressed("action_ads"):
		prime_cam.fov = lerp(prime_cam.fov, 45, delta * 10)
		currect_accuracy = ads_weapon_accuracy
		current_shake = ads_shake
	else:
		currect_accuracy = weapon_accuracy
		current_shake = ads_shake
		prime_cam.fov = lerp(prime_cam.fov, 90, delta * 10)
	
	if is_reloading == false:
		ammo_text.text = "Ammo: " + str(str(current_ammo) + "/" + str(reserve_ammo))
	elif is_reloading == true:
		ammo_text.text = str("RELOADING...")
		reset_reload(delta)
		return
		
	if current_ammo_depleted() == true and can_reload() == true:
		reload_weapon()
		
	if Input.is_action_pressed("action_shoot") and no_more_ammo() == false and ready_to_shoot == true and is_reloading == false:
		shoot()
		
	if ready_to_shoot == false:
		reset_shoot(delta)
		
		
func shoot():
	ready_to_shoot = false
	$MuzzleFlash.show()
	$MuzzleTimer.start(0.1)
	get_parent().get_parent().get_parent().get_parent().shake(current_shake.x, current_shake.y)
	current_ammo -= 1
	shoot_cast.rotation.z = rand_range(-currect_accuracy.x, currect_accuracy.x)
	shoot_cast.rotation.y = rand_range(-currect_accuracy.y, currect_accuracy.y)
	if shoot_cast.is_colliding():
		spawn_bullet_hole()
		if shoot_cast.get_collider().is_in_group("Enemy"):
			shoot_cast.get_collider().take_damage(damage)

func reset_shoot(delta):
	shoot_timer_time -= delta
	if shoot_timer_time <= 0:
		ready_to_shoot = true
		shoot_timer_time = shoot_delay
		
func reset_reload(delta):
	reload_timer_time -= delta
	if reload_timer_time <= 0:
		current_ammo = mag_size
		reserve_ammo -= mag_size
		is_reloading = false
		reload_timer_time = reload_time
		
func reload_weapon():
	is_reloading = true
	
func spawn_bullet_hole():
	var new_bullet_hole = bullet_hole.instance()
	shoot_cast.get_collider().add_child(new_bullet_hole)
	new_bullet_hole.translation = shoot_cast.get_collision_point()
	
	var surface_dir_up = Vector3(0,1,0)
	var surface_dir_down = Vector3(0,-1,0)
	
	if shoot_cast.get_collision_normal() == surface_dir_up:
		new_bullet_hole.look_at(shoot_cast.get_collision_point() + shoot_cast.get_collision_normal(), Vector3.RIGHT)
	elif shoot_cast.get_collision_normal() == surface_dir_down:
		new_bullet_hole.look_at(shoot_cast.get_collision_point() + shoot_cast.get_collision_normal(), Vector3.RIGHT)
	else:
		new_bullet_hole.look_at(shoot_cast.get_collision_point() + shoot_cast.get_collision_normal(), Vector3.DOWN)


func _on_MuzzleTimer_timeout():
	$MuzzleFlash.hide()
