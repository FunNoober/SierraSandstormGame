extends KinematicBody

var can_shoot : bool = true
var seen_player : bool = false
var player : KinematicBody

var defensive : bool = true

func _ready() -> void:
	can_shoot = true
	for child in $VisionCasts.get_children():
		child.connect("visible", self, "see_player")
		
func _process(delta: float) -> void:
	if seen_player == true and player != null:
		$PlayerPosition3D.translation = lerp($PlayerPosition3D.translation, player.translation, delta * 5)
		if defensive == true:
			$Gun.look_at($PlayerPosition3D.translation, Vector3.UP)
			self.look_at($PlayerPosition3D.translation, Vector3.UP)
			
			#$Gun.rotation.y = clamp($Gun.rotation.y, 0,0)
			self.rotation.x = clamp(self.rotation.x, 0,0)
			self.rotation.z = clamp(self.rotation.z, 0,0)
		
func see_player():
	seen_player = true


func _on_FindPlayer_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
