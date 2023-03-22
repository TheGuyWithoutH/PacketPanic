extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var g_success = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Opening: startbutton ready.")

func _pressed():
	print("start button pressed !")
	g_success = get_tree().change_scene("res://Scenes/Main.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
