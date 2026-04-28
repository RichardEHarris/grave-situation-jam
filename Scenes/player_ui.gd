extends CanvasLayer

@onready var hud: Control = %HUD
@onready var menu: Control = %Menu
@onready var button_leave: Button = %ButtonLeave
@onready var kill_number: Label = %KillNumber

func _ready() -> void:
	menu.hide()
	hud.hide()
	Global.player_ui = self
	Global.player_menu = menu

func display(do = true):
	if do:
		hud.show()
	else:
		hud.hide()

@rpc("call_local")
func set_kills(kills : int):
	kill_number.text = str(kills)
