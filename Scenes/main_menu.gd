extends CanvasLayer

@onready var button_join: Button = %ButtonJoin
@onready var button_quit: Button = %ButtonQuit

const LEVEL_1 = preload("uid://lgcdgo0015kc") #World1
const PLAYER = preload("uid://x25d2r17ely6")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_join.pressed.connect(on_join)
	button_quit.pressed.connect(func(): get_tree().quit())
	
	if OS.has_feature("server"):
		Network.start_server()
		add_world()
		hide()

func on_join():
	Network.join_server()
	add_world()
	hide()

func add_world():
	var new_world = LEVEL_1.instantiate()
	get_tree().current_scene.add_child.call_deferred(new_world)
