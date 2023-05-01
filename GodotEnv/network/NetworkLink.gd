extends Node2D

var node1: int
var node2: int
var out1: int
var out2: int
var speed: int
var id: int

#Temp var
var destination: int
var remainingTime: int
var current_packet: Packet

signal endTransfer(packet: Packet, node: int, link: int)

func _init(node_1: int, out_1: int, node_2: int, out_2: int, speed_link: int, link_id: int):
	node1 = node_1
	node2 = node_2
	out1 = out_1
	out2 = out_2
	speed = speed_link
	id = link_id
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time (in seconds) since the previous frame.
func _process(delta):
	if(current_packet != null && destination != -1):
		if(remainingTime - delta < 0):
			_finishTransfer()
		else:
			remainingTime = remainingTime - delta

func transferPacket(packet: Packet, node_id: int):
	current_packet = packet
	remainingTime = speed
	
	if(node_id == node1):
		destination = node2
	elif(node_id == node2):
		destination = node1
	else:
		push_error("Not coming from nodes related to the link")
	
	
	
func _finishTransfer():
	endTransfer.emit(current_packet, destination, id)
	destination = -1
	remainingTime = 0
	current_packet = null
