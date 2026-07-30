extends CanvasLayer
const UPGRADE_CARD = preload("uid://cxt3858tu3t34")
@onready var upgrade_container: HBoxContainer = %UpgradeContainer
@onready var upgrade_menu: Control = $UpgradeMenu
var is_open = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upgrade_menu.hide()
	Global.upgrade_ui = self
	Global.upgrade_menu = upgrade_menu

func display(do = true):
	is_open = do
	if do:
		upgrade_menu.show()
	else:
		upgrade_menu.hide()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
