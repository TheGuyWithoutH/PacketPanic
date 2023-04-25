extends ReferenceRect

var cmdindex = 0;
var sipreg = RegEx.new()
var dipreg = RegEx.new()
var cmdlist = 'res://resources/cmdlist.txt'
var entryarray = ["end of commands array"]
# Called when the node enters the scene tree for the first time.
func _ready():
	dipreg.compile("set_dest_IP\\((([0-9]{1,3}\\.){3}[0-9]{1,3})\\)")
	sipreg.compile("set_src_IP\\((([0-9]{1,3}\\.){3}[0-9]{1,3})\\)")
	$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = "> "
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text = "PACKET:"
	$ColorRect/HBoxContainer/User_Input_Panel/TermInput.caret_position = 2
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeval.text = "%d" % $ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.value

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventKey and event.pressed:
		if $ColorRect/HBoxContainer/User_Input_Panel/Terminal.text.split("\n").size() != 1:
			if event.scancode == KEY_UP:
				$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = entryarray[cmdindex-1]
				$ColorRect/HBoxContainer/User_Input_Panel/TermInput.caret_position = -1
				cmdindex -= 1
				if cmdindex < 2 : cmdindex = 2;
			if event.scancode == KEY_DOWN:
				$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = entryarray[cmdindex-1]
				$ColorRect/HBoxContainer/User_Input_Panel/TermInput.caret_position = -1
				cmdindex += 1
				if cmdindex > entryarray.size():
					cmdindex = entryarray.size()
					$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = "> "
			
func _on_LineEdit_text_entered(new_text):
	if new_text.length() > 2:
		entryarray.append(new_text)
		cmdindex = entryarray.size()
		
		$ColorRect/HBoxContainer/User_Input_Panel/TermInput.clear()
		$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = "> "
		$ColorRect/HBoxContainer/User_Input_Panel/TermInput.caret_position = 2
		
		var cmd_idx = is_command(new_text)
		if cmd_idx == null:
			$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += "\n" + new_text
			$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += "\nCommand not found : %s " % new_text.substr(2).split(" ")[0]
		else :
			$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += "\n" + new_text
			$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += terminal_exec(cmd_idx,new_text)
		
		var dip = dipreg.search(new_text)
		if dip:
			$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nDest IP : " + dip.get_string(1)
		var sip = sipreg.search(new_text)
		if sip:
			$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nSource IP : " + sip.get_string(1)

func _on_timeslider_value_changed(value):
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeval.text = "%d" % value


func _on_Button_pressed():
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/PanelContainer/DEBUG.text = $ColorRect/HBoxContainer/User_Input_Panel/Packet2.text
	
func is_command(cmd):
	cmd += " "
	var f = File.new()
	f.open(cmdlist, File.READ)
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		if line + " " == cmd.substr(2,line.length()+1):
			f.close()
			return line
	f.close()
	return null
	
func terminal_exec(cmd,arg):
	arg = arg.substr(arg.find(cmd) + cmd.length()+1)
	match cmd:
		"cat":
			return "\nYou're a kitty !"
		_: 
			return "\ncaught " + cmd + " with arguments : " + arg
	
