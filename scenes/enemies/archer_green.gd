extends CharacterBody2D

enum Enemy_State { IDLE, WALK, ATTACK, AGGRO, DEATH }

@export var move_speed : float = 40
@export var idle_time : float = 3
@export var walk_time : float = 1.5
@export var post_aggro_time : float = 1.5
@export var tot_hp : float = 10
@export var cur_hp : float = tot_hp
@export var proj_damage : float = 10.0
#@export var player : CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var health_bar := $HealthBar
@onready var damage_bar := $HealthBar/DamageBar
@onready var sprite := $Sprite2D
@onready var state_timer := $StateTimer
@onready var damage_bar_timer := $HealthBar/DamageBar/DamageBarTimer
@onready var hitbox := $Hitbox
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var arrow := preload("res://scenes/skills/arrow.tscn")

var move_direction : Vector2 = Vector2.ZERO
var current_state : Enemy_State = Enemy_State.IDLE
var player_detected : bool = false
var player_hittable : bool = false
var damage_bar_delay : float = .5
var pos_dist : float = 0.0
var skill1_last_time : int = 0
var player_body : Node2D

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
			Enemy_State["IDLE"]:
				velocity = Vector2(0,0)
			Enemy_State["WALK"]:
				velocity = move_direction * move_speed
				move_and_slide()
			Enemy_State["AGGRO"]:
				pos_dist = position.distance_to(player.global_position)	
				if !player_hittable and pos_dist > 3:
					move_direction = (player.global_position - self.global_position).normalized()
					velocity = move_direction * move_speed
					move_and_slide()
				else:
					current_state = Enemy_State.ATTACK
			Enemy_State["ATTACK"]:
				velocity = Vector2(0,0)
				state_machine.travel("Attack")
			Enemy_State["DEATH"]:
				velocity = Vector2(0,0)
			
		if(move_direction.x < 0):
			sprite.flip_h = true
		elif(move_direction.x > 0):
			sprite.flip_h = false
	
func select_new_direction():
	move_direction = Vector2(randi_range(-1,1), randi_range(-1,1)).normalized()
	
func pick_new_state():
	if(!player_detected):
		if(current_state == Enemy_State.IDLE ):
			state_machine.travel("Walk")
			current_state = Enemy_State.WALK
			select_new_direction()
			state_timer.start(walk_time)
		elif(current_state == Enemy_State.WALK):
			state_machine.travel("Idle")
			current_state = Enemy_State.IDLE
			state_timer.start(idle_time)
		elif(current_state == Enemy_State.AGGRO):
			current_state = Enemy_State.WALK
			select_new_direction()
			state_timer.start(walk_time + post_aggro_time)

func _on_timer_timeout() -> void:
	pick_new_state()

func _on_player_detector_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player") and !(cur_hp <=0)):
		player_body = body
		player_detected = true
		current_state = Enemy_State.AGGRO

func _on_player_detector_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player") and !(cur_hp <=0)):
		player_detected = false
		pick_new_state()
		
func _on_attack_player_detector_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player") and !(cur_hp <=0)):
		player_hittable = true
		current_state = Enemy_State.ATTACK
		
		#This would only happen on hitscan weapons, otherwise needs to be on arrow
		#body.hit(proj_damage)

func _on_attack_player_detector_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player") and !(cur_hp <=0)):
		player_hittable = false
		current_state = Enemy_State.AGGRO

func hit(damage: float) -> void:
	if(cur_hp > 0):
		cur_hp -= damage
		health_bar.value = cur_hp
		damage_bar_timer.start(damage_bar_delay)
		current_state = Enemy_State.AGGRO
		
		if(!health_bar.visible):
			health_bar.visible = true
			damage_bar.visible = true
	if(cur_hp <= 0 and current_state != Enemy_State.DEATH):
		die()
		
func arrow_skill() -> void:
	var arrow_tmp := arrow.instantiate()
	if(Time.get_ticks_msec() - skill1_last_time >= arrow_tmp.delay_time):
		skill1_last_time = Time.get_ticks_msec()
		var target_direction := global_position.direction_to(player_body.global_position)
		arrow_tmp.position = global_position
		arrow_tmp.global_rotation = target_direction.angle()
		arrow_tmp.direction = target_direction
		#this is to make the proj not be affected by the player's movements
		get_tree().get_root().add_child(arrow_tmp)

func die() -> void:
	hitbox.set_deferred("disabled", true)
	current_state = Enemy_State.DEATH
	velocity = Vector2.ZERO
	health_bar.visible = false
	damage_bar.visible = false
	state_machine.travel("Death")
	
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "death"):
		queue_free()
	elif("shoot" in anim_name and !(cur_hp <=0)):
		state_machine.travel("Walk")
		current_state = Enemy_State.AGGRO
		player.hit(proj_damage)

func _on_damage_bar_timer_timeout() -> void:
	damage_bar.value = cur_hp

func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	if("shoot" in anim_name):
		arrow_skill()
