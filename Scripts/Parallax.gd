extends CharacterBody2D

var start_chase = false

func _ready():
	pass

func _physics_process(delta): 
	if start_chase == true:
		velocity = Vector2(150 * 0.5, 0)
		move_and_slide()
	
func start(dec):
	start_chase = dec
	
