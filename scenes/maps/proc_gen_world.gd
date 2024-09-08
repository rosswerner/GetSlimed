extends Node2D

@export var noise_height_text : NoiseTexture2D

var noise : Noise
var width : int = 1000
var height : int = 1000
var noise_val_arr = []
var sand_val_arr : Array[Vector2i] = []
var grass_val_arr : Array[Vector2i] = []
var sand1_val_arr : Array[Vector2i] = []
var cliff_val_arr : Array[Vector2i] = []
var cliff1_val_arr : Array[Vector2i] = []
var source_id = 0

@onready var water_layer := $Water
@onready var sand_layer := $SandOnWater
@onready var grass_layer := $GrassOnSand
@onready var sand_on_grass_layer := $SandOnGrass
@onready var cliff_layer := $Cliffs
@onready var cliff_layer1 := $Cliffs1

var water_atlas = Vector2i(0,1)
var land_atlas = Vector2i(0,0)


func _ready():
	noise = noise_height_text.noise
	generate_world()

func generate_world():
		for x in range(-width/2, width/2):
			for y in range(-height/2, height/2):
				var noise_val = noise.get_noise_2d(x,y)
				noise_val_arr.append(noise_val)
				
				#sand
				if (noise_val >= -0.1):
					sand_val_arr.append(Vector2i(x,y))
				#grass
				if(noise_val >= 0.0):
					grass_val_arr.append(Vector2i(x,y))
					if(noise_val >= 0.3):
						sand1_val_arr.append(Vector2i(x,y))
				#sand_again
				if(noise_val >= 0.4):
					cliff_val_arr.append(Vector2i(x,y))
					if(noise_val >= 0.53):
						cliff1_val_arr.append(Vector2i(x,y))
					#sand_layer.set_cell(Vector2i(x,y), source_id, land_atlas)
				#water
				#else:
				water_layer.set_cell(Vector2(x,y), source_id, water_atlas)
		
		sand_layer.set_cells_terrain_connect(sand_val_arr,0,2)
		grass_layer.set_cells_terrain_connect(grass_val_arr,0,4)
		sand_on_grass_layer.set_cells_terrain_connect(sand1_val_arr,0,0)
		cliff_layer.set_cells_terrain_connect(cliff_val_arr,0,3)
		cliff_layer1.set_cells_terrain_connect(cliff1_val_arr,0,3)
		
				
