extends Spatial

export var reserve_ammo : int = 30
export var current_ammo : int = 30
export var mag_size : int = 30

export var shoot_delay : float = 1.0
export var reload_time : float = 2.0
var shoot_timer_time : float
var reload_timer_time : float

var is_reloading : bool
var ready_to_shoot : bool = true

var gui
var ammo_text
var prime_cam

onready var shoot_cast : RayCast = $ShootCast

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
	ammo_text = gui.get_node("AmmoCounter")
	prime_cam = get_parent().get_parent().get_parent()
	current_ammo = mag_size
	
	shoot_cast.translation = prime_cam.translation
	
	shoot_timer_time = shoot_delay
	reload_timer_time = reload_time
	print(can_reload())
	
func _process(delta):
	shoot_cast.translation = prime_cam.translation
	
	if is_reloading == false:
		ammo_text.text = str(str(current_ammo) + "/" + str(reserve_ammo))
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
	current_ammo -= 1
	if shoot_cast.is_colliding():
		pass

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
	
