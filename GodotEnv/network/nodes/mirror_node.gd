extends NetworkNode

class_name MirrorNode

func create(num_links, id, params):
	super.create(num_links, id, params)

func receivePacket(packet: Packet, link: int):
	super.receivePacket(packet, link)
	var in_link = links.find(link, 0)
	_sendPacket(packet, in_link)
