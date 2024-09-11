extends Area2D

@export var speed : float = 300
@export var direction := Vector2(1,0)
@export var delay_time := 1000
@export var duration : float = 3.0
@export var damage : float = 1.0
#@export var explosion_damage : float = 1.0

@onready var duration_timer := $Duration
#@onready var explosion_collision := $ExplosionArea/ExplosionCollision
@onready var animation_tree := $AnimationTree
@onready var sprite := $Sprite2D
@onready var state_machine = animation_tree.get("parameters/playback")

var arrow_dead := false
var arrow_dead_duration : float = 0.5

func _ready():
	duration_timer.wait_time = duration
	duration_timer.start()
	#explosion_collision.set_deferred("disabled", true)

func _physics_process(delta) -> void:
	position.x += (speed * direction.x * delta)
	position.y += (speed * direction.y * delta)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.hit(damage)
		destroy()

func _on_timer_timeout() -> void:
	destroy()

func destroy() -> void:
	if arrow_dead:
		queue_free()
	else:
		speed = 0
		arrow_dead = true
		duration_timer.wait_time = arrow_dead_duration
		duration_timer.start()
	#explode()
	
#func explode() -> void:
	#sprite.z_index += 1
	#explosion_collision.set_deferred("disabled", false)
	#state_machine.travel("Explode")

#func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	#if(anim_name == "explode"):
		#queue_free()

#func _on_explosion_area_body_entered(body: Node2D) -> void:
	#if body.is_in_group("Monster"):
		#body.hit(explosion_damage)
