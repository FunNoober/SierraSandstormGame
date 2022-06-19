extends KinematicBody

export var max_jump_speed = 3
export var crouch_jump_speed = 2
export var max_speed = 5
export var crouch_speed = 3.0
export (Array, PackedScene) var loadout
export var sway_amplitude : float = 0.01
export var sway_frequency : float = 0.01

onready var cam : Node = get_node("CameraHolder/Camera")
onready var cam_hold : Node = get_node("CameraHolder")
onready var lean_tween : Node = get_node("LeanTween")
onready var lean_tween_rot : Node = get_node("LeanTweenRot")
onready var hands = get_node("CameraHolder/Camera/Hands")
onready var shoot_cast = get_node("CameraHolder/ShootCast")
onready var original_hand_pos = hands.global_transform.origin

const ACCEL = 20
const DEACCEL = 10
const MAX_SLOPE_ANGLE = 40
const GRAVITY = -9

var MOUSE_SENSITIVITY : float = 1.0 
var health : int = 100
var is_crouched : bool
var is_leaning : bool
var flash_enabled : bool
var is_aiming : bool
var dir = Vector3()
var vel = Vector3()
var cam_rot
var current_speed
var jump_speed


signal player_spawned(player)
signal hurt

func _ready():
	current_speed = max_speed
	cam_rot = cam_hold.rotation_degrees
	cam_rot.x = clamp(cam_rot.x, -70, 70)
	cam_rot.y = 180
	cam_hold.rotation_degrees = cam_rot
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	health = 100.0
	FpsApi.shoot_cast = shoot_cast
	print(FpsApi.shoot_cast)
	FpsApi.player = self
	
	emit_signal("player_spawned", self)
	for i in len(loadout):
		var v = loadout[i].instance()
		hands.add_child(v)
		v.translation = hands.translation
		v.set_process(false)
		v.hide()
		$CameraHolder/Camera/Hands.switch_weapon()
		
	
func _process(delta):
	if Input.is_action_just_pressed("flash_light"):
		flash_enabled = $FlashLight.flash_light(flash_enabled, $CameraHolder/FlashLight)
	$CameraHolder/FlashLight.global_transform.origin = $CameraHolder/Camera/Hands.get_child($CameraHolder/Camera/Hands.cur_i -1).get_node("LightPosition").global_transform.origin
	
	if health <= 0:
		get_tree().reload_current_scene()
	if Cheats.cheats.fast_mode == true:
		max_speed = 35
		crouch_speed = 35
		
	$AimNode.is_aiming = is_aiming
	FpsApi.is_aiming = is_aiming
	if Input.is_action_just_pressed("ads"):
		is_aiming = not is_aiming

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	
	var movement = cos(FpsApi.time+sway_frequency)*sway_amplitude
	hands.translation.y = FpsApi.move_on_sine(hands.translation.y, movement, -0.934)
	$CameraHolder/Camera/AimPosition.translation.y = FpsApi.move_on_sine($CameraHolder/Camera/AimPosition.translation.y, movement, -0.678)
	$CameraHolder/Camera/HandsPosNormal.translation.y = FpsApi.move_on_sine($CameraHolder/Camera/HandsPosNormal.translation.y, movement, -0.934)
	if is_aiming == false:
		hands.translation.x = FpsApi.move_on_sine(hands.translation.y, movement, 0.739)
	else:
		hands.translation.x = FpsApi.move_on_sine(hands.translation.y, movement, 0)
		hands.translation.y = $CameraHolder/Camera/AimPosition.translation.y

func process_input(delta):
	if is_crouched or is_leaning or is_aiming:
		current_speed = crouch_speed
		jump_speed = crouch_jump_speed
	else:
		current_speed = max_speed
		jump_speed = max_jump_speed
		
	if is_leaning:
		MOUSE_SENSITIVITY = 0.5
	else:
		MOUSE_SENSITIVITY = 1
	
	dir = Vector3()
	var cam_xform = cam.get_global_transform()
	
	var input_mv_vec = Vector2()
	
	input_mv_vec = $FloorCheckNode.move($FloorCast, input_mv_vec)			
	is_crouched = $CrouchNode.crouch(is_crouched, $BodyCollision, $CrouchTween)
	is_leaning = $LeanNode.lean(is_leaning, $LeanTween, $LeanTweenRot, $CameraHolder)
		
	input_mv_vec = input_mv_vec.normalized()
	
	dir += -cam_xform.basis.z * input_mv_vec.y
	dir += cam_xform.basis.x * input_mv_vec.x
	
	vel.y = $FloorCheckNode.jump($FloorCast, vel, jump_speed)
	
func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	vel.y += delta * GRAVITY
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir
	target *= current_speed
	
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
		
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		cam_hold.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
		cam_rot = cam_hold.rotation_degrees
		cam_rot.x = clamp(cam_rot.x, -70, 70)
		cam_rot.y = 180
		cam_hold.rotation_degrees = cam_rot

func take_damage(amount):
	if Cheats.cheats.god_mode == false:
		health -= amount
		emit_signal("hurt")
	if health <= 0:
		get_tree().reload_current_scene()
