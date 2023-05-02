extends NetworkNode

class_name MirrorNode

func create(num_links, id, params):
	super.create(num_links, id, params)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func receivePacket(packet: Packet, link: int):
	super.receivePacket(packet, link)
	var in_link = links.find(link, 0)
	_sendPacket(packet, in_link)
