extends ReferenceRect

const Packet = preload("res://network/Packet.tscn")

var cmdindex = 0;
var func_reg = RegEx.new()
var command_reg = RegEx.new()
var cmdlist = 'res://resources/cmdlist.txt'
var entryarray = ["end of commands array"]
var level: BasicLevel
var currentPacket: Packet
var lastHistory: Array

# Right now for default scene, when menu is done use setLevel instead
@export var levelScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	func_reg.compile("(\\w+)\\((.*)\\)")
	command_reg.compile("(\\w+) *(.*)")
	$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = "> "
	$ColorRect/HBoxContainer/User_Input_Panel/TermInput.caret_column = 2
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeval.text = "%d" % $ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.value
	level = levelScene.instantiate()
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/GameBoard/SubViewportContainer/LevelView.add_child(level)
	level.endLevel.connect(endLevel)
	currentPacket = Packet.instantiate()
	$Levelselector.position = Vector2(113,49)
	$Packet_Panic.position = Vector2(1000,1000)
	get_node("Levelselector/Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel").lvlselected.connect(_on_lvl_selected)
	get_node("Levelselector/Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel2").lvlselected.connect(_on_lvl_selected)
	get_node("Levelselector/Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel3").lvlselected.connect(_on_lvl_selected)
	setLevel(load("res://Scenes/Levels/level1/Level1.tscn"))
	
func _on_lvl_selected(levelscn: PackedScene):
	setLevel(levelscn)
	print("selected level : "+ str(levelscn))

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
		$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += "\n" + new_text
		$ColorRect/HBoxContainer/User_Input_Panel/TermInput.clear()
		$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = "> "
		$ColorRect/HBoxContainer/User_Input_Panel/TermInput.caret_column = 2
		new_text = new_text.substr(2)
		var cmd_funct = func_reg.search(new_text)
		var cmd_command = command_reg.search(new_text)
		if cmd_funct:
			var funct_name = cmd_funct.get_string(1)
			var args = cmd_funct.get_string(2)
			print("found funct "+ funct_name + " with arg : " + args)
			if is_from(funct_name,"res://resources/funct_list.txt"):
				$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += terminal_exec(funct_name,args)
			else:
				print("error : program \"" + funct_name + "\" not found.")
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
	
func is_from(word,file):
	var f = FileAccess.open(file, FileAccess.READ)
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		if line == word:
			f.close()
			return true
	f.close()
	return false

	
func endLevel(success: bool, error: String, history: Array):
	print('end: ' + error)
	lastHistory = history
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.tick_count = lastHistory.size()
	if(success):
		print("yaaaaay")
	else:
		$Packet_Panic.position = Vector2(578,327)
		$Packet_Panic/MarginContainer/VBoxContainer/RichTextLabel.text = "error : "+ error
	pass


func _on_button_levelselector():
	$Levelselector.position = Vector2(113,49)
	
	
func terminal_exec(cmd,arg):
	match cmd:
		"netcat":
			return "\nYou're a kitty ! : " + arg
		"set_src_ip":
			currentPacket.setSource(arg)
			return " "
		"set_dest_ip":
			currentPacket.setDestination(arg)
			return " "
		"set_port":
			currentPacket.setPort(str_to_var(arg))
			return " "
		"dns_addr":
			print("dns adress not implemented")
			return " "
		"HTTP_method":
			currentPacket.setHTTPMethod(arg)
			return " "
		"mac_addr":
			currentPacket.setMac(arg)
			return " "
		"use_vpn":
			currentPacket.setVPN(arg)
			return " "
		"encrypt":
			currentPacket.encryption = arg
			return " "
		_: 
			return "\n" + cmd + "not implemented ," + arg
	print_packet_info()
	
func print_packet_info():
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text = "Packet :"
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nsrc_ip :" + currentPacket.src_addr
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\ndest_ip :" + currentPacket.dst_addr
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nport :" + str(currentPacket.port)
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nmac_addr :" + str(currentPacket.mac_addr)
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nHTTP_meth :" + str(currentPacket.http_method)
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nencryption :" + currentPacket.encryption
	

