extends Control

func _ready() -> void:
	get_parent().connect("hurt", self, "enable_hurt_ui")

func enable_hurt_ui():
	$HurtUI.color = Color(1,0,0)
	$HurtUI.color.a = 0.33
	var tw = Tween.new()
	tw.interpolate_property($HurtUI, "color", $HurtUI.color, Color(0,0,0,0), $HurtTimer.wait_time)
	get_tree().get_root().add_child(tw)
	tw.start()
