extends NetworkNode

var shifting

func create(num_links, id):
	super.create(num_links, id)
	#shifting = shift

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func receivePacket(packet: Packet, link: int):
	super.receivePacket(packet, link)
	var out_link
	if(shifting == -1):
		out_link = (link + packet.mac_addr.toInteger()) % num_links
	else:
		out_link = (link + shifting) % num_links
	_sendPacket(packet, out_link)
