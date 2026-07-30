extends PanelContainer
@onready var title: RichTextLabel = %Title
@onready var descripton: RichTextLabel = %Descripton
@onready var button_select: Button = %ButtonSelect

var title_text = ""
var description_text = ""
var values_to_add = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_select.pressed.connect(select)
	title.clear()
	title.append_text(title_text)
	descripton.clear()
	descripton.append_text(description_text)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_values(new_title : String, new_description : String, values : Dictionary):
	title_text = new_title
	description_text = new_description
	values_to_add = values

func select():
	Global.upgrade_ui.display(false)
	Global.increment_upgrade.rpc_id(1, get_multiplayer_authority())
	Global.apply_upgrade(values_to_add)
