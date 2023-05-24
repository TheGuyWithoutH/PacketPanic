extends Node2D

class_name BasicLevel

@export var manager: PackedScene
@export var json_file: JSON
@export var explanationsText: Array[String]
var network: NetworkManager

signal endLevel(success: bool, error: String, history: Array)
signal startExplanation(explanations: Array[String])

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = FileAccess.open(json_file.resource_path, FileAccess.READ)
	var json = json_file.parse_string(file.get_as_text())
	network = manager.instantiate()
	network.create(json)
	network.finishGame.connect(_endLevel)
	add_child(network)
	startExplanation.emit(explanationsText)


func startLevel(packet: Packet):
	add_child(packet)
	network.startGame(packet)

func _endLevel(success: bool, error: String, history: Array):
	endLevel.emit(success, error, history)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
