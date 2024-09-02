extends Area2D

@export var speed : float = 200
@export var direction := Vector2(1,0)
@export var delay_time := 1000
@export var duration : float = 2.0
@export var damage : float = 2

@onready var duration_timer := $Duration

func _ready():
	duration_timer.wait_time = duration
	duration_timer.start()

func _physics_process(delta) -> void:
	position.x += (speed * direction.x * delta)
	position.y += (speed * direction.y * delta)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Monster"):
		body.hit(damage)
		destroy()

func _on_timer_timeout() -> void:
	destroy()

func destroy() -> void:
	speed = 0
	queue_free()
