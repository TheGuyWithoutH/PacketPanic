extends NetworkNode

var vpn_id: Utils.VPNs
var vpn_list: Array

@export var textureNA: Texture
@export var textureSA: Texture
@export var textureAS: Texture
@export var textureAF: Texture
@export var textureEU: Texture
@export var textureOC: Texture

func create(num_links, id, params):
	assert(params['name'] != null)
	assert(params['vpn_list'] != null)
	assert(params['addr'] != null)
	super.create(num_links, id, params)
	
	match(params['name']):
		'north_america':
			vpn_id = Utils.VPNs.NORTH_AMERICA
			$SpriteNA.show()
		'south_america':
			vpn_id = Utils.VPNs.SOUTH_AMERICA
			$SpriteSA.show()
		'africa':
			vpn_id = Utils.VPNs.AFRICA
			$SpriteAF.show()
		'asia':
			vpn_id = Utils.VPNs.ASIA
			$SpriteAS.show()
		'europe':
			vpn_id =Utils.VPNs.EUROPE
			$SpriteEU.show()
		'oceania':
			vpn_id =Utils.VPNs.OCEANIA
			$SpriteOC.show()
	
	vpn_list = params['vpn_list']

func receivePacket(packet: Packet, link: int):
	print("catched packet !\n")
	super.receivePacket(packet, link)
	var chosen_vpn = packet.vpn if packet.vpn else Utils.VPNs.EUROPE
	sendVPN.emit(packet, vpn_list[chosen_vpn])

func receivePacketVPN(packet: Packet):
	super.receivePacketVPN(packet)
	packet.setSource(ip.ip_address)
	_sendPacket(packet, 0)
	
