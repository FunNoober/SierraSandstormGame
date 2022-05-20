extends RayCast

signal visible

func _process(delta: float) -> void:
	if is_colliding() == true and get_collider().is_in_group("Player"):
		emit_signal("visible")
