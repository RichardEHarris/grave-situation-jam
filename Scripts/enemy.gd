extends CharacterBody3D

const SPEED = 2.0
var min_spawn_dist = 25.0
var max_spawn_dist = 40.0

#@onready var enemy_collision: Area3D = $EnemyCollision
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
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func hit():
	#TODO Damage and health handling here
	queue_free()
	set_collision_layer_value(2, false)
	remove_from_group(Global.ENEMY_TAG)
	add_to_group("hit_enemies")
	var temp_timer := Timer.new()
	add_child(temp_timer)
	temp_timer.wait_time = 0.2
	temp_timer.one_shot = true
	temp_timer.start()
	temp_timer.timeout.connect(restore_hitable)

func restore_hitable():
	print("Enemy hittable")
	set_collision_layer_value(2, true)
	add_to_group(Global.ENEMY_TAG)

func _exit_tree() -> void:
	Global.enemy_count -= 1
	Global.kills += 1
