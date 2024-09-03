extends CharacterBody2D

@export var move_speed : float = 100
@export var attack_speed : float = 1000
#@export var starting_direction : Vector2 = Vector2(0,1)

var last_velocity := Vector2.ZERO
var click_position := Vector2()
var target_position := Vector2()
var mouse_position := Vector2()
var pos_dist : float = 0.0
var skill1_last_time : int = 0

#@export var attack_velocity : Vector2
@onready var animation_tree := $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var fireball := preload("res://scenes/skills/fireball.tscn")
@onready var healthbar := get_tree().get_root().get_node("GameLevel/HUD/HealthBar")
@onready var tot_hp : float = 100
@onready var cur_hp := tot_hp

func _ready():
	click_position = position
	healthbar.max_value = tot_hp
	healthbar.value = cur_hp
	#animation_tree.set("parameters/Idle/blend_position", starting_direction)
	
func _physics_process(_delta):
	mouse_position = get_global_mouse_position()
	if Input.is_action_pressed("Left_Click"):
		click_position = mouse_position
	if Input.is_action_pressed("Skill1"):
		fireball_skill()
		
	pos_dist = position.distance_to(click_position)	
	if pos_dist > 3:
		target_position = (click_position - position).normalized()
		var vel := position.direction_to(click_position) * move_speed
		velocity = vel
		last_velocity = velocity
		move_and_slide()
	else:
		pos_dist = 0
		velocity = Vector2(0,0)
		move_and_slide()
	
	update_animation_parameters(target_position)
	
	if last_velocity.x < 0:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false
	
	pick_new_state()
	#print("position = " + str(position))
	#print("mposition = " + str(click_position))
	#print("velocity = " + str(velocity))
	#print("posdist = " + str(pos_dist))
	
func update_animation_parameters(move_input : Vector2):
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)

func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")
		
func fireball_skill() -> void:
	var fireball_tmp := fireball.instantiate()
	if(Time.get_ticks_msec() - skill1_last_time >= fireball_tmp.delay_time):
		skill1_last_time = Time.get_ticks_msec()
		var shoot_target := (mouse_position - global_position).normalized()
		fireball_tmp.position = global_position
		fireball_tmp.rotation = position.direction_to(mouse_position).angle()
		fireball_tmp.direction = shoot_target
		#this is to make the proj not be affected by the player's movements
		get_tree().get_root().add_child(fireball_tmp)
