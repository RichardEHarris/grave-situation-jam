extends Node

var world : Node3D
var spawn_container : Node3D
var player_colour : Color

var spawn_enemies : bool = false
var spawn_cooldown = 1.0
var current_timer = 0
@export var enemy_count = 0
var max_enemies = 10

const BALL = preload("uid://4hnuvjijwq2b")
const ENEMY = preload("uid://on77vwkf1mvg")

func _process(delta: float) -> void:
	if multiplayer.multiplayer_peer and not is_multiplayer_authority():
		return	
	current_timer -= delta
	if get_players().size() > 0:
		spawn_enemies = true
	if spawn_enemies and current_timer <= 0:
		spawn_enemy()
		current_timer = spawn_cooldown
	

func spawn_enemy():
	if enemy_count >= max_enemies:
		return
	var new_enemy := ENEMY.instantiate()
	#new_enemy.position = Vector3(randf_range(5, 10), 0.1, randf_range(5, 10))
	enemy_count += 1
	new_enemy.label_text = str(enemy_count)
	spawn_container.add_child(new_enemy, true)

@rpc("any_peer")
func shoot_ball(pos, dir, force):
	var new_ball : RigidBody3D = BALL.instantiate()
	new_ball.position = pos + Vector3(0, 1, 0) + (dir * 2)
	spawn_container.add_child(new_ball, true)
	new_ball.apply_central_impulse(dir * force)
	
@rpc("any_peer")
func set_player_colour(player_id: String):
	var player = find_player(player_id)
	player.set_colour()
	print(player.player_colour)

func find_player(id) -> Node:
	var players: = get_players()
	var player = players.find_custom(func(item): return item.name == str(id))
	return players[player]

func get_players() -> Array[Node]:
	var players: Array[Node] = get_tree().get_nodes_in_group("Players")
	return players
	
