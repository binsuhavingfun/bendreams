extends Control


var progress = []
var sceneName
var scene_load_status1 = 0
var scene_load_status2 = 0
var scene_load_status3 = 0
var scene_load_status4 = 0
var scene_load_status5 = 0
var scene_load_status6 = 0

var _save_path = "res://User/Data/Scenes.save"
var first_time 
var savings
var saved_scene
var chapter

var File : FileAccess



# Called when the node enters the scene tree for the first time.
func _ready():
	get_save()
	sceneName = saved_scene
	ResourceLoader.load_threaded_request("res://Scenes/Bedroom.tscn")
	ResourceLoader.load_threaded_request("res://Scenes/Corridor.tscn")
	ResourceLoader.load_threaded_request("res://Scenes/GUI.tscn")
	ResourceLoader.load_threaded_request("res://Scenes/main_menu.tscn")
	ResourceLoader.load_threaded_request("res://Scenes/pause_menu.tscn")
	ResourceLoader.load_threaded_request("res://Scenes/game_over.tscn")
	ResourceLoader.load_threaded_request("res://Scenes/clown_chase.tscn")
	ResourceLoader.load_threaded_request("res://Scenes/cutscenes.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	load_assets()
	
func load_assets():
	scene_load_status1 = ResourceLoader.load_threaded_get_status("res://Scenes/Bedroom.tscn", progress)
	scene_load_status2 = ResourceLoader.load_threaded_get_status("res://Scenes/Corridor.tscn", progress)
	scene_load_status3 = ResourceLoader.load_threaded_get_status("res://Scenes/GUI.tscn", progress)
	scene_load_status4 = ResourceLoader.load_threaded_get_status("res://Scenes/main_menu.tscn", progress)
	scene_load_status5 = ResourceLoader.load_threaded_get_status("res://Scenes/pause_menu.tscn", progress)
	$CenterContainer/VBoxContainer/CountDown.text = str(floor(progress[0]*100)) + "%"
	if scene_load_status1 == ResourceLoader.THREAD_LOAD_LOADED:
		if scene_load_status2 == ResourceLoader.THREAD_LOAD_LOADED:
			if scene_load_status3 == ResourceLoader.THREAD_LOAD_LOADED:
				if scene_load_status4 == ResourceLoader.THREAD_LOAD_LOADED: 
					if scene_load_status5 == ResourceLoader.THREAD_LOAD_LOADED:
						var newScene = ResourceLoader.load_threaded_get(sceneName)
						ChapTransition.change_scene(newScene)
						Dialogic.VAR.reset()
func get_save():
	var File = FileAccess.open(_save_path, FileAccess.READ)
	if File.file_exists(_save_path):
		while File.get_position() < File.get_length():
			var test_json_conv = JSON.new()
			test_json_conv.parse(File.get_line())
			var data = test_json_conv.get_data()
			first_time = data["first_time"]
			saved_scene = data["saved_scene"]
			chapter = data["chapter"]
		File.close()
	else:
		save_settings()
		
 
func save_settings():
	var File = FileAccess.open(_save_path, FileAccess.WRITE)
	var data = {
		"first_time": first_time,
		"saved_scene": saved_scene,
		"chapter": chapter,
	}
	File.store_line(JSON.new().stringify(data))
	File.close()

