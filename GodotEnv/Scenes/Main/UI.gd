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
var modal_window: Modal 

# Right now for default scene, when menu is done use setLevel instead
@export var levelScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	func_reg.compile("(\\w+)\\((.*)\\)")
	command_reg.compile("(\\w+) *(.*)")
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.editable = false
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.tick_count = 1
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.value = 0
	$ColorRect/HBoxContainer/User_Input_Panel/TermInput.text = "> "
	$ColorRect/HBoxContainer/User_Input_Panel/TermInput.caret_column = 2
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeval.text = "%d" % $ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.value
	$Modal.hide()
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/GameBoard/SubViewportContainer/LevelView.add_child(levelScene.instantiate())
	currentPacket = Packet.instantiate()
	$Levelselector.position = Vector2(113,49)
	$Packet_Panic.position = Vector2(1000,1000)
	$Packet_Success.position = Vector2(1000,1000)
	get_node("ColorRect/HBoxContainer/Game_Window/Documentation/Game/VBoxContainer/Music").set_pressed_no_signal(true)
	get_node("Levelselector/Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel").lvlselected.connect(_on_lvl_selected)
	get_node("Levelselector/Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel2").lvlselected.connect(_on_lvl_selected)
	get_node("Levelselector/Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel3").lvlselected.connect(_on_lvl_selected)
	get_node("Levelselector/Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel4").lvlselected.connect(_on_lvl_selected)
	get_node("Levelselector/Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel5").lvlselected.connect(_on_lvl_selected)
	get_node("Levelselector/Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel6").lvlselected.connect(_on_lvl_selected)
	get_node("Levelselector/Level_popup/VBoxContainer/MenuBar/VBoxContainer/Panel7").lvlselected.connect(_on_lvl_selected)
	get_node("ColorRect/HBoxContainer/Game_Window/Documentation/Game/VBoxContainer/Button").pressed.connect(_on_button_levelselector)
	get_node("ColorRect/HBoxContainer/Game_Window/Documentation/Game/VBoxContainer/Music").toggled.connect(_on_music_toggled)
	get_node("ColorRect/HBoxContainer/Game_Window/Documentation/Game/VBoxContainer/Quit_game").pressed.connect(_on_quit_game_pressed)
	
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
	$Levelselector.position = Vector2(1000,1000)

func setLevel(newLevel: PackedScene):
	if level:
		level.quitLevel(currentPacket)
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/GameBoard/SubViewportContainer/LevelView.remove_child(level)
	level = newLevel.instantiate()
	level.endLevel.connect(endLevel)
	level.startExplanation.connect(_on_start_explanations)
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
		new_text = new_text.substr(2) if new_text.contains("> ") else new_text
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
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.editable = false
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.tick_count = 1
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.value = 0
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

	
func endLevel(success: bool, error: String, history: Array, explanations: String):
	print('end: ' + error)
	lastHistory = history
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.editable = true
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.tick_count = lastHistory.size()
	$ColorRect/HBoxContainer/Game_Window/NetWork_Window/timeline/timecont/timeslider.value = 100
	if(success):
		$Packet_Success.position = Vector2(363,210)
		$Packet_Success/MarginContainer/VBoxContainer/RichTextLabel.parse_bbcode("The Packet arrived safely at " + str(currentPacket.dst_addr.ip_address) + ".\n\n" + str(explanations))
		levelbar._done(true)
		$VictorySound.play()
	else:
		$Packet_Panic.position = Vector2(363,210)
		$Packet_Panic/MarginContainer/VBoxContainer/RichTextLabel.text = error
		$ErrorSound.play()
	pass


func _on_button_levelselector():
	$Levelselector.position = Vector2(113,49)
	$Darken.show()
	
	
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
			currentPacket.setVPN(_getVpnFromString(arg))
			return " "
		"encrypt":
			currentPacket.encryptMessage(_getEncryptionFromString(arg))
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
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nport : " + (str(currentPacket.port) if currentPacket.port > -1 else "NONE")
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nmac_addr : " + str(currentPacket.mac_addr.mac_address)
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nHTTP_meth : " + str(Utils.HTTPMethod.keys()[currentPacket.http_method] if currentPacket.http_method > -1 else "NONE")
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nencryption : " + str(Utils.Encryption.keys()[currentPacket.encryption])
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\nvpn_preference : " + str(Utils.VPNs.keys()[currentPacket.vpn])
	$ColorRect/HBoxContainer/User_Input_Panel/Packet2.text += "\n############"
	

func _on_start_explanations(explanations: Array[String]):
	$Modal.index = 0
	$Modal/MarginContainer/VBoxContainer/HBoxContainer/next.disabled = false
	$Modal/MarginContainer/VBoxContainer/HBoxContainer/previous.disabled = true
	$Modal.panel_text = explanations
	$Modal/MarginContainer/VBoxContainer/prompteur.text = explanations[0]
	$Modal.show()
	$Darken.show()

func _getVpnFromString(input: String):
	match input.to_lower():
		"europe":
			return Utils.VPNs.EUROPE
		"africa":
			return Utils.VPNs.AFRICA
		"asia":
			return Utils.VPNs.ASIA
		"oceania":
			return Utils.VPNs.OCEANIA
		"north america":
			return Utils.VPNs.NORTH_AMERICA
		"south america":
			return Utils.VPNs.SOUTH_AMERICA

func _getEncryptionFromString(input: String):
	match input.to_lower():
		"none":
			return Utils.Encryption.NONE
		"vigenere":
			return Utils.Encryption.VIGENERE
		"aes":
			return Utils.Encryption.AES
		"post quantum":
			return Utils.Encryption.POST_QUANTUM

func _clickOnTerminalFocusesInput(event: InputEvent):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		$ColorRect/HBoxContainer/User_Input_Panel/TermInput.grab_focus()

func _on_term_input_text_changed(new_text):
	$keystroke.play(1)

func _on_quit_game_pressed():
	get_tree().quit(0)
	
func _on_music_toggled(on):
	if (on):
		$Music.play()
	else:
		$Music.stop()
	
