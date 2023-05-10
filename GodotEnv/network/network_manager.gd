extends Node2D

class_name NetworkManager

var start_node: int = -1
var end_node: Utils.IPAddress
var nodes: Array
var links: Array
var history: Array
var timeout: int
var finished = false

const Packet = preload("res://network/Packet.tscn")
var idlePacket: Packet

const LogicNode = preload("res://network/nodes/logic_node.tscn")
const DeadNode = preload("res://network/nodes/dead_node.tscn")
const ServerNode = preload("res://network/nodes/server_node.tscn")
const NetworkLink = preload("res://network/NetworkLink.tscn")
const ClientNode = preload("res://network/nodes/client_node.tscn")
const MirrorNode =  preload("res://network/nodes/mirror_node.tscn")
const DnsNode =  preload("res://network/nodes/dns_node.tscn")
const AttackerNode = preload("res://network/nodes/attacker_node.tscn")
const VpnNode = preload("res://network/nodes/vpn_node.tscn")
const SlowNode = preload("res://network/nodes/slow_node.tscn")

signal finishGame(success: bool, error: String, history: Array)

func create(level: Dictionary):
	var nodes_list = level['nodes']
	var i = 0
	for node in nodes_list:
		var nodeObj: NetworkNode
		match(node['type']):
			'logic':
				nodeObj = LogicNode.instantiate()
				var params = null
				if(node.get('shifting')):
					params = {'shifting': node['shifting']}
				nodeObj.create(node['out_num'], i, params)
			'dead':
				nodeObj = DeadNode.instantiate()
				nodeObj.create(node['out_num'], i, null)
			'server':
				nodeObj = ServerNode.instantiate()
				nodeObj.create(node['out_num'], i, { 'addr': node['addr'], 'port': node.get('port', -1), 'target_src': node.get('target_src'), 'http_method': node.get('http_method')})
			'start':
				nodeObj = ClientNode.instantiate()
				nodeObj.create(1, i, null)
			'mirror':
				nodeObj = MirrorNode.instantiate()
				nodeObj.create(node['out_num'], i, null)
			'dns':
				nodeObj = DnsNode.instantiate()
				nodeObj.create(node['out_num'], i, { 'addr': node['addr'], 'translation': node['translation'] })
			'slow':
				nodeObj = SlowNode.instantiate()
				nodeObj.create(node['out_num'], i, { 'delay': node['delay'] })
			'attacker':
				nodeObj = AttackerNode.instantiate()
				nodeObj.create(node['out_num'], i, { 'encryption': node['encryption'] })
			'vpn':
				nodeObj = VpnNode.instantiate()
				nodeObj.create(node['out_num'], i, { 'addr': node['addr'], 'name': node['name'], 'vpn_list': node['vpn_list'] })
		nodes.append(nodeObj)
		add_child(nodeObj)
		nodeObj.position = Vector2(node['position'][0], node['position'][1])
		nodeObj.sendPacket.connect(_handleStartTransfer)
		nodeObj.sendVPN.connect(_sendToVPN)
		nodeObj.endGame.connect(_endLevel)
		i += 1
	
	start_node = level['start_node']
	timeout = level['timeout']
	
	var links_list = level['links']
	i = 0
	for link in links_list:
		var linkObj = NetworkLink.instantiate()
		linkObj.create(link[0], link[2], link[4], i, nodes[link[0]].position, nodes[link[2]].position)
		nodes[linkObj.node1].setLink(link[1], i)
		nodes[linkObj.node2].setLink(link[3], i)
		links.append(linkObj)
		add_child(linkObj)
		linkObj.endTransfer.connect(_handleEndTransfer)
		i += 1
	
	idlePacket = Packet.instantiate()
	idlePacket.position = nodes[start_node].position
	add_child(idlePacket)
	print(idlePacket.position)

func _handleStartTransfer(packet: Packet, link: int, node_id: int):
	print(link)
	links[link].transferPacket(packet, node_id)

func _sendToVPN(packet: Packet, vpn: int):
	print('arrived after vpn')
	history.append(nodes[vpn].position)
	nodes[vpn].receivePacketVpn(packet)
	
func _handleEndTransfer(packet: Packet, node: int, link: int):
	print('end transfer')
	history.append(nodes[node].position)
	if(!finished):
		nodes[node].receivePacket(packet, link)

# Method to call to start the game
func startGame(packet: Packet):
	finished = false
	remove_child(idlePacket)
	history.clear()
	history.append(nodes[start_node].position)
	packet.position = nodes[start_node].position
	print(packet.position)
	nodes[start_node].startGame(packet)
	$MaxTime.start(timeout)

func _endLevel(success: bool, error: String):
	finished = true
	finishGame.emit(success, error, history)


func _on_time_timeout():
	finished = true
	_endLevel(false, "Error 408: Request timeout, you took too long to arrive")
