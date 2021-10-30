extends Node
class_name Peer

var velocity : Vector3

onready var body = get_node("Body")

func update(t : Vector3, ry : float, hrx : float, vel : Vector3, f : bool):
	body.translation = t
	body.transform.basis = Basis(Vector3(body.rotation.x, ry, body.rotation.z))
	body.get_node("Head").rotation.x = hrx
	body.get_parent().velocity = vel
