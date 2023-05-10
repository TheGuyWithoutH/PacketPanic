extends NetworkNode

var vpn_id: Utils.VPNs
var vpn_list: Array

func create(num_links, id, params):
	assert(params['name'] != null)
	assert(params['vpn_list'] != null)
	assert(params['addr'] != null)
	super.create(num_links, id, params)
	
	match(params['name']):
		'america':
			vpn_id = Utils.VPNs.AMERICA
		'africa':
			vpn_id = Utils.VPNs.AFRICA
		'asia':
			vpn_id = Utils.VPNs.ASIA
		'europe':
			vpn_id =Utils.VPNs.EUROPE
	
	vpn_list = params['vpn_list']

func receivePacket(packet: Packet, link: int):
	super.receivePacket(packet, link)
	var chosen_vpn = packet.vpn
	sendVPN.emit(packet, vpn_list[chosen_vpn])

func receivePacketVPN(packet: Packet):
	packet.setSource(ip.ip_address)
	_sendPacket(packet, 0)
	
