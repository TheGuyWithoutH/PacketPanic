extends ColorRect

signal usercreds(username:String,password:String)

func _on_password_in_text_submitted(new_text):
	print("submitted : " + $MarginContainer/Container/username_in.text + $MarginContainer/Container/password_in.text)
	if($MarginContainer/Container/username_in.text != '' && $MarginContainer/Container/password_in.text != '' ):
		usercreds.emit($MarginContainer/Container/username_in.text,$MarginContainer/Container/password_in.text)
		#TODO change scene to main
