extends CharacterBody2D

enum Slime_State { IDLE, WALK, DEATH, FLEE }

@export var move_speed : float = 40
@export var idle_time : float = 3
@export var walk_time : float = 1.5
@export var post_flee_time : float = 1.5
#@export var player : CharacterBody2D

#@onready var animation_tree = $AnimationTree
#@onready var state_machine = animation_tree.get("parameters/playback")
@onready var sprite = $Sprite2D
@onready var timer = $Timer
@onready var player = get_tree().get_first_node_in_group("Player")

var move_direction : Vector2 = Vector2.ZERO
var current_state : Slime_State = Slime_State.IDLE
var player_detected : bool = false

func _ready():
	select_new_direction()
	pick_new_state()
	
func _physics_process(_delta):
	if is_instance_valid(player):
		match current_state:
			Slime_State["IDLE"]:
				pass
			Slime_State["WALK"]:
				velocity = move_direction * move_speed
				move_and_slide()
			Slime_State["FLEE"]:
				move_direction = -1 * (player.global_position - self.global_position).normalized()
				velocity = move_direction * move_speed
				move_and_slide()
			Slime_State["DEATH"]:
				pass
	
	
func select_new_direction():
	move_direction = Vector2(randi_range(-1,1), randi_range(-1,1)).normalized()
	
	if(move_direction.x < 0):
		sprite.flip_h = true
	elif(move_direction.x > 0):
		sprite.flip_h = false
	
func pick_new_state():
	if(!player_detected):
		if(current_state == Slime_State.IDLE ):
			#state_machine.travel("Walk")
			current_state = Slime_State.WALK
			select_new_direction()
			timer.start(walk_time)
		elif(current_state == Slime_State.WALK):
			#state_machine.travel("Idle")
			current_state = Slime_State.IDLE
			timer.start(idle_time)
		elif(current_state == Slime_State.FLEE):
			#state_machine.travel("Flee")
			current_state = Slime_State.WALK
			select_new_direction()
			timer.start(walk_time + post_flee_time)

func _on_timer_timeout() -> void:
	pick_new_state()

func _on_player_detector_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		player_detected = true
		current_state = Slime_State.FLEE

func _on_player_detector_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		player_detected = false
		pick_new_state()
