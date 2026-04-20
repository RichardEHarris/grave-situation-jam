extends Node

var world : Node3D
var spawn_container : Node3D

const BALL = preload("uid://4hnuvjijwq2b")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@rpc("any_peer")
func shoot_ball(pos, dir, force):
	var new_ball : RigidBody3D = BALL.instantiate()
	new_ball.position = pos + Vector3(0, 1, 0) + (dir * 2)
	spawn_container.add_child(new_ball, true)
	new_ball.apply_central_impulse(dir * force)
