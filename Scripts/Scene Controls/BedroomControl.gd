extends Node2D

@onready var nav : NavigationAgent2D = $NavigationaAgent2D
@onready var nav2d : NavigationRegion2D = $NavigationRegion2D
@onready var nav2d2 : NavigationRegion2D = $NavigationRegion2D2
@onready var nav2d3 : NavigationRegion2D = $NavigationRegion2D3
@onready var line2D : Line2D = $Line2D
@onready var Player : CharacterBody2D = $Ben
@onready var PlayerSprite : AnimatedSprite2D = $Ben/Ben_Sprite
@onready var BenShadow : AnimatedSprite2D = $WorldEnvironment/BenShadow

#items\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
@onready var switch : Sprite2D = $WorldEnvironment/SwitchOff
@onready var lights : Sprite2D = $WorldEnvironment/TopLightOn
@onready var door : Sprite2D = $WorldEnvironment/DoorClose
@onready var audio_player : AudioStreamPlayer2D = $bgmusic
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#variables\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
var switch_on = true
var door_closed = true
var window_closed = true
var out_bed = true
var is_chatting = false
var encounters = 0;
var songs = ["res://Sound/BGM/MENU THEME.mp3", "res://Sound/BGM/REALITY THEME.mp3", "res://Sound/BGM/DREAM THEME.mp3", "res://Sound/SFX/OFF/Weather Ambience/BAGYO 1.mp3"]
enum { IDLE, MOVE, RUN }
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#dialogic\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
var player_in_area = false
var player_in_area_light = false
var player_in_area_door = false
var player_in_area_window = false
var player_in_area_bed = false
var player_in_area_mirror = false
var player_in_area_plush = false
var allow_action = true
var interacting = false
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#saving\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
var _save_path = "res://User/Data/Scenes.save"
var first_time
var saved_scene
var chapter
var file : FileAccess
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

func _ready():
	$".".visible = true
	Dialogic.VAR.reset()
	get_tree().paused = false
	get_save()
	check_freedom()
			
	Dialogic.signal_event.connect(DialogicSignal)
	
func _process(delta):
	if Input.is_action_pressed("ui_leftMouseClick"):
		return
		
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
		"0":
			Player.should_move(false)
			player_in_area = true
			Player.line_show(false)
			sceneConfigs(chapter)
			run_dialogue("Goodnight")
		"1":
			Player.should_move(false)
			player_in_area = true
			Player.line_show(false)
			sceneConfigs(chapter)
			run_dialogue("Encounter")
		"2":
			if first_time == true:
				Player.should_move(false)
				Player.line_show(false)
				player_in_area = false
				sceneConfigs(chapter)
				run_dialogue("WakingUp")
			else:
				DialogicSignal("switchOff")
				Player.line_show(true)
				player_in_area = false
				Player.should_move(true)
				sceneConfigs(chapter)
		"3":
			DialogicSignal("switchOff")
			door_closed = true
			Player.should_move(true)
			Player.line_show(true)
			player_in_area = false
			sceneConfigs(chapter)
		"4":
			Player.should_move(false)
			Player.line_show(false)
			player_in_area = false
			sceneConfigs(chapter)
			$Raining.visible = true
			$Raining/AnimationPlayer.play("raining")
			run_dialogue("rainy")
		"5":
			Player.should_move(false)
			Player.line_show(false)
			player_in_area = false
			sceneConfigs(chapter)
			$Mirror.visible = true
			$Mirror/AnimationPlayer.play("go_to_mirror")
			await $Mirror/AnimationPlayer.animation_finished
			$Mirror/Ben/Ben_Sprite.change_state(IDLE)
			run_dialogue("break")
#Dialogic\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
func run_dialogue(dialogue_string):
	interacting = true
	is_chatting = true
	Player.should_move(false)
	Player.line_show(false)
	Dialogic.start(dialogue_string)
func DialogicSignal(arg: String):
	if arg == "switchOn" || arg == "switchOff":
		switch_on = !switch_on
		Dialogic.VAR.Bedroom.switchOn = !Dialogic.VAR.Bedroom.switchOn
		if switch_on == false:
			$WorldEnvironment/SwitchOn.texture=ResourceLoader.load("res://Scenes/Objects/Chapter 1/States/Dark Mode/switch off.png")
		elif switch_on == true:
			$WorldEnvironment/SwitchOn.texture=ResourceLoader.load("res://Scenes/Objects/Chapter 1/States/Dark Mode/switch on.png")
		lights.visible = !lights.visible
		is_chatting = false
		interacting = false
		Dialogic.end_timeline()
		if player_in_area == false:
			Player.should_move(true)
			Player.line_show(true)
	if arg == "doorOpen" || arg == "doorClosed":
		door_closed = !door_closed
		Dialogic.VAR.Bedroom.doorClosed = !Dialogic.VAR.Bedroom.doorClosed
		if door_closed == false:
			$WorldEnvironment/DoorClose.texture=ResourceLoader.load("res://Scenes/Objects/Chapter 1/States/Dark Mode/door open.png")
			$NavigationRegion2D.navigation_polygon= nav2d2.navigation_polygon
			$WorldEnvironment/DoorClose/door_open.play()
			Player.set_up()
			door.door_is_closed(false)
		elif door_closed == true:
			$WorldEnvironment/DoorClose.texture=ResourceLoader.load("res://Scenes/Objects/Chapter 1/States/Dark Mode/door closed.png")
			$NavigationRegion2D.navigation_polygon= nav2d3.navigation_polygon
			$WorldEnvironment/DoorClose/door_close.play()
			Player.set_up()
			door.door_is_closed(true)
		is_chatting = false
		interacting = false
		Dialogic.end_timeline()
		if player_in_area == false:
			Player.should_move(true)
			Player.line_show(true)
	if arg == "windowOpen" || arg == "windowClosed":
		window_closed = !window_closed
		Dialogic.VAR.Bedroom.windowClosed = !Dialogic.VAR.Bedroom.windowClosed
		if window_closed == false:
			$WorldEnvironment/WindowClose.texture=ResourceLoader.load("res://Scenes/Objects/Chapter 1/States/Dark Mode/window open.png")
			$WorldEnvironment/WindowClose/window_open.play()
		elif window_closed == true:
			$WorldEnvironment/WindowClose.texture=ResourceLoader.load("res://Scenes/Objects/Chapter 1/States/Dark Mode/window close.png")
			$WorldEnvironment/WindowClose/window_close.play()
		is_chatting = false
		interacting = false
		Dialogic.end_timeline()
		if player_in_area == false:
			Player.should_move(true)
			Player.line_show(true)
	if arg == "can_sleep":
		run_dialogue("Bed")
		Dialogic.end_timeline()
	if arg == "go_sleep":
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		$Fade/AnimationPlayer.play("fade_out")
		$Intro.visible = false
		allow_action = true
	if arg == "encountered":
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		$Fade/AnimationPlayer.play("fade_out")
		encounters += 1
		BenShadow.position.x += 250
		if encounters == 1:
			run_dialogue("Encounter")
		if encounters == 2:
			run_dialogue("Encounter")
		if encounters == 3:
			sceneConfigs(chapter)
		interacting = false
		Dialogic.end_timeline()
	if arg == "OnBed":
		out_bed = !out_bed
		Dialogic.VAR.Bedroom.OutofBed = !Dialogic.VAR.Bedroom.OutofBed
		if (window_closed == true && door_closed == true && switch_on == false) || chapter == "4":			
			$Fade.visible = true
			$Fade/AnimationPlayer.play("fade_in")
			await $Fade/AnimationPlayer.animation_finished
			$Fade/AnimationPlayer.play("fade_out")
			$Fade.visible = false
			await sleep()
			$Sleeping.visible = true
			match chapter:
				"0":
					first_time = true
					saved_scene = "res://Scenes/Bedroom.tscn"
					chapter = "1"
					save_settings()
					ChapTransition.change_scene(saved_scene)
				"1":
					first_time = true
					saved_scene = "res://Scenes/Bedroom.tscn"
					chapter = "2"
					save_settings()
					ChapTransition.change_scene(saved_scene)
				"3":
					first_time = false
					saved_scene = "res://Scenes/Bedroom.tscn"
					chapter = "4"
					save_settings()
					ChapTransition.change_scene(saved_scene)
				"4":
					first_time = false
					saved_scene = "res://Scenes/Bedroom.tscn"
					chapter = "5"
					save_settings()
					ChapTransition.change_scene(saved_scene)
			Dialogic.end_timeline()
			Dialogic.VAR.Bedroom.OutofBed = !Dialogic.VAR.Bedroom.OutofBed
		else:
			Dialogic.VAR.Bedroom.OutofBed = !Dialogic.VAR.Bedroom.OutofBed
			run_dialogue("checkBed")
		is_chatting = false
		interacting = false
	if arg == "awake":
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		$Fade/AnimationPlayer.play("fade_out")
		Dialogic.VAR.Bedroom.switchOn = false
		$Fade.visible = false
		$Sweat.visible = false
		BenShadow.visible = false
		Player.position = Vector2(320,420)
		Player.visible = true
		allow_action = true
		interacting = false
		Dialogic.end_timeline()
	if arg == "out_of_bed":
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		$Fade/AnimationPlayer.play("fade_out")
		$Fade.visible = false
		$OnBed.visible = false
		$Sweat.visible = true
		run_dialogue("beginning")
		interacting = false
		Dialogic.end_timeline()
	if arg == "checking_out":
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		$Fade/AnimationPlayer.play("fade_out")
		$Fade.visible = false
		Player.position = Vector2(320,420)
		$Sweat.visible = false
		Dialogic.VAR.Bedroom.switchOn = false
		allow_action = true
		player_in_area = false
		is_chatting = false
		Player.should_move(true)
		Player.line_show(true)
		interacting = false
		Dialogic.end_timeline()
	if arg == "close_window":
		$Raining.visible = false
		$".".visible = true
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		$Fade/AnimationPlayer.play("fade_out")
		Dialogic.VAR.Bedroom.switchOn = false
		$Fade.visible = false
		allow_action = true
		player_in_area = false
		is_chatting = false
		Player.should_move(true)
		Player.line_show(true)
		interacting = false
		Dialogic.end_timeline()
	if arg == "stop_chat":
		interacting = false
		is_chatting = false
		allow_action = true
		if player_in_area == false:
			Player.should_move(true)
			Player.line_show(true)
	if arg == "appear":
		$Mirror/Ben2/Ben_Sprite.set_flip_h(true)
		$Mirror/Ben/Ben_Sprite.set_flip_h(true)
		$Mirror/AnimationPlayer.play("appear")
		await $Mirror/AnimationPlayer.animation_finished
	if arg == "Over":
		run_dialogue("other")
	if arg == "wack":
		$Mirror/AnimationPlayer.play("wack")
		await $Mirror/AnimationPlayer.animation_finished
		first_time = false
		saved_scene = "res://Scenes/Bedroom.tscn"
		ChapTransition.change_scene("res://Scenes/game_over.tscn")
	if arg == "Truth":
		run_dialogue("end")
	if arg == "shadow":
		$Mirror/AnimationPlayer.play("shadow")
	if arg == "end":
		first_time = ""
		chapter = ""
		saved_scene = ""
		save_settings()
		ChapTransition.change_scene("res://Scenes/GAME SCREEN.tscn")

		
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#switch\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
func _on_switch_area_input_event(viewport, event, shape_idx):
	if allow_action == true:
		if player_in_area || player_in_area_light:
			if event.is_action_pressed("ui_leftMouseClick"):
				run_dialogue("Switch")
func _on_switch_area_body_entered(body):
	if body.has_method("Player"):
		player_in_area_light = true
func _on_switch_area_body_exited(body):
	if body.has_method("Player"):
		player_in_area_light = false
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#door\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
func _on_door_area_input_event(viewport, event, shape_idx):
	if allow_action == true:
		if player_in_area || player_in_area_door:
			if event.is_action_pressed("ui_leftMouseClick"):
				if chapter != "4" || chapter != "6":
					run_dialogue("Door")
				else:
					run_dialogue("NoDoor")
func _on_door_area_body_entered(body):
	if body.has_method("Player"):
		player_in_area_door = true
func _on_door_area_body_exited(body):
	if body.has_method("Player"):
		player_in_area_door = false
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#window\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
func _on_wincdow_input_event(viewport, event, shape_idx):
	if allow_action == true:
		if player_in_area || player_in_area_window:
			if event.is_action_pressed("ui_leftMouseClick"):
				run_dialogue("Window")
func _on_wincdow_body_entered(body):
	if body.has_method("Player"):
		player_in_area_window = true
func _on_wincdow_body_exited(body):
	if body.has_method("Player"):
		player_in_area_window = false
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#bed\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	
func _on_bed_input_event(viewport, event, shape_idx):
	if allow_action == true:
		if player_in_area || player_in_area_bed:
				if event.is_action_pressed("ui_leftMouseClick"):
					if chapter == "4":
						$".".visible = false	
						$Raining.visible = true
						$Fade.visible = true
						$Fade/AnimationPlayer.play("fade_in")
						await $Fade/AnimationPlayer.animation_finished
						$Fade/AnimationPlayer.play("fade_out")
						$Fade.visible = false
						if window_closed == true:
							$bgmusic.volume_db = 10.0
							$Raining/AnimationPlayer.play("closed_window")
							run_dialogue("window_closed")
						else:
							$bgmusic.stop()
							$Raining/AnimationPlayer.play("opened_window")
					#else:
						#run_dialogue("window_opened")
					run_dialogue("Bed")
func _on_bed_body_entered(body):
	if body.has_method("Player"):
		player_in_area_bed = true
func _on_bed_body_exited(body):
	if body.has_method("Player"):
		player_in_area_bed = false
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

func sceneConfigs(Chapter):
	match Chapter:
		"0":
			BenShadow.visible = false
			audio_player.stream = load(songs[1])
			audio_player.play()
			$Intro.visible = true
			allow_action = false
		"1":
			BenShadow.visible = true
			DialogicSignal("switchOff")
			Player.visible = false
			$Ben_asleep.visible = true
			allow_action = false
			if encounters == 3:
				$Ben_asleep.visible = false
				$bgmusic.play()
				DialogicSignal("switchOff")
				$Sweat.visible = true
				run_dialogue("minutesLater")
		"2":
			if first_time != false:
				BenShadow.visible = false
				DialogicSignal("switchOff")
				allow_action = false
				audio_player.stream = load(songs[2])
				audio_player.play()
				$OnBed.visible = true
			else:
				audio_player.stream = load(songs[2])
				audio_player.play()
				allow_action = true
				first_time = true
				save_settings()
		"3":
			audio_player.stream = load(songs[2])
			audio_player.play()
			allow_action = true
			first_time = false
			save_settings()
		"4":
			$".".visible = false
			DialogicSignal("switchOff")
			DialogicSignal("windowOpen")
			audio_player.stream = load(songs[3])
			audio_player.play()
			allow_action = true
			first_time = false
			Player.position = Vector2(350, 402)
			saved_scene = "res://Scenes/Bedroom.tscn"
			save_settings()
		"5":
			$".".visible = false
			audio_player.stream = load(songs[3])
			$Mirror/Ben/Ben_Sprite.change_state(MOVE)
			audio_player.play()
			allow_action = false
			first_time = false
			saved_scene = "res://Scenes/Bedroom.tscn"
			save_settings()

func _on_exit_body_entered(body):
	if player_in_area_door == true && door_closed == false:
		if body.has_method("Player"):
			save_settings()
			Transition.trans("res://Scenes/Corridor.tscn")

#WINDOW
func _on_wincdow_mouse_entered():
	if interacting == false && allow_action == true && (player_in_area == true || player_in_area_window):
		if window_closed == true:
			$WorldEnvironment/WindowClose/close_interact.visible = true
		else:
			$WorldEnvironment/WindowClose/close_interact.visible = false
			
			
func _on_wincdow_mouse_exited():
	if interacting == false && allow_action == true && (player_in_area == true || player_in_area_window):
		if window_closed == false:
			$WorldEnvironment/WindowClose/open_interact.visible = true
			
		else:
			$WorldEnvironment/WindowClose/open_interact.visible = false
#WINDOW
#MIRROR
func _on_mirror_2d_input_event(viewport, event, shape_idx):
	pass # Replace with function body.
func _on_mirror_2d_body_entered(body):
	if body.has_method("Player"):
		player_in_area_mirror = true
func _on_mirror_2d_body_exited(body):
	if body.has_method("Player"):
		player_in_area_mirror = false
func _on_mirror_2d_mouse_entered():
	if interacting == false && allow_action == true && player_in_area == true || player_in_area_mirror:
		$WorldEnvironment/Mirror/Mirror2.visible = true
func _on_mirror_2d_mouse_exited():
	if interacting == false && allow_action == true && player_in_area == true || player_in_area_mirror:
		$WorldEnvironment/Mirror/Mirror2.visible = false
#MIRROR
#SWITCH
func _on_switch_area_mouse_entered():
	if interacting == false && allow_action == true && player_in_area == true || player_in_area_light:
		if switch_on == true:
			$WorldEnvironment/SwitchOn/onswitch.visible = true
		else:
			$WorldEnvironment/SwitchOn/offswitch.visible = true
func _on_switch_area_mouse_exited():
	if interacting == false && allow_action == true && player_in_area == true || player_in_area_light:
		if switch_on == false:
			$WorldEnvironment/SwitchOn/offswitch.visible = false
		else:
			$WorldEnvironment/SwitchOn/onswitch.visible = false
#SWITCH
#DOOR
func _on_door_area_mouse_entered():
	if interacting == false && allow_action == true && player_in_area == true || player_in_area_door:
		if door_closed == true:
			$WorldEnvironment/DoorClose/closedoor.visible = true
		else:
			$WorldEnvironment/DoorClose/opendoor.visible = true
func _on_door_area_mouse_exited():
	if interacting == false && allow_action == true && player_in_area == true || player_in_area_door:
		if door_closed == false:
			$WorldEnvironment/DoorClose/opendoor.visible = false
		else:
			$WorldEnvironment/DoorClose/closedoor.visible = false
#DOOR
#PLUSH
func _on_plush_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ui_leftMouseClick"):
		run_dialogue("Plush")
func _on_plush_body_entered(body):
	if body.has_method("Players"):
		player_in_area_plush = true
func _on_plush_body_exited(body):
	if body.has_method("Players"):
		player_in_area_plush = false
func _on_plush_mouse_entered():
	if interacting == false && allow_action == true && player_in_area == true || player_in_area_plush:
		$WorldEnvironment/Drawer/plush.visible = true
	else: 
		$WorldEnvironment/Drawer/plush.visible = false
func _on_plush_mouse_exited():
	if interacting == false && allow_action == true && player_in_area == true || player_in_area_plush:
		$WorldEnvironment/Drawer/plush.visible = false
	else:
		$WorldEnvironment/Drawer/plush.visible = false
#PLUSH
#BED
func _on_bed_mouse_entered():
	if allow_action == true && player_in_area == true || player_in_area_bed:
		$WorldEnvironment/Bed/Bed2.visible = true
	else:
		print(allow_action)
		print(player_in_area)
		print(player_in_area_bed)
func _on_bed_mouse_exited():
	if allow_action == true && player_in_area == true || player_in_area_bed:
		$WorldEnvironment/Bed/Bed2.visible = false
#BED
#CLOCK
func _on_clock_input_event(viewport, event, shape_idx):
	pass # Replace with function body.
func _on_clock_mouse_entered():
	if allow_action == true:
		$WorldEnvironment/Walls/Clock2.visible = true
func _on_clock_mouse_exited():
	if allow_action == true:
		$WorldEnvironment/Walls/Clock2.visible = false
#CLOCK

func sleep():
	$Sleeping.visible = true
	$Sleeping/AnimationPlayer.play("sleeping")
	await $Sleeping/AnimationPlayer.animation_finished
	$Sleeping.visible = false
