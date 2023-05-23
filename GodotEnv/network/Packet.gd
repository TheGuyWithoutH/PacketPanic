extends Node2D

class_name Packet

var utils
var src_addr
var dst_addr
var mac_addr: Utils.MACAddress
var http_method: Utils.HTTPMethod = -1
var port: int = -1
var vpn
var encryption
var isTampered = false
@export var message = ""

signal errstr(errstr:String)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setSource(address: String):
	var tmpaddr = Utils.IPAddress.new(address)
	if (!tmpaddr._error):
		src_addr = tmpaddr
	else :
		errstr.emit("\""+address+"\" is not a valid ip address !")

func setDestination(address: String):
	var tmpaddr = Utils.IPAddress.new(address)
	if (!tmpaddr._error):
		dst_addr = tmpaddr
	else :
		errstr.emit("\""+address+"\" is not a valid ip address !")
	

func setPort(process_port: int):
	port = process_port

func setMac(mac: String):
	var tmpaddr = Utils.MACAddress.new(mac)
	if (!tmpaddr._error):
		mac_addr = tmpaddr
	else :
		errstr.emit("\""+mac+"\" is not a valid MAC address !")

func encryptMessage(protocol: Utils.Encryption):
	encryption = protocol

func setHTTPMethod(method: Utils.HTTPMethod):
	http_method = method

func setVPN(location: Utils.VPNs):
	vpn = location

func tamperMessage():
	isTampered = true

func setMoving(move: bool):
	if(move):
		$AnimatedSprite2D.play("Moving")
		$Camera2D.allowDrag = false
	else:
		$AnimatedSprite2D.play("Still")
		$Camera2D.allowDrag = true
