extends RichTextLabel

func _ready():
	var f = FileAccess.open("res://resources/documentation.txt", FileAccess.READ)
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		self.text += line + "\n"
	f.close()
