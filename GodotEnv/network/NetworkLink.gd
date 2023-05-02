extends Node2D

var node1: int
var node2: int
var speed: int
var id: int
var from: Vector2
var to: Vector2

#Temp var
var destination: int
var remainingTime: float
var current_packet: Packet

signal endTransfer(packet: Packet, node: int, link: int)

func create(node_1: int, node_2: int, speed_link: int, link_id: int, position1: Vector2, position2: Vector2):
	node1 = node_1
	node2 = node_2
	speed = speed_link
	id = link_id
	from = position1
	to = position2
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time (in seconds) since the previous frame.
func _process(delta):
	if(current_packet != null && destination > -1):
		if(remainingTime - delta <= 0):
			_finishTransfer()
		else:
			remainingTime = remainingTime - delta
			current_packet.position = _interpolatePosition()

func _interpolatePosition():
	var percent = (speed - remainingTime) / speed
	var start_position: Vector2
	var end_position: Vector2
	
	if(destination == node1):
		start_position = to
		end_position = from
	else:
		start_position = from
		end_position = to
	
	return start_position.lerp(end_position, percent)


func transferPacket(packet: Packet, node_id: int):
	print('transferring packet...')
	current_packet = packet
	remainingTime = speed
	packet.setMoving(true)
	
	if(node_id == node1):
		destination = node2
	elif(node_id == node2):
		destination = node1
	else:
		push_error("Not coming from nodes related to the link")


func _finishTransfer():
	var tempDest = destination
	var tempPacket = current_packet
	destination = -1
	remainingTime = 0
	current_packet = null
	endTransfer.emit(tempPacket, tempDest, id)
	
func _draw():
	draw_line(from, to, Color.WHITE, 2.)
