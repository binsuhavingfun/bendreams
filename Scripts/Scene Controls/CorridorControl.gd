extends Node2D

@onready var Player : CharacterBody2D = $Ben
@onready var audio_player : AudioStreamPlayer2D = $bgmusic
@onready var PianoPlayer : CharacterBody2D = $PianoPlay/Ben
@onready var PlayerSprite : AnimatedSprite2D = $PianoPlay/Ben/Ben_Sprite
@onready var ClownUser : AnimatedSprite2D = $"Clown Intro/Center/Ben/Ben_Sprite"
@onready var ClownSprite : AnimatedSprite2D = $"Clown Intro/Center/Clown/ClownSprite"
#Saving\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
var _save_path = "res://User/Data/Scenes.save"
var first_time
var saved_scene
var chapter
var file : FileAccess
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#variables\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
var is_chatting = false
var songs = ["res://Sound/BGM/MENU THEME.mp3", "res://Sound/BGM/REALITY THEME.mp3", "res://Sound/BGM/DREAM THEME.mp3"]
enum { IDLE, MOVE, RUN }
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#dialogic\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
var allow_action = true
var player_in_area_door = false
var player_in_area_door2 = false
var player_in_area_piano = false
var piano_was_played = false
var interacting = false
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

func _ready():
	$Fade.visible = false
	Dialogic.VAR.reset()
	get_tree().paused = false
	get_save()
	check_freedom()	
	Dialogic.signal_event.connect(DialogicSignal)
			
func _process(delta):
	
	if is_chatting == true:
		Player.is_chatting(true)
	else:
		Player.is_chatting(false)
		
		
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
	
func check_freedom():
	match chapter:
		"2":
			is_chatting = false
			Player.should_move(true)
			Player.line_show(true)
			sceneConfigs(chapter)
		"3":
			if saved_scene == "res://Dialogue/TimeLines/Corridoor.dtl":
				is_chatting = true
				allow_action = false
				Player.should_move(false)
				Player.line_show(false)
				sceneConfigs(chapter)
			else:
				is_chatting = false
				allow_action = true
				Player.should_move(true)
				Player.line_show(true)
				sceneConfigs(chapter)
			
	
func sceneConfigs(Chapter):
	match Chapter:
		"2":
			Dialogic.VAR.Corridor.alreadySet = false
			$PianoPlay.visible = false
			allow_action = true
			audio_player.stream = load(songs[2])
			audio_player.play()
		"3":
			if saved_scene == "res://Scenes/clown_chase.tscn":
				audio_player.stream = load(songs[2])
				audio_player.play()
				Player.position = Vector2(-2112, 475)
			else:
				$"Clown Intro".visible = true
				allow_action = false
				run_dialogue("interruption")
#Door\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
func _on_door_input_event(viewport, event, shape_idx):
	if allow_action == true:
		if player_in_area_door:
			if event.is_action_pressed("ui_leftMouseClick"):
				if first_time == true && piano_was_played == true:
					match chapter:
						"2":
							first_time = false
							saved_scene = "res://Scenes/Corridor.tscn"
							chapter = "3"
							save_settings()
							ChapTransition.change_scene(saved_scene)
				else: 
					run_dialogue("Corridoor")
func _on_door_body_entered(body):
	if body.has_method("Player"):
		player_in_area_door = true
func _on_door_body_exited(body):
	if body.has_method("Player"):
		player_in_area_door = false
#Door\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#piano\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
func _on_piano_input_event(viewport, event, shape_idx):
	if allow_action == true:
		if player_in_area_piano:
			if event.is_action_pressed("ui_leftMouseClick"):
				if saved_scene != "res://Scenes/clown_chase.tscn":
					run_dialogue("Piano")
				else:
					run_dialogue("ITEMS/Piano")
func _on_piano_body_entered(body):
	if body.has_method("Player"):
		player_in_area_piano = true
func _on_piano_body_exited(body):
	if body.has_method("Player"):
		player_in_area_piano = false
#piano\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#Dialogic\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
func run_dialogue(dialogue_string):
	interacting = true
	is_chatting = true
	Player.should_move(false)
	Player.line_show(false)
	Dialogic.start(dialogue_string)
func DialogicSignal(arg: String):
	if arg == "inside_room":
			if player_in_area_door == true:	
				first_time = false
				saved_scene = "res://Scenes/Bedroom.tscn"
				save_settings()
				Transition.trans("res://Scenes/Bedroom.tscn")
	if arg == "set_piano":
		print("set_piano")
		Dialogic.VAR.Corridor.alreadySet = true
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		$Fade/AnimationPlayer.play("fade_out")
		$Fade.visible = false
		PianoPlayer.position == Vector2(438, 975)
		$PianoPlay.visible = true
		run_dialogue("Piano")
		Dialogic.end_timeline()
	if arg == "play_piano":
		Dialogic.VAR.Corridor.PianoInteractable = false
		piano_was_played = true
		PlayerSprite.change_state(MOVE)
		$PianoPlay/AnimationPlayer.play("Go_to_piano")
		await $PianoPlay/AnimationPlayer.animation_finished
		PlayerSprite.change_state(IDLE)
		$PianoPlay/AudioStreamPlayer2D.play()
		if $PianoPlay/AudioStreamPlayer2D.finished:
			run_dialogue("afterpiano")
		Dialogic.end_timeline()
	if arg == "afterpiano":
		PlayerSprite.change_state(MOVE)
		$PianoPlay/Ben/Ben_Sprite.set_flip_h(true)
		if piano_was_played == true:
			$PianoPlay/AnimationPlayer.play("Get_off_piano")
		else:
			$PianoPlay/AnimationPlayer.play("Get_out")
			piano_was_played = true
		await $PianoPlay/AnimationPlayer.animation_finished
		PlayerSprite.change_state(IDLE)
		if PianoPlayer.position == Vector2(-200, 975):
			$Fade.visible = true
			$Fade/AnimationPlayer.play("fade_in")
			await $Fade/AnimationPlayer.animation_finished
			$Fade/AnimationPlayer.play("fade_out")
			$Fade.visible = false
			$PianoPlay.visible = false
			Player.position =  Vector2(1661, 475)
			$Ben/Ben_Sprite.set_flip_h(true)
			Dialogic.end_timeline()
			is_chatting = false
			allow_action = true
			interacting = false
			Player.should_move(true)
			Player.line_show(true)
	#chapter 3\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	if arg == "character_turn":
		allow_action = false
		interacting = true
		$"Clown Intro/Center/Ben/Ben_Sprite" .set_flip_h(true)
	if arg == "animation":
		$"Clown Intro/AnimationPlayer".play("zoom out")
		await $"Clown Intro/AnimationPlayer".animation_finished
		$"Clown Intro/AnimationPlayer".play("pan_to_left")
		await $"Clown Intro/AnimationPlayer".animation_finished
		run_dialogue("clown_encounter")
	if arg == "clown_enter":
		ClownSprite.change_state(MOVE)
		$"Clown Intro/AnimationPlayer".play("clown_enter")
		await $"Clown Intro/AnimationPlayer".animation_finished
		ClownSprite.change_state(IDLE)
	if arg == "action_stay":
		$"Clown Intro/incorrect".play()
		await $"Clown Intro/incorrect".finished
		if Dialogic.VAR.Corridor.noClo < 5:
			ClownUser.change_state(MOVE)
			Dialogic.VAR.Corridor.noClo += 1
			var i = Dialogic.VAR.Corridor.noClo
			print(i)
			if i == 1:
				$"Clown Intro/AnimationPlayer".play("go_to_clown1")
				run_dialogue("action_staytimeline")
			if i == 2:
				$"Clown Intro/AnimationPlayer".play("go_to_clown2")
				run_dialogue("action_stay")
			if i == 3:
				$"Clown Intro/AnimationPlayer".play("go_to_clown3")
				run_dialogue("clown_action3")
			if i == 4:
				$"Clown Intro/AnimationPlayer".play("go_to_clown4")
				run_dialogue("clown_action4")
			if i == 5:
				$"Clown Intro/AnimationPlayer".play("go_to_clown5")
				run_dialogue("final_action_stay")
			await $"Clown Intro/AnimationPlayer".animation_finished
			ClownUser.change_state(IDLE)
			print(i)
		else:
				print("dead")
				$"Clown Intro/jscare".play()
				$"Clown Intro/AnimationPlayer".play("jump_scare")
				await  $"Clown Intro/AnimationPlayer".animation_finished
				$Fade.visible = true
				$Fade/AnimationPlayer.play("fade_in")
				await $Fade/AnimationPlayer.animation_finished
				$Fade/AnimationPlayer.play("fade_out")
				await $"Clown Intro/jscare".finished
				save_settings()
				get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
	if arg == "action_run":
		$"Clown Intro/Center/Ben/Ben_Sprite" .set_flip_h(false)
		ClownUser.change_state(RUN)
		$"Clown Intro/AnimationPlayer".play("running_away")
	if arg == "clown_follows":
		ClownSprite.change_state(MOVE)
		$"Clown Intro/AnimationPlayer".play("clown_follows")
		await $"Clown Intro/AnimationPlayer".animation_finished
		$"Clown Intro".visible = false
		first_time = false
		saved_scene = "res://Scenes/Corridor.tscn"
		chapter = "3"
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		save_settings()
		ChapTransition.trans("res://Scenes/clown_chase.tscn")
	if arg == "stop_chat":
		interacting = false
		is_chatting = false
		allow_action = true
		Player.should_move(true)
		Player.line_show(true)
#Dialogic\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

func fade_effect():
	$Fade.visible = true
	$Fade/AnimationPlayer.play("fade_in")
	await $Fade/AnimationPlayer.animation_finished
	$Fade/AnimationPlayer.play("fade_out")
	$Fade.visible = false
	
		

#door
func _on_door_mouse_entered():
	if allow_action && player_in_area_door:
		if interacting == false:
			$WorldEnvironment/Door/Door2.visible = true
func _on_door_mouse_exited():
	if allow_action && player_in_area_door:
		if interacting == false:
			$WorldEnvironment/Door/Door2.visible = false
#door
#piano#
func _on_piano_mouse_entered():
	if allow_action && player_in_area_piano:
		if interacting == false:
			$WorldEnvironment/Piano/Piano2.visible = true
func _on_piano_mouse_exited():
	if allow_action && player_in_area_piano:
		if interacting == false:
			$WorldEnvironment/Piano/Piano2.visible = false
#piano
#clock
func _on_clock_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ui_leftMouseClick"):
		run_dialogue("clock_corridor")
func _on_clock_mouse_entered():
	if allow_action:
		if interacting == false:
			$WorldEnvironment/WallAndFloor/Clock2.visible = true
func _on_clock_mouse_exited():
	if allow_action:
		if interacting == false:
			$WorldEnvironment/WallAndFloor/Clock2.visible = false
#clock
#door2
func _on_door_3_mouse_exited():
	if allow_action && player_in_area_door2:
		$WorldEnvironment/Door2/Door2.visible = false
func _on_door_3_mouse_entered():
	if allow_action && player_in_area_door2:
		$WorldEnvironment/Door2/Door2.visible = true
func _on_door_3_input_event(viewport, event, shape_idx):
	pass # Replace with function body.
func _on_door_3_body_entered(body):
	if body.has_method("Player"):
		player_in_area_door2 = true
func _on_door_3_body_exited(body):
	if body.has_method("Player"):
		player_in_area_door2 = false
#door2
