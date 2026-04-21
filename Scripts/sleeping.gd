extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Dialogic.VAR.Bedroom.switchOn == true: 
		$".".texture = ResourceLoader.load("res://Characters/Ben/Sprites/ben sleep openL.png")
	else:
		$".".texture = ResourceLoader.load("res://Characters/Ben/Sprites/ben sleep openD.png")
