extends Spatial

onready var stats = get_node("WeaponStats")
var current_fire_time = 0
var current_muzzle_time = 0

var current_ammo
var can_shoot = true

func _ready() -> void:
	current_ammo = stats.mag_size

func _process(delta):
	$HUD/Container/HBoxContainer/AmmoCounter.text = str(stats.reserve_ammo) + "/" + str(current_ammo)
	
	if not can_shoot:
		return
	
	if current_ammo <= 0:
		can_shoot = false
		if can_reload():
			$ReloadTimer.wait_time = stats.reload_time
			$ReloadTimer.start()

	current_fire_time = FpsApi.countdown(current_fire_time, delta)	
	current_muzzle_time = FpsApi.countdown(current_muzzle_time, delta)
	if current_muzzle_time <= 0:
		$VFX/MuzzleFlash.hide()
	
	if FpsApi.is_pressed_hold("shoot") and current_fire_time <= 0 and can_shoot:
		current_ammo -= 1
		current_fire_time = stats.fire_rate
		$VFX/MuzzleFlash.show()
		$AnimationPlayer.play("recoil")
		current_fire_time = 0.25
		FpsApi.shoot(stats.fire_range)
#	else:
#		$AnimationPlayer.play("RESET")

func reload():
	stats.reserve_ammo -= stats.mag_size
	current_ammo = stats.mag_size
	can_shoot = true

func can_reload():
	if stats.reserve_ammo <= 0:
		return false
	else:
		return true
