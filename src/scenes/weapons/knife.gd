extends Spatial

onready var cast : RayCast = get_node("../../Meleecast")

func _ready():
	pass

func primary():
	if not $Animation.is_playing():
		$Animation.play("Slash")
		if cast.is_colliding():
			var target = cast.get_collider()
			if target.is_in_group("player") or target.is_in_group("dummy"):
				target.health -= 20

func secondary():
	if not $Animation.is_playing():
		$Animation.play("Stab")
		if cast.is_colliding():
			var target = cast.get_collider()
			if target.is_in_group("player") or target.is_in_group("dummy"):
				target.health -= 60
