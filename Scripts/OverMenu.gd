extends Control

var _save_path = "res://User/Data/Scenes.save"
var first_time 
var savings
var saved_scene
var chapter

var File : FileAccess

func _ready():
	$AudioStreamPlayer2D.play()
	get_tree().paused = false
	$CenterContainer/VBoxContainer/RetryButton.grab_focus()
	get_save()		
		
func _on_retry_button_pressed():
	get_save()
	ChapTransition.change_scene(saved_scene)

func _on_menu_pressed(): 
	Dialogic.end_timeline()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_quit_button_pressed():
	get_tree().quit()

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


func _on_bgmusic_finished():
	$bgmusic.play()
