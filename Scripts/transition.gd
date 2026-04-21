extends CanvasLayer

var _save_path = "res://User/Data/Scenes.save"
var first_time 
var savings
var saved_scene
var chapter

var File : FileAccess

func change_scene(target) -> void:
	get_save()
	match chapter:
		"0":
			$CenterContainer/VBoxContainer/Label.text = ""
		"1":
			$CenterContainer/VBoxContainer/Label.text = "CHAPTER 1"
		"2":
			$CenterContainer/VBoxContainer/Label.text = "CHAPTER 2"	
		"3": 
			$CenterContainer/VBoxContainer/Label.text = "CHAPTER 3"
		"4":
			$CenterContainer/VBoxContainer/Label.text = "CHAPTER 4"
		"5":
			$CenterContainer/VBoxContainer/Label.text = "CHAPTER 5"
		"6":
			$CenterContainer/VBoxContainer/Label.text = "CHAPTER 6"
		"7":
			$CenterContainer/VBoxContainer/Label.text = "CHAPTER 7"
		"8": 
			$CenterContainer/VBoxContainer/Label.text = "CHAPTER 8"
		"9":
			$CenterContainer/VBoxContainer/Label.text = "END GAME"
	
	
	$AnimationPlayer.play('fade_in')
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("fade_out")
			
	if target is String:
		if target == "res://Scenes/game_over.tscn":
			$CenterContainer/VBoxContainer/Label.text = ""
		get_tree().change_scene_to_file(target)
	else:
		get_tree().change_scene_to_packed(target)
	
		
func trans(scene):
	$AnimationPlayer.play('fade_in')
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("fade_out")
	get_tree().change_scene_to_file(scene)
	
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
		
