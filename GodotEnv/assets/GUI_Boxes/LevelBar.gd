extends Panel

@export var levelname: String
@export var leveljson: JSON

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("HBoxContainer/Label").text = levelname
	pass # Replace with function body.


func _on_button_pressed():
	print(levelname + " pressed !")
