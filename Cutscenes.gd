extends Node2D

var _save_path = "res://User/Data/Scenes.save"
var first_time
var saved_scene
var chapter
var file : FileAccess

enum { IDLE, MOVE, RUN }

# Called when the node enters the scene tree for the first time.
func _ready():
	get_save()
	Dialogic.signal_event.connect(DialogicSignal)
	if saved_scene == "res://Scenes/clown_chase.tscn":
		$HidingInside/Clown/ClownSprite.change_state(MOVE)
		$HidingInside/Ben/Ben_Sprite.change_state(RUN)
		DialogicSignal("room_hiding")
	else:
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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
		print("Save file not found, creating new save")
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
	
func run_dialogue(dialogue_string):
	Dialogic.start(dialogue_string)
func DialogicSignal(arg: String):
	if arg == "room_hiding":
		$HidingInside/Ben/Ben_Sprite.change_state(MOVE)
		$HidingInside/Clown/ClownSprite.change_state(MOVE)
		$HidingInside.visible = true
		$HidingInside/AnimationPlayer.play("inside")
		await $HidingInside/AnimationPlayer.animation_finished
		$HidingInside/Ben/Ben_Sprite.change_state(IDLE)
		run_dialogue("temp")
	if arg == "get_in":
		$HidingInside/Clown/ClownSprite.change_state(IDLE)
		$HidingInside/Ben/Ben_Sprite.set_flip_h(true)
		$HidingInside/AnimationPlayer.play("me_aswell")
		await $HidingInside/AnimationPlayer.animation_finished
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		$HidingInside.visible = false
		$Fade.visible = false
		save_settings()
		get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
		
		
