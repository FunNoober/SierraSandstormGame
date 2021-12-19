extends Spatial

var max_ammo = 15
var current_ammo = 15
var can_shoot = true
var is_reloading = false

onready var shoot_timer = get_node("ShootDelay")
onready var shoot_cast = get_node("ShootCast")

func _ready():
	current_ammo = max_ammo
	
func _physics_process(delta):
	if is_reloading == true:
		return
	
	if current_ammo <= 0:
		reload_weapon()
	
	if Input.is_action_pressed("action_shoot") and can_shoot == true:
		shoot()


func _on_ShootDelay_timeout():
	can_shoot = true

func shoot():
	can_shoot = false
	shoot_cast.enabled = true
	current_ammo -= 1
	print(current_ammo)
	if shoot_cast.is_colliding() == true:
		print(shoot_cast.get_collider())
	shoot_timer.start()

func reload_weapon():
	$ReloadDelay.start()
	is_reloading = true

func _on_ReloadDelay_timeout():
	current_ammo = max_ammo
	is_reloading = false
