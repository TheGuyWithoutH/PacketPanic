extends PanelContainer

class_name Modal

@export var panel_text: PackedStringArray

@onready var index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/VBoxContainer/prompteur.text = panel_text[0]


func _on_next_pressed():
	index += 1
	$MarginContainer/VBoxContainer/HBoxContainer/previous.disabled = false
	if (index >= panel_text.size()-1):
		index = panel_text.size()-1
		$MarginContainer/VBoxContainer/HBoxContainer/next.disabled = true
	$MarginContainer/VBoxContainer/prompteur.text = panel_text[index]


func _on_previous_pressed():
	index -= 1
	$MarginContainer/VBoxContainer/HBoxContainer/next.disabled = false
	if (index <= 0):
		index = 0
		$MarginContainer/VBoxContainer/HBoxContainer/previous.disabled = true
	$MarginContainer/VBoxContainer/prompteur.text = panel_text[index]


func _on_close_pressed():
	pass
