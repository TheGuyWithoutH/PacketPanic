extends RichTextLabel

var packet = {
	"src_ip":"n/a",
	"dest_ip":"n/a",
	"dns":"n/a",
	"crypt_meth":"n/a",
	"vpn":"n/a",
	"port":"n/a",
	"http_req":"n/a",
	"mac_addr":"n/a"
}

func _ready():
	packet.src_ip = "192.168.0.78"
	print_packet()
	
func print_packet():
	text = "PACKET OVERWIEV\n"
	text += "src_IP : %s \n" % packet.src_ip
	text += "dest_IP : %s \n" % packet.dest_ip
	text += "port : %s \n" % packet.port
	
