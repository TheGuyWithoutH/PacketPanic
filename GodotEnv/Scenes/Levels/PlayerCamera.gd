extends Camera2D

var allowDrag = true

var _previousPosition: Vector2 = Vector2(0, 0);
var _moveCamera: bool = false;

func _input(event: InputEvent):
	if !allowDrag:
		_moveCamera = false;
	elif event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled();
		if event.is_pressed():
			_previousPosition = event.position;
			_moveCamera = true;
		else:
			_moveCamera = false;
	elif event is InputEventMouseMotion && _moveCamera:
		get_viewport().set_input_as_handled();
		var new_position = position + (_previousPosition - event.position)
		if(_isInBounds(new_position)):
			position = new_position;
			_previousPosition = event.position;

func _isInBounds(position: Vector2):
	var size = get_viewport().size
	print(position)
	return position.x > -800 && position.x < 1900 && position.y > -1000 && position.y < 600
