extends KinematicBody

export var max_jump_speed = 3
export var crouch_jump_speed = 2
export var max_speed = 5
export var crouch_speed = 3.0
export (Array, PackedScene) var loadout

onready var cam : Node = get_node("CameraHolder/Camera")
onready var cam_hold : Node = get_node("CameraHolder")
onready var lean_tween : Node = get_node("LeanTween")
onready var lean_tween_rot : Node = get_node("LeanTweenRot")
onready var original_hand_pos = $CameraHolder/Camera/Hands.translation

const ACCEL = 20
const DEACCEL = 10
const MOUSE_SENSITIVITY = 1
const MAX_SLOPE_ANGLE = 40
const GRAVITY = -9

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
	FpsApi.shoot_cast = $CameraHolder/Camera/ShootCast
	FpsApi.player = self
	
	emit_signal("player_spawned", self)
	for gun in loadout:
		var v = gun.instance()
		$CameraHolder/Camera/Hands.add_child(v)
	
func _process(delta):
	if Input.is_action_just_pressed("flash_light"):
		flash_enabled = $FlashLight.flash_light(flash_enabled, $CameraHolder/FlashLight)
	
	if health <= 0:
		get_tree().reload_current_scene()
	if Cheats.cheats.fast_mode == true:
		max_speed = 35
		crouch_speed = 35

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	var movement = cos(FpsApi.time+.01)*.1
	$CameraHolder/Camera/Hands.translation.y = movement + -0.334

func process_input(delta):
	if is_crouched or is_leaning or is_aiming:
		current_speed = crouch_speed
		jump_speed = crouch_jump_speed
	else:
		current_speed = max_speed
		jump_speed = max_jump_speed
	
	dir = Vector3()
	var cam_xform = cam.get_global_transform()
	
	var input_mv_vec = Vector2()
	
	if $FloorCast.is_colliding():
		if Input.is_action_pressed("mv_forward") or Input.is_action_pressed("mv_back"):
			input_mv_vec.y += Input.get_axis("mv_back", "mv_forward")
		if Input.is_action_pressed("mv_right") or Input.is_action_pressed("mv_left"):
			input_mv_vec.x +=  Input.get_axis("mv_left", "mv_right")
			
	if Input.is_action_just_pressed("ads"):
		if is_aiming == true:
			is_aiming = false
			$AimTween.interpolate_property($CameraHolder/Camera/Hands, 'translation', $CameraHolder/Camera/AimPosition.translation, original_hand_pos, 1)
			$AimTween.start()
			$CameraHolder/Camera.fov = 90
			return
		if is_aiming == false:
			is_aiming = true
			$AimTween.interpolate_property($CameraHolder/Camera/Hands, 'translation', original_hand_pos, $CameraHolder/Camera/AimPosition.translation, 1)
			$AimTween.start()
			$CameraHolder/Camera.fov = 50
			return
		
		
	if Input.is_action_just_pressed("crouch"):
		is_crouched = $CrouchNode.crouch(is_crouched, $BodyCollision, $CrouchTween)
	
	if Input.is_action_just_pressed("lean_left"):
		if is_leaning == false:
			$LeanNode.lean_left(lean_tween, lean_tween_rot, cam_hold)
			is_leaning = true
		else:
			$LeanNode.reset_lean(lean_tween, lean_tween_rot, cam_hold)
			is_leaning = false
	if Input.is_action_just_pressed("lean_right"):
		if is_leaning == false:
			$LeanNode.lean_right(lean_tween, lean_tween_rot, cam_hold)
			is_leaning = true
		else:
			$LeanNode.reset_lean(lean_tween, lean_tween_rot, cam_hold)
			is_leaning = false
		
	input_mv_vec = input_mv_vec.normalized()
	
	dir += -cam_xform.basis.z * input_mv_vec.y
	dir += cam_xform.basis.x * input_mv_vec.x
	
	if $FloorCast.is_colliding():
		if Input.is_action_just_pressed("mv_jump"):
			vel.y = jump_speed
	
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
