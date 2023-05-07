extends ReferenceRect

const Packet = preload("res://network/Packet.tscn")

var cmdindex = 0;
var sipreg = RegEx.new()
var dipreg = RegEx.new()
var cmdlist = 'res://resources/cmdlist.txt'
var entryarray = ["end of commands array"]
var level: BasicLevel
var currentPacket: Packet
var lastHistory: Array

# Right now for default scene, when menu is done use setLevel instead
@export var levelScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	dipreg.compile("set_dest_IP\\((([0-9]{1,3}\\.){3}[0-9]{1,3})\\)")
	sipreg.compile("set_src_IP\\((([0-9]{1,3}\\.){3}[0-9]{1,3})\\)")
	$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = "> "
	$ColorRect/HBoxContainer/User_Input_Panel/TermInput.caret_column = 2
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeval.text = "%d" % $ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.value
	level = levelScene.instantiate()
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/GameBoard/SubViewportContainer/LevelView.add_child(level)
	level.endLevel.connect(endLevel)
	currentPacket = Packet.instantiate()

func setLevel(newLevel: PackedScene):
	level = newLevel.instantiate()
	level.endLevel.connect(endLevel)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
			
func _on_LineEdit_text_entered(new_text):
	if new_text.length() > 2:
		entryarray.append(new_text)
		cmdindex = entryarray.size()
		
		$ColorRect/HBoxContainer/User_Input_Panel/TermInput.clear()
		$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = "> "
		$ColorRect/HBoxContainer/User_Input_Panel/TermInput.caret_column = 2
		
		var cmd_idx = is_command(new_text)
		if cmd_idx == null:
			$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += "\n" + new_text
			$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += "\nCommand not found : %s " % new_text.substr(2).split(" ")[0]
		else :
			$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += "\n" + new_text
			$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += terminal_exec(cmd_idx,new_text)
		
		var dip = dipreg.search(new_text) # search for destination ip address
		if dip:
			$ColorRect/HBoxContainer/Game_Window/NetWork_Window/GameBoard/SubViewportContainer/SubViewport/BasicLevel.packet.setDestination('185.25.195.105')
			print("set dest")
		var sip = sipreg.search(new_text)
		if sip:
			$ColorRect/HBoxContainer/User_Input_Panel/Packet2.packet.src_ip = sip.get_string(1)
			$ColorRect/HBoxContainer/User_Input_Panel/Packet2.print_packet()

func _on_timeslider_value_changed(value):
	if(lastHistory.size() > 0):
		var index = floor((lastHistory.size() - 1) * value / 100)
		var linkSize = 100 / (lastHistory.size() - 1)
		$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeval.text = "%d" % index
		
		if(index == lastHistory.size() - 1):
			currentPacket.position = lastHistory[index]
		else:
			currentPacket.position = lastHistory[index].lerp(lastHistory[index + 1], (value - (index * linkSize)) / linkSize)


func _on_Start_Button_pressed():
	print("start")
	lastHistory.clear()
	currentPacket.setDestination('185.25.195.105')
	currentPacket.setMac('5E:FF:56:A2:AF:03')
	currentPacket.setPort(80)
	level.startLevel(currentPacket)
	
func is_command(cmd):
	cmd += " "
	var f = FileAccess.open(cmdlist, FileAccess.READ)
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
		"netcat":
			return "\nYou're a kitty ! : " + arg
		_: 
			return "\ncaught " + cmd + " with arguments : " + arg
	
func endLevel(success: bool, error: String, history: Array):
	print('end: ' + error)
	lastHistory = history
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.tick_count = lastHistory.size()
	pass
