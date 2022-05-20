extends Node

var cheats = {
	'infinite_ammo' : false,
	'god_mode' : false,
	'fast_mode' : false,
	'super_jump': false
}

const file_loc = "user://cheats.json"

func _ready() -> void:
	var dir = Directory.new()
	if dir.file_exists(file_loc) == false:
		var f = File.new()
		f.open(file_loc, f.WRITE)
		f.store_string(JSON.print(cheats))
		f.close()
	else:
		var f = File.new()
		f.open(file_loc, f.READ)
		var content_as_text = f.get_as_text()
		var content_as_dictionary = parse_json(content_as_text)
		cheats = content_as_dictionary
		f.close()
