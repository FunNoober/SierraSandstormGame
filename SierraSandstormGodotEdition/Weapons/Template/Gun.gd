extends Spatial

onready var stats = get_node("WeaponStats")
export var weapon_name : String
export var moddable : bool
var current_fire_time = 0
var current_muzzle_time = 0

var current_ammo
var can_shoot = true

func _ready() -> void:
	$ReloadTimer.connect("timeout", self, 'reload')
	var stats_dic = {
		'starting_ammo' : stats.reserve_ammo,
		'mag_size' : stats.mag_size,
		'reload_time' : stats.reload_time,
		'fire_rate' : stats.fire_rate
	}
	
	current_ammo = stats.mag_size
	var dir = Directory.new()
	if moddable == true:
		if dir.file_exists("user://" + weapon_name + ".json"):
			var f = File.new()
			f.open("user://" + weapon_name + ".json", File.READ)
			var c_a_t = f.get_as_text()
			var c_a_d = parse_json(c_a_t)
			stats_dic = c_a_d
			stats.reserve_ammo = stats_dic.starting_ammo
			stats.mag_size = stats_dic.mag_size
			stats.reload_time = stats.reload_time
			stats.fire_rate = stats.fire_rate
		else:
			var f = File.new()
			f.open("user://" + weapon_name + ".json", File.WRITE)
			f.store_string(JSON.print(stats_dic))
			f.close()

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
		$Visuals/MuzzleFlash.hide()
	
	if FpsApi.is_pressed_hold("shoot") and current_fire_time <= 0 and can_shoot:
		current_ammo -= 1
		current_fire_time = stats.fire_rate
		$Visuals/MuzzleFlash.show()
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
