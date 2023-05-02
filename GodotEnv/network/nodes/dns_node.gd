extends MirrorNode

var translation: Utils.IPAddress

# Called when the node enters the scene tree for the first time.
func create(num_links, id, params):
	assert(params['addr'] != null)
	assert(params['translation'] != null)
	super.create(num_links, id, params)
	translation = Utils.IPAddress.new(params['translation'])
	$Control.tooltip_text = 'IP: ' + ip.ip_address

func receivePacket(packet: Packet, link: int):
	if(packet.dst_addr && packet.dst_addr.ip_address == ip.ip_address):
		packet.setDestination(translation.ip_address)
	super.receivePacket(packet, link)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
