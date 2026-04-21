extends Control

var _save_path = "res://User/Data/Scenes.save"
var first_time 
var savings
var saved_scene
var chapter

var File : FileAccess


@onready var continueButton : Button = $VBoxContainer/ContinueButton

func _ready():	
	get_tree().paused = false
	$VBoxContainer/StartButton.grab_focus()
	#create_file()
	get_save()	
	if saved_scene != null:
		ResourceLoader.load_threaded_request("res://Scenes/pause_menu.tscn")
	if (chapter == ""):
		continueButton.visible = false
	else: 
		continueButton.visible = true
			
func _on_start_button_pressed():
	saved_scene = "res://Scenes/Bedroom.tscn"
	first_time = true
	chapter = "0"
	save_settings()
	get_tree().change_scene_to_file("res://Scenes/loading.tscn")

func _on_credit_button_pressed():
	pass 

func _on_quit_button_pressed():
	get_tree().quit()

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://Scenes/loading.tscn")
	
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
	
func create_file():
	var File = FileAccess.open(_save_path, FileAccess.WRITE)
	File.close()
	get_save()
	

func _on_audio_stream_player_2d_finished():
	$AudioStreamPlayer2D.play()
