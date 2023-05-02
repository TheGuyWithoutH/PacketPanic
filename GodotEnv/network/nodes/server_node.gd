extends NetworkNode

# Called when the node enters the scene tree for the first time.
func create(num_links, id, params):
	assert(params['addr'] != null)
	super.create(num_links, id, params)
	$Control.tooltip_text = 'IP: ' + ip.ip_address

func receivePacket(packet: Packet, link: int):
	super.receivePacket(packet, link)
	if(packet.dst_addr && packet.dst_addr.ip_address == ip.ip_address):
		endGame.emit(true, 'good')
	else:
		var indexLink = links.find(link, 0)
		
		if(indexLink == 0):
			_sendPacket(packet, 1)
		else:
			_sendPacket(packet, 0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
