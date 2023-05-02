extends NetworkNode

func create(num_links, id, params):
	super.create(1, id, params)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func receivePacket(packet: Packet, link: int):
	super.receivePacket(packet, link)
	_sendPacket(packet, -1)

func startGame(packet: Packet):
	_sendPacket(packet, 0)
