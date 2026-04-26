extends RigidBody3D

@onready var projectile_collision: Area3D = $ProjectileCollision

func _ready() -> void:
	add_to_group(Global.PROJECTILE_TAG)
	if not is_multiplayer_authority():
		#set_process(false)
		set_physics_process(false)
		return
	projectile_collision.body_entered.connect(on_collision)

func on_collision(body : Node3D):
	if body.is_in_group(Global.ENEMY_TAG):
		body.queue_free()
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
