extends KinematicBody
class_name Peer

var velocity : Vector3

func update(t : Vector3, ry : float, hrx : float, vel : Vector3):
	translation = t
	transform.basis = Basis(Vector3(rotation.x, ry, rotation.z))
	get_node("Head").rotation.x = hrx
	velocity = vel
