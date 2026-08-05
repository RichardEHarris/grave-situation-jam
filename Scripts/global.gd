extends Node

var world : Node3D
var spawn_container : Node3D
var player_ui : CanvasLayer
var player_menu : Control
var upgrade_ui : CanvasLayer
var upgrade_menu : Control

var spawn_enemies : bool = false
var spawn_cooldown = 0.2
var current_timer = 0
var player_upgrade_count : Dictionary = {}
var upgrade_max : int = 0
var upgrade_interval : int = 10
@export var enemy_count : int = 0
@export var max_enemies : int = 100
@export var kills : int = 0

const PLAYER_TAG = "Players"
const ENEMY_TAG = "Enemy"
const PROJECTILE_TAG = "Projectile"

const ENEMY = preload("uid://on77vwkf1mvg")
const PROJECTILE = preload("uid://dy0vkht00yvfv")
const PLAYER_MATERIAL = preload("uid://nxsn4asxq8gc")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if multiplayer.multiplayer_peer and not is_multiplayer_authority():
		return
	if not get_tree().paused:
		current_timer -= delta
		if get_players().size() > 0:
			spawn_enemies = true
		if spawn_enemies and current_timer <= 0:
			spawn_enemy()
			current_timer = spawn_cooldown
		player_ui.display()
		player_ui.set_kills.rpc(kills, upgrade_interval)

		if kills >= upgrade_interval:
			upgrade_max += 1
			upgrade_interval = int(upgrade_interval * 1.5) + 10
	
	if not upgrade_ui.is_open:
		if get_lowest_upgrade_count() < upgrade_max:
			#print("Upgrade menu opened")
			upgrade_ui.is_open = true
			populate_upgrade_count()
			show_upgrades.rpc()
			pause.rpc()
	else:
		if get_lowest_upgrade_count() == upgrade_max:
			#print("Upgrade menu closed for all clients")
			upgrade_ui.is_open = false
			unpause.rpc()
		

func spawn_enemy():
	if enemy_count >= max_enemies:
		return
	var enemy_data := WaveList.get_random()
	var new_enemy = create_enemy(enemy_data[0],enemy_data[1],enemy_data[2],enemy_data[3])
	enemy_count += 1
	new_enemy.label_text = str(enemy_count)
	spawn_container.add_child(new_enemy, true)

func create_enemy(move_speed, health, colour, size) -> Node:
	var new_enemy := ENEMY.instantiate()
	#new_enemy.position = Vector3(randf_range(5, 10), 0.1, randf_range(5, 10))
	new_enemy.set_data(move_speed, health, colour, size)
	return new_enemy

@rpc("any_peer")
func shoot_projectile(pos : Vector3, basis : Basis, projectile_data : Dictionary):
	#print("Attempting to create "+str(projectile_data[Projectile.amount])+" Projectiles")
	for i in projectile_data[Projectile.amount]:
		var spread = deg_to_rad(projectile_data[Projectile.spread_angle])
		var offset = get_spread_offset_by_count(spread, i)
		var new_proj : RigidBody3D = PROJECTILE.instantiate()
		new_proj.position = pos + Vector3(0, 0.5, 0) + (basis * offset)
		new_proj.set_direction(basis * offset)
		spawn_container.add_child(new_proj, true)
		new_proj.set_data(projectile_data)
		

func find_player(id) -> Node:
	var players: = get_players()
	var player = players.find_custom(func(item): return item.name == str(id))
	return players[player]

func get_players() -> Array[Node]:
	var players: Array[Node] = get_tree().get_nodes_in_group("Players")
	return players

## Get direction rotated by angle in radians
func get_angleaxis(angle : float) -> Vector3:
	return Vector3(sin(angle), 0, -cos(angle))

func get_spread_offset_by_count(spread, count):
		if count % 2 == 1:
			return get_angleaxis(spread * ceil((count+1)/2))
		else:
			return get_angleaxis(spread * -ceil(count/2))

func find_closest_in(origin_pos : Vector3, tag : String, max_distance : float = INF, min_distance : float = 0) -> CharacterBody3D:
	var enemies = get_tree().get_nodes_in_group(tag)
	var closest_tagged: CharacterBody3D = null
	var shortest_distance_squared: float = INF
	
	for tagged in enemies:
		if tagged is CharacterBody3D:
			var distance_squared = origin_pos.distance_squared_to(tagged.global_position)
			if  (distance_squared <= max_distance 
			and distance_squared < shortest_distance_squared 
			and distance_squared > min_distance):
				shortest_distance_squared = distance_squared
				closest_tagged = tagged
	return closest_tagged

@rpc("authority", "call_remote")
func show_upgrades():
	upgrade_ui.display(true)
	

@rpc("any_peer", "call_local")
func pause():
	get_tree().paused = true

@rpc("any_peer","call_local")
func unpause():
	get_tree().paused = false

@rpc("any_peer")
func increment_upgrade():
	add_upgrade_count(multiplayer.get_remote_sender_id())

@rpc("any_peer")
func apply_upgrade(values_to_add : Dictionary):
	var players = get_players()
	for player in players:
		player.add_projectile_data(values_to_add)

@rpc("authority")
func get_upgrade_count(player_id : int) -> int:
	if player_upgrade_count.has(str(player_id)):
		return player_upgrade_count[str(player_id)]
	else:
		player_upgrade_count[str(player_id)] = 0
		return 0

@rpc("authority")
func add_upgrade_count(player_id : int):
	player_upgrade_count[str(player_id)] += 1
	#print(player_id, " : added 1 to upgrade count, Total: ", player_upgrade_count[str(player_id)] )

#TODO handle player leaving or orphaned id
@rpc("authority")
func get_lowest_upgrade_count() -> int:
	if player_upgrade_count.size() == 0:
		return 0
	var lowest = INF
	for player in player_upgrade_count:
		var count = player_upgrade_count[player]
		if count < lowest:
			lowest = count
	#print("From: ", player_upgrade_count.values(), " the lowest is: ", lowest)
	return lowest

func populate_upgrade_count():
	for player in get_players():
		get_upgrade_count(int(player.name))
