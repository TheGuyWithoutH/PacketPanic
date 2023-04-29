extends RichTextLabel

func _ready():
	var f = File.new()
	f.open("res://resources/documentation.txt", File.READ)
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		self.bbcode_text += line + "\n"
	f.close()
