extends CharacterBody2D

@onready var PlayerSprite : AnimatedSprite2D = $Ben_Sprite
var destination = Vector2()
var distance = Vector2()

@export var speed = 250


enum { IDLE, MOVE }

var map
var region
var navigation_poly
var path = []

var state = IDLE

func _ready():
	destination = position
	
func _physics_process(delta):
	var walk_distance = speed * delta
	
				
func move_here(location: Vector2):
	print(location)
	var last_point = self.position
	if(location.x > position.x):
		get_node("Ben_Sprite").set_flip_h(false)
	if(location.x < position.x):
		get_node("Ben_Sprite").set_flip_h(true)		
	
	if position != location:
		distance = Vector2(location - position)	
		velocity.x = distance.normalized().x * speed
		velocity.y = distance.normalized().y * speed
		move_and_slide()
		print(position)

func chara_global_position():
	return position

func navigator_path():
	for i in path:
		return i

func final_point_path():
	return destination
	

	
