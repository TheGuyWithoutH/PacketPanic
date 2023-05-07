extends Node2D

@export var manager: PackedScene
@export var json_file: JSON
const Packet = preload("res://network/Packet.tscn")
@onready var packet = Packet.instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = FileAccess.open(json_file.resource_path, FileAccess.READ)
	var json = json_file.parse_string(file.get_as_text())
	packet.setDestination('185.25.195.105')
	packet.setMac('5E:FF:56:A2:AF:03')
	packet.setPort(80)
	var network = manager.instantiate()
	network.create(json, packet)
	add_child(network)
	add_child(packet)
	network.startGame(packet)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
