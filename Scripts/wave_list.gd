extends Node
##(move_speed, health, colour, size)
const wave_list = [[2, 2, Color(0.118, 0.078, 0.0, 1.0), 1],
[1, 5, Color(0.361, 0.396, 0.239, 1.0), 2]]

func get_random() -> Array:
	return wave_list[randi_range(0, wave_list.size()-1)]
