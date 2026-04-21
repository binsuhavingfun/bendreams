extends CharacterBody2D

@onready var PlayerSprite : AnimatedSprite2D = $Ben_Sprite
@onready var nav : NavigationAgent2D = $NavigationAgent2D
@onready var nav2D : NavigationRegion2D = $"../NavigationRegion2D"
@onready var line : Line2D = $"../Line2D"
@onready var scene : Control 

var destination = Vector2()
var distance = Vector2()

@export var speed = 250

var allowed_to_move = false
var can_chat = false
var show_line = true

enum { IDLE, MOVE }

var map
var region
var navigation_poly
var path = []

var state = IDLE

func _ready():
	destination = position
	call_deferred("setup_navserver")
	
func _input(event):
	if Input.is_action_pressed("ui_leftMouseClick"):
		if allowed_to_move == true && show_line == true:
			_update_navigation_path(self.position, get_global_mouse_position())
			var clicked_destination = get_global_mouse_position()
			destination = clicked_destination
			state = MOVE
		else: 
			pass
	elif Input.is_action_just_released("ui_leftMouseClick"):
		state = IDLE
		line.clear_points()
	
	
func setup_navserver():
	map = NavigationServer2D.map_create()
	NavigationServer2D.map_set_active(map, true)
	
	var region = NavigationServer2D.region_create()
	NavigationServer2D.region_set_transform(region, Transform2D())
	NavigationServer2D.region_set_map(region, map)
	
	var navigation_poly = NavigationMesh.new()
	navigation_poly = $"../NavigationRegion2D".navigation_polygon
	NavigationServer2D.region_set_navigation_polygon(region, navigation_poly)
	
func set_up():
	call_deferred("setup_navserver")
	
func _update_navigation_path(start_position, end_position):
	path = NavigationServer2D.map_get_path(map,start_position, end_position, true)
	destination = end_position
	destination = nav.get_final_position()
	
	line.clear_points()
	for i in path:
		line.add_point(i)
	
	path.remove_at(0)
	set_process(true)
	
func _physics_process(delta):
	var walk_distance = speed * delta
	match state:
		IDLE:
			PlayerSprite.change_state(IDLE)
		MOVE:
			if allowed_to_move == true && can_chat == false:
				PlayerSprite.change_state(MOVE)
				move_along_path(walk_distance)
			else: 
				pass
				
func move_here(location: Vector2):
	var last_point = self.position
	if(location.x > position.x):
		get_node("Ben_Sprite").set_flip_h(false)
	if(location.x < position.x):
		get_node("Ben_Sprite").set_flip_h(true)		
	while path.size():
		var distance_between_points = last_point.distance_to(path[0])
		if distance <= distance_between_points:
			PlayerSprite.change_state(MOVE)
			self.position = last_point.lerp(path[0], distance / distance_between_points)
			return
		
		distance -= distance_between_points
		last_point = path[0]
		path.remove_at(0)
	self.position = last_point
	set_process(false)
	
func move_along_path(distance):
	var last_point = self.position
	if(destination.x > position.x):
		get_node("Ben_Sprite").set_flip_h(false)
	if(destination.x < position.x):
		get_node("Ben_Sprite").set_flip_h(true)		
	while path.size():
		var distance_between_points = last_point.distance_to(path[0])
		if distance <= distance_between_points:
			self.position = last_point.lerp(path[0], distance / distance_between_points)
			return
		
		distance -= distance_between_points
		last_point = path[0]
		path.remove_at(0)
	self.position = last_point
	set_process(false)

func chara_global_position():
	return position

func navigator_path():
	for i in path:
		return i

func final_point_path():
	return destination
	
func should_move(move):
	allowed_to_move = move
	can_chat = !can_chat

func is_chatting(chat):
	can_chat = chat

func line_show(show):	
	show_line = show
	
func Player():
	pass
