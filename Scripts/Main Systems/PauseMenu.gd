extends Control

func _unhandled_input(event):
	$CenterContainer/VBoxContainer/ResumeButton.grab_focus()
	if event.is_action_pressed("ESC"):
		self.is_paused = !is_paused

var is_paused = false:
	set(value):
		is_paused = value
		get_tree().paused = is_paused
		visible = is_paused

func _on_resume_button_pressed():
	self.is_paused = false


func _on_menu_pressed(): 
	Dialogic.end_timeline()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_quit_button_pressed():
	get_tree().quit()

