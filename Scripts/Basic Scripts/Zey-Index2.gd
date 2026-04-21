extends Node2D

@export var low_index : int
@export var high_index : int

@export var y_threshold : float

@export var x_threshold : float

@onready var Ben : CharacterBody2D = $"../../Ben"

var door_closed

func _physics_process(delta):
	if door_closed == false:
		if(Ben.position.y > y_threshold):
			self.set_z_index(low_index)
		if(Ben.position.y < y_threshold):
			self.set_z_index(high_index)
		else:
			pass
	else: 
		self.set_z_index(low_index)
		
		
func door_is_closed(check):
	door_closed = check
