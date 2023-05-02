extends Node

class_name Utils

class IPAddress:
	var ip_address
	
	func _init(address):
		assert(_checkIpAddress(address))
		ip_address = address
	
	func _checkIpAddress(address):
		var regex = RegEx.new()
		regex.compile("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$")
		return regex.search(address).get_string() == address

class MACAddress:
	var mac_address: String
	
	func _init(address):
		assert(_checkMacAddress(address))
		mac_address = address
	
	func _checkMacAddress(address):
		var regex = RegEx.new()
		regex.compile("^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$")
		return regex.search(address).get_string() == address
	
	func toInteger():
		var numbers = mac_address.split(':')
		print(int(numbers[numbers.size() - 1]))
		return int(numbers[numbers.size() - 1])

enum Encryption {NONE, RSA, AES, POST_QUANTUM}

enum HTTPMethod {GET, POST, DELETE}

enum VPNs {AMERICA, EUROPE, ASIA, AFRICA}
