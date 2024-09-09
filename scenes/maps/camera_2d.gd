extends Camera2D

func _process(_delta: float) -> void:
	var ZoomSpeed = Vector2(.1,.1)
	
	if Input.is_action_just_released("Zoom_In"):
		zoom += ZoomSpeed
	elif Input.is_action_just_released("Zoom_Out"):
		zoom -= ZoomSpeed
