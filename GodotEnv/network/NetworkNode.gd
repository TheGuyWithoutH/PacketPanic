extends Node2D

class_name NetworkNode

var num_links: int = 0
var links: Array
var node_id: int
signal sendPacket(packet: Packet, link: int, node_id: int)
signal endGame(success: bool, error: String)
signal sendVPN(packet: Packet, vpn: int)
var ip: Utils.IPAddress = null

func create(num_links, id, params):
	self.num_links = num_links
	links = []
	links.resize(num_links)
	node_id = id
	if(params && params.get('addr')):
		ip = Utils.IPAddress.new(params['addr'])
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setLink(out: int, link_id: int):
	assert(out < num_links)
	assert(links[out] == null)
	links[out] = link_id

func receivePacket(packet: Packet, link: int):
	assert(links.find(link) > -1 && links.find(link) < num_links)
	packet.position = self.position
	packet.setMoving(false)
	pass

# Send a packet to a node
func _sendPacket(packet: Packet, link: int):
	sendPacket.emit(packet, links[link], node_id)
