extends KinematicBody

const GRAVITY = -15
var velocity = Vector3()
const TRUE_MAX_SPEED = 6
var MAX_SPEED = 6
const JUMP_FORCE = 4
const ACCELERATION = 3
var dir = Vector3()

const DEACCELERATION = 5
const MAX_SLOPE_ANGLE = 45

onready var camera = get_node("Camera")

var MOUSE_SENSITIVITY = 0.09

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	handle_stances(delta)
	
func process_input(delta):
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector2()
	
	if Input.is_action_pressed("move_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_movement_vector.x += 1
		
	input_movement_vector = input_movement_vector.normalized()
	
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	
	if is_on_floor():
		if Input.is_action_pressed("move_jump"):
			velocity.y = JUMP_FORCE
	
	if Input.is_action_just_released("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	
	velocity.y += delta * GRAVITY
	
	var hvel = velocity
	hvel.y = 0
	
	var target = dir
	target *= MAX_SPEED
	
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCELERATION
	else:
		accel = DEACCELERATION
	
	hvel = hvel.linear_interpolate(target, accel * delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	velocity = move_and_slide(velocity, Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	
func handle_stances(delta):
	if Input.is_action_pressed("move_crouch"):
		self.scale.y = lerp(self.scale.y, 0.5, delta*2)
		MAX_SPEED = 2
	else:
		self.scale.y = lerp(self.scale.y, 1, delta*2)
		MAX_SPEED = TRUE_MAX_SPEED
		
	if Input.is_action_pressed("move_prone"):
		self.scale.y = lerp(self.scale.y, 0.2, delta*2)
		MAX_SPEED = 1
	else:
		self.scale.y = lerp(self.scale.y, 1, delta*2)
		MAX_SPEED = TRUE_MAX_SPEED
	
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		camera.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		camera.rotation.x = clamp(camera.rotation.x, -0.90, 1)
