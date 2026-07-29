extends RigidBody3D
class_name Projectile

var direction : Vector3
var look_update_interval = 0.05
var look_update_timer = 0.0

#region Data titles
const speed = "speed"
const base_damage = "base_damage"
const size = "size"
const lifespan = "lifespan"
const hits = "hits"
const amount = "amount"
const spread_angle = "spread_angle"
const piercing = "piercing"
const gravity = "gravity"
const split = "split"
const split_angle = "split_angle"
const chain = "chain"
const homing = "homing"
const homing_distance = "homing_distance"
#endregion
@export var proj_data = {
	speed : 25,
	base_damage : 1.0,
	size : 1.0,
	lifespan : 3.0,
	hits : 20,
	amount : 1,
	spread_angle : 10,
	piercing : false,
	gravity : true,
	split : 0,
	split_angle: 45,
	chain: false,
	homing : 0,
	homing_distance : 50
}
#TODO damage
enum movement_type{
	straight,
	wiggle
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
	timer.wait_time = proj_data[lifespan]
	timer.timeout.connect(timeout)
	timer.start()
	if not proj_data[gravity]:
		gravity_scale = 0
	#set_collision_mask_value(2, not proj_data[piercing]) #set enemy collision mask.
	
	
func _physics_process(delta: float) -> void:
	look_update_timer -= delta
	if look_update_timer <= 0:
		if proj_data[homing] != 0:
			var closest = Global.find_closest_in(global_position, Global.ENEMY_TAG, proj_data[homing_distance])
			if closest != null:
				smooth_look_at(closest.global_position, proj_data[homing]*40, delta)
		look_forward()
		look_update_timer = look_update_interval
	

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity = direction * proj_data[speed]
	#look_follow(state, transform, position + direction * 2)

func look_forward() -> void:
	var target_position = position + direction
	if global_position.is_equal_approx(target_position):
		return
	look_at(target_position)

func on_collision(body : Node3D):
	if is_queued_for_deletion():
		return
	if body and body.is_in_group(Global.ENEMY_TAG):
		handle_collision.call_deferred(body)
		if is_instance_valid(body):
			body.hit(get_damage())


func handle_collision(body : Node3D):
	proj_data[hits] -= 1
	if proj_data[hits] <= 0:
		queue_free()
	else:
		if not proj_data[piercing] and not proj_data[chain]:
			set_direction(direction.bounce((body.global_position - position).normalized()))
			look_forward()
		if proj_data[split] > 0:
			var split_projectile_data = proj_data.duplicate_deep()
			split_projectile_data[amount] = proj_data[split]
			split_projectile_data[split] = 0
			split_projectile_data[spread_angle] = proj_data[split_angle]
			Global.shoot_projectile(global_position, transform.basis.rotated(Vector3.UP, deg_to_rad(split_projectile_data[spread_angle])), split_projectile_data)
		if proj_data[chain]:
			var closest := Global.find_closest_in(global_position, Global.ENEMY_TAG, INF, 1)
			#print("Hit: " + str(body.label_text) + ", Moving towards: " + str(closest.label_text))
			set_direction((closest.global_position - global_position).normalized())

func set_direction(new_dir : Vector3):
	direction = Vector3(new_dir.x, 0, new_dir.z).normalized()

func timeout() -> void:
	queue_free()
	
func get_capsule_shape(radius : float = 0.5, height :float = 2.0) -> CapsuleShape3D:
	var shape = CapsuleShape3D.new()
	shape.radius = radius
	shape.height = height
	return shape


func smooth_look_at(target_position: Vector3, rotation_speed : float, delta: float) -> void:
	if global_position.is_equal_approx(target_position):
		return
	target_position.y = global_position.y
	#var target_direction : Vector3 = (target_position - global_position).normalized()
	#var max_angle = direction.angle_to(target_direction)
	#var offset = Global.get_angleaxis(clampf(deg_to_rad(rotation_speed) * delta * 60, -max_angle, max_angle))
	#set_direction(basis * offset)
	
	var target_transform = global_transform.looking_at(target_position, Vector3.UP)
	var current_quaternion = global_transform.basis.get_rotation_quaternion()
	var target_quaternion = target_transform.basis.get_rotation_quaternion()
	var next_quaternion = current_quaternion.slerp(target_quaternion, rotation_speed * delta)
	set_direction(Basis(next_quaternion) * Vector3.FORWARD)

func get_damage() -> float:
	return proj_data[base_damage]
