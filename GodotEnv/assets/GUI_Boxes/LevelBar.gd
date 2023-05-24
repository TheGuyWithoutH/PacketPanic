extends Panel

class_name LevelBar

@export var levelname: String
@export var levelscn: PackedScene
@export var lvlimgpath: CompressedTexture2D

signal lvlselected(lvlscn,cur_bar)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("HBoxContainer/Label").text = levelname
	get_node("HBoxContainer/TextureRect").texture = lvlimgpath
	pass # Replace with function body.

func _on_button_pressed():
	print(levelname + " pressed !")
	print(levelscn)
	lvlselected.emit(levelscn,self)

func _done(lvlok:bool):
	$HBoxContainer/CheckButton.set_pressed_no_signal(lvlok)
