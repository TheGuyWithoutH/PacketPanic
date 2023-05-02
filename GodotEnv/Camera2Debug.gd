extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_updateDirection()
	
	
func _updateDirection():
	if Input.is_action_pressed("move_left"):
		self.position.x -= 2
	if Input.is_action_pressed("move_right"):
		self.position.x += 2
	if Input.is_action_pressed("move_up"):
		self.position.y -= 2
	if Input.is_action_pressed("move_down"):
		self.position.y += 2
