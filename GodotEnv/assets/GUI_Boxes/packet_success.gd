extends Panel

signal closed_error
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_button_pressed():
	self.position = Vector2(1000,1000)
	closed_error.emit()
