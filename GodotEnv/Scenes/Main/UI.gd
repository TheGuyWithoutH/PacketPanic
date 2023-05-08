extends ReferenceRect

var cmdindex = 0;
var func_reg = RegEx.new()
var command_reg = RegEx.new()
var cmdlist = 'res://resources/cmdlist.txt'
var entryarray = ["end of commands array"]
# Called when the node enters the scene tree for the first time.
func _ready():
	func_reg.compile("(\\w+)\\((.*)\\)")
	command_reg.compile("(\\w+) (.*)")
	$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = "> "
	$ColorRect/HBoxContainer/User_Input_Panel/TermInput.caret_column = 2
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeval.text = "%d" % $ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.value


func _on_LineEdit_text_entered(new_text):
	if new_text.length() > 2:
		entryarray.append(new_text)
		cmdindex = entryarray.size()
		$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += "\n" + new_text
		$ColorRect/HBoxContainer/User_Input_Panel/TermInput.clear()
		$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = "> "
		$ColorRect/HBoxContainer/User_Input_Panel/TermInput.caret_column = 2
		new_text = new_text.substr(2)
		var cmd_funct = func_reg.search(new_text)
		var cmd_command = command_reg.search(new_text)
		if cmd_funct:
			print("found funct "+ cmd_funct.get_string(1) + " with arg : " + cmd_funct.get_string(2))
		elif cmd_command:
			var prog_name = cmd_command.get_string(1)
			var args = cmd_command.get_string(2)
			print("found command "+ prog_name)
			if is_from(prog_name,"res://resources/cmdlist.txt"):
				$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += terminal_exec(prog_name,args)
			else:
				print("error : program \"" + prog_name + "\" not found.")
		else :
			print("error : \"" + new_text + "\" not recognized.")
			
func _on_timeslider_value_changed(value):
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeval.text = "%d" % value

func _input(event):
	if event is InputEventKey and event.pressed:
		if $ColorRect/HBoxContainer/User_Input_Panel/Terminal.text.split("\n").size() != 1:
			if event.keycode == KEY_UP:
				$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = entryarray[cmdindex-1]
				$ColorRect/HBoxContainer/User_Input_Panel/TermInput.caret_column = -1
				cmdindex -= 1
				if cmdindex < 2 : cmdindex = 2;
			if event.keycode == KEY_DOWN:
				$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = entryarray[cmdindex-1]
				$ColorRect/HBoxContainer/User_Input_Panel/TermInput.caret_column = -1
				cmdindex += 1
				if cmdindex > entryarray.size():
					cmdindex = entryarray.size()
					$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = "> "
			

func _on_Button_pressed():
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/GameBoard/SubViewportContainer/SubViewport/BasicLevel.start()
	
func is_from(word,file):
	var f = FileAccess.open(file, FileAccess.READ)
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		if line == word:
			f.close()
			return true
	f.close()
	return false
	
func terminal_exec(cmd,arg):
	match cmd:
		"netcat":
			return "\nYou're a kitty ! : " + arg
		_: 
			return "\ncaught " + cmd + " with arguments : " + arg
	
