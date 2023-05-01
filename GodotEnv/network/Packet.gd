extends Node

class_name Packet

var utils
var src_addr
var dst_addr
var mac_addr: Utils.MACAddress
var http_method
var port
var vpn
var encryption
var isTampered = false
@export var message = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setSource(address: String):
	src_addr = Utils.IPAddress.new(address)

func setDestination(address: String):
	dst_addr = Utils.IPAddress.new(address)

func setPort(process_port: int):
	port = process_port

func setMac(mac: String):
	mac_addr = Utils.MACAddress.new(mac)

func encryptMessage(protocol: Utils.Encryption):
	encryption = protocol

func setHTTPMethod(method: Utils.HTTPMethod):
	http_method = method

func setVPN(location: Utils.VPNs):
	vpn = location

func tamperMessage():
	isTampered = true

