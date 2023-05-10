extends NetworkNode

var encryptionNeeded: Utils.Encryption

func create(num_links, id, params):
	assert(params['encryption'] != null)
	super.create(1, id, params)
	match(params['encryption']):
		'none':
			encryptionNeeded = Utils.Encryption.NONE
		'vigenere':
			encryptionNeeded = Utils.Encryption.VIGENERE
		'aes':
			encryptionNeeded = Utils.Encryption.AES
		'quantum':
			encryptionNeeded = Utils.Encryption.POST_QUANTUM


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func receivePacket(packet: Packet, link: int):
	super.receivePacket(packet, link)
	if(packet.encryption && packet.encryption < encryptionNeeded):
		packet.tamperMessage()
	
	if(num_links == 1):
		_sendPacket(packet, 0)
	else:
		var indexLink = links.find(link, 0)
		
		if(indexLink == 0):
			_sendPacket(packet, 1)
		else:
			_sendPacket(packet, 0)
