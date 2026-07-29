extends CharacterBody3D

@export var player_colour : Color
@export var angle_offset = -15.0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var player_material : StandardMaterial3D 

@onready var camera_3d: Camera3D = %Camera3D
@onready var head: Node3D = %Head
@onready var hat: MeshInstance3D = $"Head/Wizard Hat/Cone"

@onready var player_collision: Area3D = $PlayerCollision

var projectile : Projectile

@rpc("any_peer","call_local")
func sync():
	if not is_multiplayer_authority():
		return
	set_colour.rpc(player_colour)

func _enter_tree() -> void:
	set_multiplayer_authority(int(name))
	player_material = Global.PLAYER_MATERIAL.duplicate()
	projectile = Projectile.new()
	if not is_multiplayer_authority():
		return
	player_colour = Color(randf(), randf(), randf(), 255)

func _ready():
	add_to_group(Global.PLAYER_TAG)
	hat.set_surface_override_material(0, player_material)
	#print(str(multiplayer.get_unique_id()) + ": " + str(get_path()))
	sync.rpc.call_deferred()
	
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
		return
	
	position = position + Vector3(randf_range(0, 5), 1, randf_range(0, 5))
	camera_3d.current = true
	Global.player_ui.button_leave.pressed.connect(func(): Network.leave_server())
	Global.player_ui.display()
	player_collision.body_entered.connect(on_collision)
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('menu'):
		if Global.player_menu.visible == false:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Global.player_menu.show()
		else:
			Global.player_menu.hide()
		#self.player_colour = Color(randf(), randf(), randf(), 255)
	if Input.is_action_just_pressed("shoot"):
		shoot()
		set_colour.rpc(player_colour)
		

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		var screen_size = get_viewport().get_visible_rect().size
		var half_screen = screen_size/2
		var mouse_pos = event.position
		var relative_location = Vector3(mouse_pos.x - half_screen.x, 0, mouse_pos.y - half_screen.y)
		head.look_at(relative_location + transform.origin)
		head.rotate(Vector3(1,0,0), deg_to_rad(angle_offset))
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		#head.look_at(direction + transform.origin)
		#head.rotate(Vector3(1,0,0), deg_to_rad(angle_offset))
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()

@rpc("authority","call_local")
func set_colour(colour : Color):
	#print(str(multiplayer.get_unique_id()) + ": colour: "+str(player_colour))
	var material = hat.get_surface_override_material(0)
	material.albedo_color = colour

func shoot():
	var direction := head.transform.basis
	var projectile_data := projectile.proj_data.duplicate_deep()
	Global.shoot_projectile.rpc_id(1, global_position, direction, projectile_data)

func on_collision(body : Node3D):
	if body.is_in_group(Global.ENEMY_TAG):
		#TODO add player health handling here
		print(name+": Ouch")
