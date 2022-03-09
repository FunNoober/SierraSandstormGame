extends Spatial

var pop_upped = false
var shot = false

func _ready():
	$VFX/Base/Position3D/Pole/Target/TargetPointBody.set_process(false)
	$AnimationPlayer.play("PopUp")
	
	
func _process(delta):
	if pop_upped == true:
		$VFX/Base/Position3D/Pole/Target/TargetPointBody.set_process(true)
	
func pop_down():
	$AnimationPlayer.play("PopDown")
	$VFX/Base/Position3D/Pole/Target/TargetPointBody.set_process(false)
	shot = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "PopUp":
		pop_upped = true
