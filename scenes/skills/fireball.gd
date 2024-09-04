extends Area2D

@export var speed : float = 200
@export var direction := Vector2(1,0)
@export var delay_time := 1000
@export var duration : float = 2.0
@export var damage : float = 2.0
@export var explosion_damage : float = 1.0

@onready var duration_timer := $Duration
@onready var explosion_collision := $ExplosionArea/ExplosionCollision
@onready var animation_tree := $AnimationTree
@onready var sprite := $Sprite2D
@onready var state_machine = animation_tree.get("parameters/playback")

func _ready():
	duration_timer.wait_time = duration
	duration_timer.start()
	explosion_collision.set_deferred("disabled", true)

func _physics_process(delta) -> void:
	position.x += (speed * direction.x * delta)
	position.y += (speed * direction.y * delta)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Monster"):
		body.hit(damage)
		destroy()

func _on_timer_timeout() -> void:
	queue_free()

func destroy() -> void:
	speed = 0
	explode()
	
func explode() -> void:
	sprite.z_index += 1
	explosion_collision.set_deferred("disabled", false)
	state_machine.travel("Explode")

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "explode"):
		queue_free()

func _on_explosion_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Monster"):
		body.hit(explosion_damage)
