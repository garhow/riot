extends KinematicBody
class_name Peer

var velocity : Vector3

func update(t : Vector3, ry : float, hrx : float, vel : Vector3):
	$Tween.interpolate_property(self, "translation", translation, t, Net.HOST_RATE, Tween.TRANS_LINEAR)
	$Tween.interpolate_property(self, "transform:basis", transform.basis, Basis(Vector3(rotation.x, ry, rotation.z)), Net.HOST_RATE, Tween.TRANS_LINEAR)
	$Tween.start()
	get_node("Head").rotation.x = hrx
	velocity = vel
