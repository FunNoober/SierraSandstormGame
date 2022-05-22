class_name Firearm
extends Spatial

onready var stats = get_node("WeaponStats")
export var weapon_name : String
export var moddable : bool

var current_ammo
var can_shoot = true

signal shot(recoil_amount, return_time, accuracy, accuracy_ads)

func _ready() -> void:
	$ReloadTimer.connect("timeout", self, 'reload')
	
	current_ammo = stats.mag_size
	var dir = Directory.new()
	if moddable == true:
		if dir.file_exists("user://" + weapon_name + ".json"):
			var f = File.new()
			f.open("user://" + weapon_name + ".json", File.READ)
			var contents_as_text = f.get_as_text()
			var contents_as_dictionary = parse_json(contents_as_text)
			stats.reserve_ammo = contents_as_dictionary.reserve_ammo
			stats.mag_size = contents_as_dictionary.mag_size
			stats.reload_time = contents_as_dictionary.reload_time
			stats.fire_rate = contents_as_dictionary.fire_rate
			stats.recoil = contents_as_dictionary.recoil
			f.close()
			
		else:
			var f = File.new()
			f.open("user://" + weapon_name + ".json", File.WRITE)
			var dic = {
				'reserve_ammo' : stats.reserve_ammo,
				'mag_size' : stats.mag_size,
				'reload_time' : stats.reload_time,
				'fire_rate' : stats.fire_rate,
				'recoil' : stats.recoil
			}
			f.store_string(JSON.print(dic))
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
			$Visuals/WeaponModel/AnimationPlayer.play("Reloadanimation")
	
	if Input.is_action_pressed("shoot") and can_shoot:
		if Cheats.cheats.infinite_ammo == false:
			current_ammo -= 1
		$ShootTimer.start(stats.fire_rate)
		$Visuals/MuzzleFlash.show()
		$MuzzleFlashTimer.start()
		$MuzzleParticles.emitting = true
		$AudioStreamPlayer.playing = true
		
		
		can_shoot = false
		var coll = FpsApi.throw_ray(stats.fire_range)
		if coll != null and coll.is_in_group("Enemy"):
			coll.take_damage(stats.damage)
		emit_signal("shot", stats.recoil, stats.return_time, stats.accuracy_normal, stats.accuracy_ads)

		

func reload():
	stats.reserve_ammo -= stats.mag_size
	current_ammo = stats.mag_size
	can_shoot = true

func can_reload():
	if stats.reserve_ammo <= 0:
		return false
	else:
		return true
		
func _on_ShootTimer_timeout() -> void:
	can_shoot = true

func _on_MuzzleFlashTimer_timeout() -> void:
	$Visuals/MuzzleFlash.hide()
