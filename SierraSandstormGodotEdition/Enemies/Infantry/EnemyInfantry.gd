extends KinematicBody

export var speed : float
export var defensive : bool = true

var can_shoot : bool = true
var seen_player : bool = false
var player : KinematicBody

#Path finding stuff
var path = []
var path_node = 0
var velocity = Vector2.ZERO

func _ready() -> void:
	can_shoot = true
	for child in $VisionCasts.get_children():
		child.connect("visible", self, "see_player")
		
func _process(delta: float) -> void:
	if player != null and seen_player == true:
		$PlayerPosition3D.translation = lerp($PlayerPosition3D.translation, player.translation, delta * 5)
		$PlayerPosition3D.translation.y = player.translation.y + 1.5
		look_at_player()
		if defensive:
			pass
	
func see_player():
	seen_player = true

func _on_FindPlayer_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body

func look_at_player():
	$Gun.look_at($PlayerPosition3D.translation, Vector3.UP)
	self.look_at($PlayerPosition3D.translation, Vector3.UP)
			
	self.rotation.x = 0
	self.rotation.z = 0
