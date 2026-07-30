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
		populate_cards()
	else:
		upgrade_menu.hide()
		clear_cards()

func populate_cards():
	for i in range(3):
		var new_card = UPGRADE_CARD.instantiate()
		var values = UpgradeList.get_random()
		new_card.set_values(values[0],values[1],values[2])
		upgrade_container.add_child(new_card)

func clear_cards():
	for child in upgrade_container.get_children():
		upgrade_container.remove_child(child)
