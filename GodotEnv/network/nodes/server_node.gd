extends NetworkNode

var target_src_ip: Utils.IPAddress = null
var target_http_method: Utils.HTTPMethod = -1
var target_port: int = 80

# Called when the node enters the scene tree for the first time.
func create(num_links, id, params):
	assert(params['addr'] != null)
	super.create(num_links, id, params)
	$Control.tooltip_text = 'IP: ' + ip.ip_address + '\nPort: ' + str(target_port)
	
	if(params.get('http_method', null)):
		match(params['http_method']):
			'GET':
				target_http_method = Utils.HTTPMethod.GET
			'POST':
				target_http_method = Utils.HTTPMethod.POST
			'DELETE':
				target_http_method = Utils.HTTPMethod.DELETE
	
	if(params.get('port', -1) > -1):
		target_port = params['port']
	
	if(params.get('target_src')):
		target_src_ip =  Utils.IPAddress.new(params['target_src'])

func receivePacket(packet: Packet, link: int):
	super.receivePacket(packet, link)
	if(packet.dst_addr && packet.dst_addr.ip_address == ip.ip_address):
		if(target_port > -1 && (packet.port < 0 || packet.port != target_port)):
			endGame.emit(false, 'Error 400: nothing is available at this port.')
		elif(target_src_ip && (!packet.src_addr || packet.src_addr.ip_address != target_src_ip.ip_address)):
			endGame.emit(false, 'Error 401: your source IP address is not authorized.')
		elif(target_http_method > -1 && (packet.http_method < 0 || packet.http_method != target_http_method)):
			endGame.emit(false, 'Error 405: accessing the ressource with the wrong method.')
		else:
			endGame.emit(true, 'good')
	elif(num_links == 1):
		_sendPacket(packet, 0)
	else:
		var indexLink = links.find(link, 0)
		
		if(indexLink == 0):
			_sendPacket(packet, 1)
		else:
			_sendPacket(packet, 0)

func showHighlight():
	$Highligt.show()
