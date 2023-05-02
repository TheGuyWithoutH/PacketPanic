extends NetworkNode

var shifting: int = -1

func create(num_links, id, params):
	super.create(num_links, id, null)
	if(params && params['shifting']):
		shifting = params['shifting']

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func receivePacket(packet: Packet, link: int):
	super.receivePacket(packet, link)
	var out_link
	var in_link: int = links.find(link, 0)
	if(shifting == -1):
		out_link = (in_link + packet.mac_addr.toInteger()) % num_links
	else:
		out_link = (in_link + shifting) % num_links
	_sendPacket(packet, out_link)
