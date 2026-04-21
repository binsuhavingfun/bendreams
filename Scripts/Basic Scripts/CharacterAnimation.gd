extends AnimatedSprite2D

var state;

enum{IDLE, MOVE, RUN}
 
func _ready():
	state = IDLE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_state(newState):
	state = newState
	match state: 
		IDLE:
			self.play("idle")
		MOVE:
			self.play("move")
		RUN:
			self.play("run")
