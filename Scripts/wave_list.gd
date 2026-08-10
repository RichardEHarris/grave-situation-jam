extends Node

const WAVE_INTERVAL = 60.0

##(health, size, move_speed, colour, exp)
const ENEMY_LIST := {
	"default" : [2, 1, 2, Color(0.118, 0.078, 0.0, 1.0), 1],
	"large"   : [5, 2, 1, Color(0.361, 0.396, 0.239, 1.0), 5]
	}

##(max_enemies, enemy_types : Array, ratio : Array)
const WAVE_LIST = [
	[30, ["default"], [1.0]],
	[100, ["default"], [1.0]],
	[50, ["default","large"], [0.9, 0.1]]
	]
##(max_enemies, enemy_types, ratio)
func get_wave(time : float) ->Array:
	return WAVE_LIST[clampi(int(time / WAVE_INTERVAL), 0, WAVE_LIST.size()-1)]

##(health, size, move_speed, colour, exp)
func get_random() -> Array:
	var keys = ENEMY_LIST.keys()
	return ENEMY_LIST.get(keys.pick_random())

func get_enemy(id : String) -> Array:
	return ENEMY_LIST.get(id)

func get_random_index(ratios : Array) -> int:
	var random_num := randf()
	for i in range(ratios.size()):
		random_num -= ratios[i]
		if random_num <= 0:
			return i
	return 0
