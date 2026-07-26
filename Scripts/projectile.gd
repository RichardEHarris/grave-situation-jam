extends RigidBody3D
class_name Projectile

var direction : Vector3
var look_update_interval = 0.2
var look_update_timer = 0.0
@export var proj_data = {
  "speed" : 25,
  "base_damage" : 1.0,
  "size" : 1.0,
  "lifespan" : 3.0,
  "hits" : 1,
  "amount" : 1,
  "piercing" : true,
  "gravity" : true,
  "homing" : false,
  "spread_angle" : 10
}
enum movement_type{
	straight
}

@onready var projectile_collision: Area3D = $ProjectileCollision
@onready var timer: Timer = $Timer
@onready var physics_shape: CollisionShape3D = $PhysicsShape
@onready var hitbox: CollisionShape3D = $ProjectileCollision/Hitbox

func set_data(new_data : Dictionary) -> void:
	proj_data = new_data
	

func _ready() -> void:
	add_to_group(Global.PROJECTILE_TAG)
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
		
		return
	projectile_collision.body_entered.connect(on_collision)
	timer.wait_time = proj_data["lifespan"]
	timer.timeout.connect(timeout)
	timer.start()
	if not proj_data["gravity"]:
		gravity_scale = 0
	set_collision_mask_value(2, not proj_data["piercing"]) #set enemy collision mask.
	if proj_data["amount"] > 1:
		pass
		#TODO: Spawn in Extra Projectiles
	
func _physics_process(delta: float) -> void:
	look_update_timer -= delta
	if look_update_timer <= 0:
		look_forward()
		look_update_timer = look_update_interval
	

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity = direction * proj_data["speed"]
	
	
	#look_follow(state, transform, position + direction * 2)

func look_forward() -> void:
	#var current_rotation = transform.basis.get_rotation_quaternion().y
	#var target_rotation = direction.angle_to(Vector3.FORWARD)
	#var rotation_required = target_rotation - current_rotation
	#print("Direction: " , direction , " Current: ",rad_to_deg(current_rotation), " Target: " , rad_to_deg(target_rotation), " Required: " , rad_to_deg(rotation_required))
	#transform.basis = transform.basis.rotated(Vector3.UP, rotation_required)
	look_at(position + direction)

func on_collision(body : Node3D):
	if is_queued_for_deletion():
		return
	if body and body.is_in_group(Global.ENEMY_TAG):
		handle_collision.call_deferred(body)

func handle_collision(body : Node3D):
	if is_instance_valid(body):
		body.queue_free()
	proj_data["hits"] -= 1
	if proj_data["hits"] <= 0:
		queue_free()
	elif not proj_data["piercing"]:
		set_direction(direction.bounce((body.global_position - position).normalized()))
		look_forward()
		

func set_direction(new_dir : Vector3):
	direction = Vector3(new_dir.x, 0, new_dir.z).normalized()

func timeout() -> void:
	queue_free()
	
func get_capsule_shape(radius : float = 0.5, height :float = 2.0) -> CapsuleShape3D:
	var shape = CapsuleShape3D.new()
	shape.radius = radius
	shape.height = height
	return shape
