extends CharacterBody3D

var move_speed = 2.0
var min_spawn_dist = 25.0
var max_spawn_dist = 40.0

var health : float = 2
var iframes : float = 0.1
var original_colour : Color
#@onready var enemy_collision: Area3D = $EnemyCollision
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var label_3d: Label3D = $Label3D
@export var label_text: String

func _enter_tree() -> void:
	#print("Initial: " + str(position))
	var random_direction = Vector3(randf_range(-1,1),0,randf_range(-1,1)).normalized()
	var spawn_location = random_direction * randf_range(min_spawn_dist, max_spawn_dist)
	position = position + spawn_location
	#print("position: " + str(position))

func _ready() -> void:
	add_to_group(Global.ENEMY_TAG)
	var material = mesh.get_surface_override_material(0)
	mesh.set_surface_override_material(0, material.duplicate())
	original_colour = material.albedo_color
	if not is_multiplayer_authority():
		#set_process(false)
		set_physics_process(false)
		return
	#enemy_collision.body_entered.connect(on_collision)
	
#func on_collision(body : Node3D):
	#print(body.get_groups())
	#if body.is_in_group(Global.PROJECTILE_TAG):
	#	queue_free()

func _process(_delta: float) -> void:
	if label_text:
		label_3d.text = label_text
	pass

func _physics_process(_delta: float) -> void:
	if is_queued_for_deletion():
		return
	var players = Global.get_players()
	var closest = null
	var closest_dist = 1000
	for player in players:
		var dist = position.distance_to(player.position)
		if dist < closest_dist:
			closest = player
			closest_dist = dist
	if closest:
		var look := position.direction_to(closest.position)
		var direction := look
		if direction:
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func hit(damage : float):
	take_damage(damage)
	set_collision_layer_value(2, false)
	remove_from_group(Global.ENEMY_TAG)
	add_to_group("hit_enemies")
	create_timer(restore_hitable, iframes)

func restore_hitable():
	set_collision_layer_value(2, true)
	add_to_group(Global.ENEMY_TAG)
	reset_colour.rpc()

func take_damage(damage : float):
	damage_flash.rpc()
	health -= damage
	if health <= 0:
		queue_free()

@rpc("authority","call_local")
func damage_flash():
	var material := mesh.get_surface_override_material(0)
	material.albedo_color = Color.TOMATO

@rpc("authority","call_local")
func reset_colour():
	var material := mesh.get_surface_override_material(0)
	material.albedo_color = original_colour

func create_timer(function_to_connect, wait_time):
	var temp_timer := Timer.new()
	add_child(temp_timer)
	temp_timer.wait_time = wait_time
	temp_timer.one_shot = true
	temp_timer.start()
	temp_timer.timeout.connect(function_to_connect)

func set_data(movement_speed : float, health_points : float, colour : Color, size : float):
	move_speed = movement_speed
	health = health_points
	original_colour = colour
	set_size(size)
	set_colour.rpc.call_deferred(colour)
	

@rpc("any_peer", "call_local")
func set_colour(colour : Color):
	var material := mesh.get_surface_override_material(0)
	material.albedo_color = colour
	original_colour = colour

func set_size(size):
	transform = transform.scaled(Vector3.ONE * size)

func _exit_tree() -> void:
	Global.enemy_count -= 1
	Global.kills += 1
