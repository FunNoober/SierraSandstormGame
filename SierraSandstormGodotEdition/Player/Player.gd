extends KinematicBody

export var jump_speed = 6
export var max_speed = 10.0
export var crouch_speed = 3.0
export (Array, PackedScene) var loadout

onready var cam : Node = get_node("CameraHolder/Camera")
onready var cam_hold : Node = get_node("CameraHolder")
onready var lean_tween : Node = get_node("LeanTween")
onready var lean_tween_rot : Node = get_node("LeanTweenRot")

const ACCEL = 20
const DEACCEL = 20
const MOUSE_SENSITIVITY = 1
const MAX_SLOPE_ANGLE = 40
const GRAVITY = -9

var health
var time = 0.0
var is_crouched : bool
var is_leaning : bool
var flash_enabled : bool
var dir = Vector3()
var vel = Vector3()
var cam_rot
var current_speed

signal player_spawned(player)

func _ready():
	current_speed = max_speed
	#Setting the camera rotation on start
	cam_rot = cam_hold.rotation_degrees
	cam_rot.x = clamp(cam_rot.x, -70, 70)
	cam_rot.y = 180
	cam_hold.rotation_degrees = cam_rot
	#End
	
	#Setting default values
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	health = 100.0
	FpsApi.shoot_cast = $CameraHolder/Camera/ShootCast
	FpsApi.player = self
	#End
	
	emit_signal("player_spawned", self)
	#Spawining in the starting weapon
	for gun in loadout:
		var v = gun.instance()
		$CameraHolder/Camera/Hands.add_child(v)
	#End
	
func _process(delta):
	if Input.is_action_just_pressed("flash_light"):
		flash_enabled = $FlashLight.flash_light(flash_enabled, $CameraHolder/FlashLight)
	
	if health <= 0:
		get_tree().reload_current_scene()

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):
	if is_crouched or is_leaning:
		current_speed = crouch_speed
	else:
		current_speed = max_speed
	
	dir = Vector3()
	var cam_xform = cam.get_global_transform()
	
	var input_mv_vec = Vector2()
	
	if Input.is_action_pressed("mv_forward"):
		input_mv_vec.y += 1
	if Input.is_action_pressed("mv_back"):
		input_mv_vec.y -= 1
	if Input.is_action_pressed("mv_right"):
		input_mv_vec.x += 1
	if Input.is_action_pressed("mv_left"):
		input_mv_vec.x -= 1
		
	if Input.is_action_just_pressed("crouch"):
		is_crouched = $CrouchNode.crouch(is_crouched, $BodyCollision, $CrouchTween)
	
	#Leaning behavior and input
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
	#End
		
	#Normalizing to prevent moving faster while holding down 2 keys at once
	input_mv_vec = input_mv_vec.normalized()
	#End
	
	#Some magic to get the relative rotation
	dir += -cam_xform.basis.z * input_mv_vec.y
	dir += cam_xform.basis.x * input_mv_vec.x
	#End
	
	if is_on_floor():
		if Input.is_action_just_pressed("mv_jump"):
			vel.y = jump_speed
	
func process_movement(delta):
	#I don't know what the below code does, just copied it from the Godot Docs
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
	#End

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		cam_hold.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
		cam_rot = cam_hold.rotation_degrees
		cam_rot.x = clamp(cam_rot.x, -70, 70)
		cam_rot.y = 180
		cam_hold.rotation_degrees = cam_rot

func take_damage(amount):
	health -= amount
	#TODO: Add hurt user interface to let the player know when they are hurt
	if health <= 0:
		get_tree().reload_current_scene()
