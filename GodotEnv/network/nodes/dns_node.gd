extends MirrorNode

var translation: Utils.IPAddress
var dest: int

# Called when the node enters the scene tree for the first time.
func create(num_links, id, params):
	assert(params['addr'] != null)
	assert(params['translation'] != null)
	assert(params['dest_id'] != null)
	super.create(num_links, id, params)
	translation = Utils.IPAddress.new(params['translation'])
	dest = params['dest_id']
	$Control.tooltip_text = 'IP: ' + ip.ip_address

func receivePacket(packet: Packet, link: int):
	if(packet.dst_addr && packet.dst_addr.ip_address == ip.ip_address):
		packet.setDestination(translation.ip_address)
		highlightServer.emit(dest)
	super.receivePacket(packet, link)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
