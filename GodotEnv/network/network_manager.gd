extends Node2D

class_name NetworkManager

var start_node: int
var end_node: Utils.IPAddress
var nodes: Array
var links: Array

const LogicNode = preload("res://network/nodes/logic_node.tscn")
const DeadNode = preload("res://network/nodes/dead_node.tscn")
const ServerNode = preload("res://network/nodes/server_node.tscn")
const NetworkLink = preload("res://network/network_link.tscn")
const ClientNode = preload("res://network/nodes/client_node.tscn")

func create(level: Dictionary):
	var nodes_list = level['nodes']
	var i = 0
	for node in nodes_list:
		var nodeObj: NetworkNode
		match(node['type']):
			'logic':
				nodeObj = LogicNode.instantiate()
				nodeObj.create(node['out_num'], i)
			'dead':
				nodeObj = DeadNode.instantiate()
				nodeObj.create(0, i)
			'server':
				nodeObj = ServerNode.instantiate()
				nodeObj.create(node['out_num'], i)
			'start':
				nodeObj = ClientNode.instantiate()
				nodeObj.create(1, i)
		nodes.append(nodeObj)
		add_child(nodeObj)
		nodeObj.position = Vector2(node['position'][0], node['position'][1])
		nodeObj.sendPacket.connect(_handleStartTransfer)
		++i
	
	var links_list = level['links']
	i = 0
	for link in links_list:
		var linkObj = NetworkLink.new(link[0], link[1], link[2], link[3], link[4], i)
		links.append(linkObj)
		add_child(linkObj)
		linkObj.endTransfer.connect(_handleEndTransfer)
		++i
		


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _handleStartTransfer(packet: Packet, link: int, node_id: int):
	links[link].transferPacket(packet, node_id)
	
func _handleEndTransfer(packet: Packet, node: int, link: int):
	nodes[node].receivePacket(packet, link)
