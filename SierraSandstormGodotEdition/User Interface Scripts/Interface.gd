extends Control

func _ready() -> void:
	get_parent().connect("hurt", self, "enable_hurt_ui")

func enable_hurt_ui():
	$HurtUI.show()
	$HurtTimer.start()

func _on_HurtTimer_timeout() -> void:
	$HurtUI.hide()
