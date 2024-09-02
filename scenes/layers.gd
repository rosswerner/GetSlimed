extends Node
const base_layer = preload("res://scenes/test_base_layer.tscn")

func _ready():
	#change x to number of layers
	#for i in range(x)
	var new_layer = base_layer.instantiate()
	add_child(new_layer)
