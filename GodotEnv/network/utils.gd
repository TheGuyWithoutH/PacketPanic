extends Node

class_name Utils

class IPAddress:
	var ip_address
	var _error
	
	func _init(address):
		if(_checkIpAddress(address)):
			ip_address = address
			_error = false
		else: 
			ip_address = "0.0.0.0"
			_error = true
	
	func _checkIpAddress(address):
		var regex = RegEx.new()
		regex.compile("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$")
		if(regex.search(address) != null):
			return true
		else:
			return false

class MACAddress:
	var mac_address: String
	var _error
	signal errstr(errstr:String)
	
	func _init(address):
		if(_checkMacAddress(address)):
			mac_address = address
			_error = false
		else: 
			mac_address = "00:00:00:00:00:00"
			_error = true
			
	
	func _checkMacAddress(address):
		var regex = RegEx.new()
		regex.compile("^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$")
		if(regex.search(address) != null):
			return true
		else:
			return false
	
	func toInteger():
		var numbers = mac_address.split(':')
		print(int(numbers[numbers.size() - 1]))
		return int(numbers[numbers.size() - 1])

enum Encryption {NONE, VIGENERE, AES, POST_QUANTUM}

enum HTTPMethod {GET, POST, DELETE}

enum VPNs {AMERICA, EUROPE, ASIA, AFRICA}
