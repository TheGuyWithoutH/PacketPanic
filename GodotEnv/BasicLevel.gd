extends Node2D

@export var manager: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	var network = manager.instantiate()
	network.create({
		'nodes': [
			{
				'type': "start",
				'position': [1683, 1597]
			},
			{
				'type': "server",
				'position': [1483, 1446],
				'out_num': 2
			},
			{
				'type': "dead",
				'position': [1588, 1268]
			},
		],
		'links': [
			
		]
	})
	add_child(network)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
