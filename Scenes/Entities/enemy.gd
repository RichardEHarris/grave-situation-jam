extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(_delta: float) -> void:
	var players = Global.get_players()
	var closest = null
	var closest_dist = 1000
	for player in players:
		var dist = position.distance_to(player.position)
		if dist < closest_dist:
			closest = player
			closest_dist = dist
	var look := position.direction_to(closest.position)
	var direction := look
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
