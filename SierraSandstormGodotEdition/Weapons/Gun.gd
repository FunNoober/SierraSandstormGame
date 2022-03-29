extends Spatial

onready var stats = get_node("WeaponStats")
var current_fire_time = 0
var current_muzzle_time = 0

var current_ammo

func _process(delta):
	if current_fire_time > 0:
		current_fire_time -= delta
		
	if current_muzzle_time > 0:
		current_fire_time -= delta
	if current_muzzle_time <= 0:
		$VFX/MuzzleFlash.hide()
	
	if Input.is_action_pressed("shoot") and current_fire_time <= 0:
		current_fire_time = stats.fire_rate
		$VFX/MuzzleFlash.show()
		current_fire_time = 0.25
		FpsApi.shoot(stats.fire_range, stats.accuracy)
