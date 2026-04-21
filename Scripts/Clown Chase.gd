extends Node2D

@onready var Player : CharacterBody2D = $ParallaxBackground/Ben
@onready var PlayerSprite : AnimatedSprite2D = $ParallaxBackground/Ben/Ben_Sprite
@onready var Clown : CharacterBody2D = $ParallaxBackground/Clown
@onready var ClownSprite : AnimatedSprite2D =$ParallaxBackground/Clown/ClownSprite
@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var IntroClown : CharacterBody2D = $Intro/Clown
@onready var IntroPlayer : CharacterBody2D = $Intro/Ben
@onready var CSpriteIntro : AnimatedSprite2D =$Intro/Clown/ClownSprite
@onready var PSpriteIntro : AnimatedSprite2D = $Intro/Ben/Ben_Sprite
#Saving\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
var _save_path = "res://User/Data/Scenes.save"
var first_time
var saved_scene
var chapter
var file : FileAccess
var action
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

var songs = ["res://Sound/BGM/MENU THEME.mp3", "res://Sound/BGM/REALITY THEME.mp3", "res://Sound/BGM/DREAM THEME.mp3", "res://Sound/BGM/CHASE.mp3"]
enum { IDLE, MOVE, RUN }
var scene = "res://Scenes/clown_chase.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	Dialogic.VAR.reset()
	get_save()
	$Intro.visible = false
	$Hid.visible = false
	$Fade.visible = false
	$Running.visible = false
	action = false
	sceneConfigs(chapter)
	
	Dialogic.signal_event.connect(DialogicSignal)

func sceneConfigs(Chapter):
	match Chapter:
		"3":
			PSpriteIntro.change_state(RUN)
			CSpriteIntro.change_state(MOVE)
			$Intro.visible = true
			audio_player.stream = load(songs[3])
			audio_player.play()
			await cutscnene()
			
			$Fade.visible = true
			$Fade/AnimationPlayer.play("fade_in")
			await $Fade/AnimationPlayer.animation_finished
			$Fade/AnimationPlayer.play("fade_out")
			$Intro.visible = false
			$Fade.visible = false
			main_scene()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if chapter == "3" && saved_scene == "res://Scenes/Corridor.tscn":
		first_time = false
		chapter = "3"
		saved_scene = scene
		save_settings()
	if $Intro.visible == false:
		PlayerSprite.change_state(RUN)
		ClownSprite.change_state(MOVE)
	
	if action == true:
		if Dialogic.VAR.Corridor.Hiding == true:
			$AudioStreamPlayer2D2.play()
			DialogicSignal("hid")
		if Dialogic.VAR.Corridor.Running == true:
			DialogicSignal("run")
		
func main_scene():	
	action = true
	Player.start(true)
	Clown.start(true)
	run_dialogue("clownchase")	
	Dialogic.end_timeline()
func cutscnene():
	$Intro/AnimationPlayer.play("on_screen")
	await $Intro/AnimationPlayer.animation_finished

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
	if arg == "hid":
		$Hid/Ben/Ben_Sprite.change_state(MOVE)
		$Hid/Clown/ClownSprite.change_state(MOVE)
		action = false
		print("received")
		Player.start(false)
		Clown.start(false)
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		$Fade/AnimationPlayer.play("fade_out")
		$AudioStreamPlayer2D.stop()
		$Hid.visible = true
		$Fade.visible = false
		$Hid/AnimationPlayer.play("Intrance")
		await $Hid/AnimationPlayer.animation_finished
		$Hid/Ben/Ben_Sprite.change_state(IDLE)
		$Hid/Ben/Ben_Sprite.set_flip_h(true)
		run_dialogue("hiding")
	if arg == "hid_continue":
		$ParallaxBackground.visible = false
		$Hid/Ben/Ben_Sprite.change_state(MOVE)
		$Hid/Clown/ClownSprite.change_state(MOVE)
		$Hid/AnimationPlayer.play("getting_inside")
		await $Hid/AnimationPlayer.animation_finished
		$Hid.visible = false
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		$HidingInside.visible = false
		$Fade.visible = false
		save_settings()
		ChapTransition.trans("res://Scenes/cutscenes.tscn")
	if arg == "run":
		$ParallaxBackground.visible = false
		action = false
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		$Fade/AnimationPlayer.play("fade_out")
		$Running/Ben/Ben_Sprite.change_state(MOVE)
		$RunAway/Clown/ClownSprite.change_state(MOVE)
		$RunAway/Ben/Ben_Sprite.change_state(RUN)
		$Fade.visible = false
		$RunAway.visible = true
		$RunAway/AnimationPlayer.play("getting_out")
		await $RunAway/AnimationPlayer.animation_finished
		$RunAway.visible = false
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		$Fade/AnimationPlayer.play("fade_out")
		$Fade.visible = false
		$Running.visible = true
		$Running/AnimationPlayer.play("safe")
		await $Running/AnimationPlayer.animation_finished
		$Running/Ben/Ben_Sprite.change_state(IDLE)
		$Running/Ben/Ben_Sprite.set_flip_h(true)
		run_dialogue("safe")
	if arg == "go_back":
		$Fade.visible = true
		$Fade/AnimationPlayer.play("fade_in")
		await $Fade/AnimationPlayer.animation_finished
		first_time = false
		chapter = "3"
		saved_scene = "res://Scenes/clown_chase.tscn"
		save_settings()
		ChapTransition.trans("res://Scenes/Corridor.tscn")
