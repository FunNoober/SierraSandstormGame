extends Spatial

var cur_i : int = 1

func _ready() -> void:
	switch_weapon()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch_weapon"):
		switch_weapon()

func switch_weapon():
	if cur_i >= get_child_count():
		cur_i = 0
	
	for i in get_child_count():
		get_child(i).set_process(false)
		get_child(i).hide()
		get_child(i).get_node("HUD/Container").hide()
		if i == cur_i:
			get_child(i).set_process(true)
			get_child(i).show()
			get_child(i).get_node("HUD/Container").show()
	cur_i += 1
