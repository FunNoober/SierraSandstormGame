extends Spatial

onready var stats = get_node("WeaponStats")
var current_fire_time = 0
var current_muzzle_time = 0

var current_ammo

func _ready() -> void:
	current_ammo = stats.mag_size

func _process(delta):
	current_fire_time = FpsApi.countdown(current_fire_time, delta)	
	current_muzzle_time = FpsApi.countdown(current_muzzle_time, delta)
	if current_muzzle_time <= 0:
		$VFX/MuzzleFlash.hide()
	
	if FpsApi.is_pressed_hold("shoot") and current_fire_time <= 0:
		current_ammo -= 1
		print(current_ammo)
		current_fire_time = stats.fire_rate
		$VFX/MuzzleFlash.show()
		current_fire_time = 0.25
		FpsApi.shoot(stats.fire_range, stats.accuracy)
