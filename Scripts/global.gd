extends Node

var world : Node3D
var spawn_container : Node3D
var player_ui : CanvasLayer
var player_menu: Control

var spawn_enemies : bool = false
var spawn_cooldown = 0.5
var current_timer = 0
@export var enemy_count : int = 0
@export var max_enemies : int = 20
@export var kills : int = 0

const PLAYER_TAG = "Players"
const ENEMY_TAG = "Enemy"
const PROJECTILE_TAG = "Projectile"


const ENEMY = preload("uid://on77vwkf1mvg")
const PROJECTILE = preload("uid://dy0vkht00yvfv")
const PLAYER_MATERIAL = preload("uid://nxsn4asxq8gc")


func _process(delta: float) -> void:
	if multiplayer.multiplayer_peer and not is_multiplayer_authority():
		return
	current_timer -= delta
	if get_players().size() > 0:
		spawn_enemies = true
	if spawn_enemies and current_timer <= 0:
		spawn_enemy()
		current_timer = spawn_cooldown
	player_ui.display()
	player_ui.set_kills.rpc(kills)
	

func spawn_enemy():
	if enemy_count >= max_enemies:
		return
	var new_enemy := ENEMY.instantiate()
	#new_enemy.position = Vector3(randf_range(5, 10), 0.1, randf_range(5, 10))
	enemy_count += 1
	new_enemy.label_text = str(enemy_count)
	spawn_container.add_child(new_enemy, true)
	
@rpc("any_peer")
func shoot_projectile(pos : Vector3, dir : Vector3, projectile_data : Dictionary):
	var new_proj : RigidBody3D = PROJECTILE.instantiate()
	new_proj.set_data(projectile_data)
	new_proj.position = pos + Vector3(0, 0.5, 0) + dir
	new_proj.set_direction(dir)
	#new_ball.add_to_group(PROJECTILE_TAG)
	spawn_container.add_child(new_proj, true)
	#new_proj.look_at(new_proj.position + dir)
	#new_proj.apply_central_impulse(dir * force)
	

func find_player(id) -> Node:
	var players: = get_players()
	var player = players.find_custom(func(item): return item.name == str(id))
	return players[player]

func get_players() -> Array[Node]:
	var players: Array[Node] = get_tree().get_nodes_in_group("Players")
	return players
	
