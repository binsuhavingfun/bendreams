extends Node2D

class_name Save

var _save_path = "res://User/Data/Scenes.save"
var first_time
var saved_scene

var file : FileAccess

func get_save():
	print("save receive")
	var File = FileAccess.open(_save_path, FileAccess.READ)
	if File.file_exists(_save_path):
		print("save loaded")
		File.open(_save_path, file.READ)
		while File.get_position() < File.get_length():
			# Get the saved dictionary from the next line in the save file
			var test_json_conv = JSON.new()
			test_json_conv.parse(File.get_line())
			var data = test_json_conv.get_data()
			first_time = data["first_time"]
			saved_scene = data["saved_scene"]
		File.close()
	else:
		save_settings()

func save_settings():
	print("new save")
	var File = FileAccess.open(_save_path, FileAccess.WRITE)
	var data = {
		"first_time": first_time,
		"saved_scene": saved_scene,
	}
	File.store_line(JSON.new().stringify(data))
	File.close()
	
