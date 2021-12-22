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

onready var camera = get_node("Camera") #Getting the camera node when the game starts

var MOUSE_SENSITIVITY = 0.09

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Making the mouse no longer visible and making it not move out of the window
	
func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	handle_stances(delta)
	
func process_input(delta):
	dir = Vector3() #We want to reset dir everytime so speed does not add up
	var cam_xform = camera.get_global_transform() #Getting the global transform of the camera node and then assigning a variable to it
	var input_movement_vector = Vector2() #Creating a new Vector 3 for handling movement
	
	if Input.is_action_pressed("move_forward"): #Checks if W or Up arrow is pressed
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_backward"): #Checks if S or Down arrow is pressed
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left"): #Checks if A or Left arrow is pressed
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right"): #Checks if D or Right arrow is pressed
		input_movement_vector.x += 1
		
	input_movement_vector = input_movement_vector.normalized() #Normlizing the input vector to avoid moving faster while holding 2 keys
	
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	
	if is_on_floor():
		if Input.is_action_pressed("move_jump"):
			velocity.y = JUMP_FORCE #Adding the jump force to the velocity y
	
	if Input.is_action_just_released("ui_cancel"): #Checking for the Escape key
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE: #Checking the mouse mode if it is visible and not captured
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Setting it to captured if visible
		else: #If the if statement condition is not met then do this
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) #Setting the mouse mode to visible
			
func process_movement(delta):
	dir.y = 0 #Resseting the direction on the y
	dir = dir.normalized() #Normalzing the dir
	
	velocity.y += delta * GRAVITY #Applying gravity
	
	var hvel = velocity #Creating a new variable and setting it to velocity
	hvel.y = 0 #Setting the hvel y axis to 0
	
	var target = dir #Creating a new variable and setting it equal to the dir vector
	target *= MAX_SPEED #Multiplying all axises on the target by the max speed
	
	var accel #Creating a new variable to handel acceleration and deaccleration
	if dir.dot(hvel) > 0:
		accel = ACCELERATION
	else:
		accel = DEACCELERATION
	
	hvel = hvel.linear_interpolate(target, accel * delta) #Interpolating the target by the acceleration and delta
	velocity.x = hvel.x
	velocity.z = hvel.z
	velocity = move_and_slide(velocity, Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE)) #Moving the character controller on velocity
	
func handle_stances(delta):
	if Input.is_action_pressed("move_crouch"):
		self.scale.y = lerp(self.scale.y, 0.5, delta*2) #Lerping to a smaller scale
		MAX_SPEED = 2
	else:
		self.scale.y = lerp(self.scale.y, 1, delta*2)
		MAX_SPEED = TRUE_MAX_SPEED
		
	if Input.is_action_pressed("move_prone"):
		self.scale.y = lerp(self.scale.y, 0.2, delta*2) #Lerping to a smaller scale
		MAX_SPEED = 1
	else:
		self.scale.y = lerp(self.scale.y, 1, delta*2) #Lerping to a smaller scale
		MAX_SPEED = TRUE_MAX_SPEED
	
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1)) #Rotating the whole character controller on the Y axis
		camera.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1)) #Rotating the camera on the X axis
		camera.rotation.x = clamp(camera.rotation.x, -0.90, 1) #Clamping the camera rotation to avoid being up side down
