extends Node2D

@export var low_index : int
@export var high_index : int

@export var y_threshold : float

@export var x_threshold : float

@onready var Ben : CharacterBody2D = $"../../Ben"

func _physics_process(delta):
	if(Ben.position.y > y_threshold):
		self.set_z_index(low_index)
	elif(Ben.position.y < y_threshold):
		self.set_z_index(high_index)
	else:
		pass
