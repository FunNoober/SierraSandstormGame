extends Spatial

export var max_ammo = 15
export var current_ammo = 15

export var shoot_delay = 0.05
export var reload_delay = 5.0

export var recoil = 1.0

var can_shoot = true
var is_reloading = false

var ammo_counter
var aim_cast_position

onready var shoot_timer = get_node("ShootDelay") #Getting the timer called ShootDelay
onready var shoot_cast = get_node("ShootCast") #Getting the raycat called ShootCast

onready var bullet_hole = load("res://Prefabs/Bullet_Hole.tscn") #Loading a bullet hole prefab

func _ready():
	current_ammo = max_ammo #Setting the current ammo to max ammo to be safe
	ammo_counter = get_node("../../../../Graphical_User_Interface") #Getting the UI from the main scene
	aim_cast_position = get_parent().translation #Setting the aim cast postion to the position of the camera
	shoot_cast.translation = aim_cast_position #Applying the position
	
	shoot_timer.wait_time = shoot_delay #Setting the wait time on the shoot timer node to the fire delay
	$ReloadDelay.wait_time = reload_delay #Getting the reload delay timer node and setting the wait time to the reload time
	
func _physics_process(delta):
	current_ammo = clamp(current_ammo, 0, max_ammo) #Clamping the current ammo to 0 and the max ammo
	
	
	if is_reloading == true:
		ammo_counter.ammo_counter.text = str("RELOADING...") #Setting the text on the GUI to show reloading
		return #Return to prevent code from being ran
	
	if current_ammo <= 0:
		reload_weapon() #Reloading the weapon if the ammo is less than or equal to 0
	
	if Input.is_action_pressed("action_shoot") and can_shoot == true:
		shoot() #Shoot if we press the left mouse button and if we can shoot

func _on_ShootDelay_timeout():
	can_shoot = true #When the shoot timer node finishes, we can now shoot agian

func shoot():
	if ammo_counter != null: #Checking if the ammo counter is not equal to null
		ammo_counter.ammo_counter.text = str(str(current_ammo) + "/" + str(max_ammo)) #Setting the ammo counter text to the current ammo + / + the max ammo
	can_shoot = false #Preventing shooting
	shoot_cast.enabled = true #Enabling the shootcast
	current_ammo -= 1 #Subtracting 1 from the ammo
	shoot_cast.rotation.y = rand_range(-recoil, recoil) #Applying recoil on the shoot cast
	shoot_cast.rotation.z = rand_range(-recoil, recoil) #Applying recoil on the shoot cast
	if shoot_cast.is_colliding() == true: #Checking if the ray intersects
		spawn_bullet_hole() #Calling a function that is named spawn_bullet_hole
	shoot_timer.start() #Starting the shoot timer

func reload_weapon():
	$ReloadDelay.start() #Starting the reload delay timer
	is_reloading = true #Changing the is_reloading variable to true

func _on_ReloadDelay_timeout():
	current_ammo = max_ammo #Resetting the current ammo to the max ammo
	is_reloading = false #Making it so we are no longer reloading
	if ammo_counter != null:
		ammo_counter.ammo_counter.text = str(str(current_ammo) + "/" + str(max_ammo)) #Setting the ammo counter
		
func spawn_bullet_hole():
	var new_bullet_hole = bullet_hole.instance() #Creating a new instance of the bullet hole prefab
	get_tree().get_root().add_child(new_bullet_hole) #Getting the root then adding the bullet hole as a child
	new_bullet_hole.translation = shoot_cast.get_collision_point() #Setting the position to the shoot cast collision point
	
	var surface_dir_up = Vector3(0,1,0) #Setting the surface up to a up represented by a vector 3
	var surface_dir_down = Vector3(0,-1,0) #Setting the surface down to a down represented by a vector 3
	
	#If statements below checks the normal of the face that the shoot cast collided with
	#Indented statements below make the bullet hole look torwards the normal of the collided face
	if shoot_cast.get_collision_normal() == surface_dir_up:
		new_bullet_hole.look_at(shoot_cast.get_collision_point() + shoot_cast.get_collision_normal(), Vector3.RIGHT)
	elif shoot_cast.get_collision_normal() == surface_dir_down:
		new_bullet_hole.look_at(shoot_cast.get_collision_point() + shoot_cast.get_collision_normal(), Vector3.RIGHT)
	else:
		new_bullet_hole.look_at(shoot_cast.get_collision_point() + shoot_cast.get_collision_normal(), Vector3.DOWN)
