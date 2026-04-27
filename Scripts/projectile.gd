extends RigidBody3D
class_name Projectile

@export var speed : float = 5.0
@export var base_damage : float = 1.0
@export var size : float = 1.0
@export var lifespan : float = 3.0
@export var hits : int = 1
@export var amount : int = 1
@export var piercing : bool = true

enum movement_type{
	straight,
	gravity
}

@onready var projectile_collision: Area3D = $ProjectileCollision
@onready var timer: Timer = $Timer
@onready var physics_shape: CollisionShape3D = $PhysicsShape
@onready var hitbox: CollisionShape3D = $ProjectileCollision/Hitbox

func _ready() -> void:
	add_to_group(Global.PROJECTILE_TAG)
	if not is_multiplayer_authority():
		#set_process(false)
		set_physics_process(false)
		return
	projectile_collision.body_entered.connect(on_collision)
	timer.wait_time = lifespan
	timer.timeout.connect(timeout)
	#if piercing:
		#physics_shape.shape = get_capsule_shape(0.1)
	

func on_collision(body : Node3D):
	if body.is_in_group(Global.ENEMY_TAG):
		body.queue_free()
		hits -= 1
		if hits <= 0:
			queue_free()

func timeout() -> void:
	queue_free()
	
func get_capsule_shape(radius : float = 0.5, height :float = 2.0) -> CapsuleShape3D:
	var shape = CapsuleShape3D.new()
	shape.radius = radius
	shape.height = height
	return shape
