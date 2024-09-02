extends CharacterBody2D

enum Swordsman_State { IDLE, WALK, ATTACK, AGGRO, DEATH }

@export var move_speed : float = 40
@export var idle_time : float = 3
@export var walk_time : float = 1.5
@export var post_aggro_time : float = 1.5
@export var tot_hp : float = 10
@export var cur_hp : float = tot_hp
#@export var player : CharacterBody2D

#@onready var animation_tree = $AnimationTree
#@onready var state_machine = animation_tree.get("parameters/playback")
@onready var health_bar := $HealthBar
@onready var damage_bar := $HealthBar/DamageBar
@onready var sprite := $Sprite2D
@onready var state_timer := $StateTimer
@onready var damage_bar_timer := $HealthBar/DamageBar/DamageBarTimer
@onready var player := get_tree().get_first_node_in_group("Player")

var move_direction : Vector2 = Vector2.ZERO
var current_state : Swordsman_State = Swordsman_State.IDLE
var player_detected : bool = false
var damage_bar_delay : float = .5

func _ready():
	health_bar.visible = false
	health_bar.max_value = cur_hp
	health_bar.value = cur_hp
	damage_bar.visible = false
	damage_bar.max_value = cur_hp
	damage_bar.value = cur_hp
	select_new_direction()
	pick_new_state()
	
func _physics_process(_delta):
	if is_instance_valid(player):
		match current_state:
			Swordsman_State["IDLE"]:
				velocity = Vector2(0,0)
			Swordsman_State["WALK"]:
				velocity = move_direction * move_speed
				move_and_slide()
			Swordsman_State["AGGRO"]:
				move_direction = (player.global_position - self.global_position).normalized()
				velocity = move_direction * move_speed
				move_and_slide()
			Swordsman_State["ATTACK"]:
				pass
			Swordsman_State["DEATH"]:
				velocity = Vector2(0,0)
			
		if(move_direction.x < 0):
			sprite.flip_h = true
		elif(move_direction.x > 0):
			sprite.flip_h = false
	
func select_new_direction():
	move_direction = Vector2(randi_range(-1,1), randi_range(-1,1)).normalized()
	
func pick_new_state():
	if(!player_detected):
		if(current_state == Swordsman_State.IDLE ):
			#state_machine.travel("Walk")
			current_state = Swordsman_State.WALK
			select_new_direction()
			state_timer.start(walk_time)
		elif(current_state == Swordsman_State.WALK):
			#state_machine.travel("Idle")
			current_state = Swordsman_State.IDLE
			state_timer.start(idle_time)
		elif(current_state == Swordsman_State.AGGRO):
			#state_machine.travel("Flee")
			current_state = Swordsman_State.WALK
			select_new_direction()
			state_timer.start(walk_time + post_aggro_time)

func _on_timer_timeout() -> void:
	pick_new_state()

func _on_player_detector_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		player_detected = true
		current_state = Swordsman_State.AGGRO

func _on_player_detector_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		player_detected = false
		pick_new_state()

func hit(damage: float) -> void:
	cur_hp -= damage
	health_bar.value = cur_hp
	damage_bar_timer.start(damage_bar_delay)
	if(!health_bar.visible):
		health_bar.visible = true
		damage_bar.visible = true
	if(cur_hp <= 0):
		die()

func die() -> void:
	#death animation
	queue_free()

func _on_damage_bar_timer_timeout() -> void:
	damage_bar.value = cur_hp
