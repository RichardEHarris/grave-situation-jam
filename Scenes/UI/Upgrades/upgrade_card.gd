extends PanelContainer
@onready var title: RichTextLabel = %Title
@onready var descripton: RichTextLabel = %Descripton
@onready var button_select: Button = %ButtonSelect



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_select.pressed.connect(select)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func select():
	print("Button Pressed")
	Global.upgrade_ui.display(false)
	Global.increment_upgrade.rpc_id(1, get_multiplayer_authority())
