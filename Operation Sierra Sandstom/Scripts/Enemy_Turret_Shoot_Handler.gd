extends Spatial

var can_shoot : bool = true
onready var shoot_cast = get_node("ShootCast")
onready var muzzle_flash = get_node("MuzzleFlash")
export var damage : float = 75
var enemy_sighted : bool

func _process(delta):
	if enemy_sighted == true and can_shoot == true:
		shoot()

func shoot():
	muzzle_flash.show()
	if shoot_cast.is_colliding() == true:
		if shoot_cast.get_collider().is_in_group("Friendly"):
			shoot_cast.get_collider().take_damage(damage)
	can_shoot = false
	$ShootTimer.start()
	$MuzzleFlash/MuzzleTimer.start()

func _on_ShootTimer_timeout():
	can_shoot = true


func _on_MuzzleTimer_timeout():
	muzzle_flash.hide()
