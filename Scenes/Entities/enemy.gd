extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var label_3d: Label3D = $Label3D
@export var label_text: String

func _ready() -> void:
	if not is_multiplayer_authority():
		#set_process(false)
		set_physics_process(false)
		return
	position = position + Vector3(randf_range(5, 10), 1, randf_range(5, 10))
	
func _process(delta: float) -> void:
	if label_text:
		label_3d.text = label_text

func _physics_process(_delta: float) -> void:
	
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
