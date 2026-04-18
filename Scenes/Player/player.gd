extends CharacterBody3D

@export var sensitivity: float = 0.002
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera_3d: Camera3D = %Camera3D
@onready var head: Node3D = %Head

@onready var menu: Control = %Menu
@onready var button_leave: Button = %ButtonLeave


func _enter_tree() -> void:
	set_multiplayer_authority(int(name))

func _ready():
	menu.hide()
	add_to_group("Players")
	
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
		return
	
	camera_3d.current = true
	button_leave.pressed.connect(func(): Network.leave_server())
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('menu'):
		if menu.visible == false:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			menu.show()
		else:
			menu.hide()
		

#func _unhandled_input(event: InputEvent) -> void:
#	if not is_multiplayer_authority():
#		return
#	if event is InputEventMouseMotion:
#		head.rotate_y(-event.relative.x * sensitivity)
#		camera_3d.rotate_x(-event.relative.y * sensitivity)
#		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
