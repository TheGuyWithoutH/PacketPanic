extends NetworkNode

var delay: int
var currentPacket: Packet = null
var currentLink: int = -1

func create(num_links, id, params):
	assert(params['delay'] != null)
	super.create(num_links, id, params)
	delay = params['delay']

func receivePacket(packet: Packet, link: int):
	super.receivePacket(packet, link)
	currentPacket = packet
	currentLink = link
	$Timer.start(delay)

func _on_delay_finish():
	if(num_links == 1):
		_sendPacket(currentPacket, 0)
	else:
		var indexLink = links.find(currentLink, 0)
		
		if(indexLink == 0):
			_sendPacket(currentPacket, 1)
		else:
			_sendPacket(currentPacket, 0)
	currentPacket = null
	currentLink = -1
