extends Node2D

class_name NetworkManager

var start_node: int = -1
var end_node: Utils.IPAddress
var nodes: Array
var links: Array

const LogicNode = preload("res://network/nodes/logic_node.tscn")
const DeadNode = preload("res://network/nodes/dead_node.tscn")
const ServerNode = preload("res://network/nodes/server_node.tscn")
const NetworkLink = preload("res://network/NetworkLink.tscn")
const ClientNode = preload("res://network/nodes/client_node.tscn")
const MirrorNode =  preload("res://network/nodes/mirror_node.tscn")
const DnsNode =  preload("res://network/nodes/dns_node.tscn")

func create(level: Dictionary, packet: Packet):
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
		nodes.append(nodeObj)
		add_child(nodeObj)
		nodeObj.position = Vector2(node['position'][0], node['position'][1])
		nodeObj.sendPacket.connect(_handleStartTransfer)
		nodeObj.endGame.connect(_endLevel)
		i += 1
	
	start_node = level['start_node']
	
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
		
	packet.position = nodes[start_node].position
	print(packet.position)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _handleStartTransfer(packet: Packet, link: int, node_id: int):
	print(link)
	links[link].transferPacket(packet, node_id)
	
func _handleEndTransfer(packet: Packet, node: int, link: int):
	print('end transfer')
	nodes[node].receivePacket(packet, link)

# Method to call to start the game
func startGame(packet: Packet):
	print('start')
	nodes[start_node].startGame(packet)

func _endLevel(success: bool, error: String):
	print('end: ' + error)
