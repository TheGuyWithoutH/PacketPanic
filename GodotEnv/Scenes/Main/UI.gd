extends ReferenceRect

const Packet = preload("res://network/Packet.tscn")
const lvlbar = preload("res://assets/GUI_Boxes/LevelBar.gd")

var cmdindex = 0;
var func_reg = RegEx.new()
var command_reg = RegEx.new()
var cmdlist = 'res://resources/cmdlist.txt'
var functlist = 'res://resources/funct_list.txt'
var entryarray = ["end of commands array"]
var level: BasicLevel
var levelbar: LevelBar
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
	$Packet_Success.position = Vector2(1000,1000)
	get_node("Levelselector/Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel").lvlselected.connect(_on_lvl_selected)
	get_node("Levelselector/Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel2").lvlselected.connect(_on_lvl_selected)
	get_node("Levelselector/Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel3").lvlselected.connect(_on_lvl_selected)
	setLevel(load("res://Scenes/Levels/level1/Level1.tscn"))
	#init packet
	currentPacket.setDestination("0.0.0.0")
	currentPacket.setSource("1.1.1.1")
	currentPacket.setMac("de:ad:be:ef:00:7d")
	currentPacket.encryptMessage(0)
	currentPacket.errstr.connect(_on_input_err)
	
	
func _on_lvl_selected(levelscn: PackedScene,cur_bar: LevelBar):
	levelbar = cur_bar
	print_packet_info()
	setLevel(levelscn)
	print("selected level : "+ str(levelscn))
	$Levelselector.position = Vector2(1000,1000)

func setLevel(newLevel: PackedScene):
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/GameBoard/SubViewportContainer/LevelView.remove_child(level)
	level = newLevel.instantiate()
	level.endLevel.connect(endLevel)
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/GameBoard/SubViewportContainer/LevelView.add_child(level)

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

func _on_input_err(errtext:String) -> void:
	$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += "\n" + errtext
			
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
			if is_from(funct_name,functlist):
				$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += terminal_exec(funct_name,args)
				print_packet_info()
			else:
				print("error : function \"" + funct_name + "\" not found.")
				$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += "\nstd_err : Undefined reference to \"" + funct_name + "\" 0x44."
		elif cmd_command:
			var prog_name = cmd_command.get_string(1)
			var args = cmd_command.get_string(2)
			print("found command "+ prog_name)
			if is_from(prog_name,"res://resources/cmdlist.txt"):
				$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += terminal_exec(prog_name,args)
				print_packet_info()
			else:
				print("error : command \"" + prog_name + "\" not found.")
				$ColorRect/HBoxContainer/User_Input_Panel/Terminal.text += "\n\"" + prog_name + "\" is not recognized, try \"help\"."
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
		$Packet_Success.position = Vector2(363,210)
		$Packet_Success/MarginContainer/VBoxContainer/RichTextLabel.text = "The Packet arrived safely at " + str(currentPacket.dst_addr.ip_address)
		#levelbar._done(true)
	else:
		$Packet_Panic.position = Vector2(363,210)
		$Packet_Panic/MarginContainer/VBoxContainer/RichTextLabel.text = error
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
			currentPacket.setHTTPMethod(str_to_var(arg))
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
		"help":
			var help = "\nAvailable commands :\n"
			var f = FileAccess.open(functlist, FileAccess.READ)
			while not f.eof_reached(): # iterate through all lines until the end of file is reached
				var line = f.get_line()
				help += "- " + line + "\n"
			f.close()
			return help
		_: 
			return "\n" + cmd + "not implemented ," + arg
	
func print_packet_info():
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text =  "############\n"
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "PACKET STATE\n"
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "############"
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nsrc_ip : " + str(currentPacket.src_addr.ip_address)
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\ndest_ip : " + str(currentPacket.dst_addr.ip_address)
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nport : " + str(currentPacket.port)
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nmac_addr : " + str(currentPacket.mac_addr.mac_address)
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nHTTP_meth : " + str(currentPacket.http_method)
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nencryption : " + str(currentPacket.encryption)
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\n############"
	

