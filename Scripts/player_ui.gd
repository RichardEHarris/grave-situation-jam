extends CanvasLayer

@onready var hud: Control = %HUD
@onready var menu: Control = %Menu
@onready var button_leave: Button = %ButtonLeave
@onready var kill_number: Label = %KillNumber
@onready var exp_bar: ProgressBar = %ExpBar
@onready var timer: Label = %Timer

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
func set_hud(kills : int, experience : float, upgrade_interval : int, previous_interval : int, time : float):
	kill_number.text = str(kills)
	exp_bar.value = ((experience - previous_interval) / (upgrade_interval - previous_interval)) * 100
	timer.text = "%10.2f" % [time]
