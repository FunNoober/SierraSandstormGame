class_name Firearm
extends Spatial

export var weapon_name : String = ""

onready var stats = get_node("WeaponStats")
var can_shoot : bool = true
var is_reloading : bool = false
var position_before_shot : Vector3
var aim_pos : Vector3
var pos_before_shot : Vector3 
var current_ammo : int

var data_to_store = {
	"reserve_ammo" : 90,
	"mag_size" : 30,
	"reload_time" : 2.083,
	"fire_rate" : 0.1
}

func _ready() -> void:
	can_shoot = true
	current_ammo = stats.mag_size
	
	var d = Directory.new()
	if d.file_exists("user://" + weapon_name + ".weapon"):
		var f = File.new()
		f.open("user://" + weapon_name + ".weapon", f.READ)
		var contents_as_string = f.get_as_text()
		var contents_as_dictionary = parse_json(contents_as_string)
		data_to_store = contents_as_dictionary
		stats.reserve_ammo = data_to_store.reserve_ammo
		stats.mag_size = data_to_store.mag_size
		stats.reload_time = data_to_store.reload_time
		stats.fire_rate = data_to_store.fire_rate
		f.close()
	else:
		var f = File.new()
		f.open("user://" + weapon_name + ".weapon", f.WRITE)
		f.store_string(JSON.print(data_to_store))
		f.close()
	
func _process(delta: float) -> void:
	$HUD/Container/HBoxContainer/AmmoCounter.text = str(stats.reserve_ammo) + "/" + str(current_ammo)
	translation = lerp(translation, pos_before_shot, delta * 5)
	if Input.is_action_pressed("shoot") and can_shoot == true and is_reloading == false and current_ammo > 0:
		shoot()
	if can_reload() == true and current_ammo <= 0 and is_reloading == false:
		reload()

func shoot():
	var col = FpsApi.throw_ray(stats.fire_range)
	if col != null and col.is_in_group("Enemy"):
		col.take_damage(stats.damage)
	can_shoot = false
	$ShootTimer.start(stats.fire_rate)
	current_ammo -= 1
	translation.z -= stats.recoil

func _on_ShootTimer_timeout() -> void:
	can_shoot = true

func can_reload():
	if stats.reserve_ammo >= stats.mag_size:
		return true
	else:
		return false

func reload():
	is_reloading = true
	$ReloadTimer.start(stats.reload_time)
	$Visuals/WeaponModel/AnimationPlayer.play("Reloadanimation")

func _on_ReloadTimer_timeout() -> void:
	is_reloading = false
	stats.reserve_ammo -= stats.mag_size
	current_ammo = stats.mag_size
