extends NetworkNode

func create(num_links, id, params):
	super.create(num_links, id, params)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func receivePacket(packet: Packet, link: int):
	super.receivePacket(packet, link)
	endGame.emit(false, 'You felt into a dead node')
