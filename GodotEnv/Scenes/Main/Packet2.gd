extends RichTextLabel

const Packet = preload("res://network/Packet.tscn")

@export var editpack = Packet.instantiate()

func _ready():
	editpack.setDestination('185.25.195.105')
	editpack.setMac('5E:FF:56:A2:AF:03')
	editpack.setPort(80)

func _process(delta):
	self.text = "packet:\n"
	self.text += "dest_ip : " + str(editpack.dst_addr)
