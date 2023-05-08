extends ColorRect

@onready var levelList = [get_node("Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel"),
						get_node("Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel2"),
						get_node("Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel3")]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_close_pressed():
	self.position = Vector2(1000,1000)
