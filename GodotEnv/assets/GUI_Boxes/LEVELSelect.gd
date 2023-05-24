extends ColorRect

func _ready():
	pass # Replace with function body.

func _on_close_pressed():
	self.position = Vector2(1000,1000)
	self.get_parent().get_node("Darken").hide()
