extends Spatial

const MAX_DAMAGE = 48
const MIN_DAMAGE = 8

onready var cast : RayCast = get_node("../../Guncast")

func primary():
	if not $Animation.is_playing() and not $Tween.is_active():
		var origin = transform.origin
		var degrees = rotation_degrees
		var multiplier = rand_range(0.5, 2)
		$Tween.interpolate_property(self, "translation", Vector3(origin.x, origin.y+multiplier/4, origin.z+multiplier), origin, 0.1, Tween.TRANS_SINE, Tween.TRANS_SINE)
		$Tween.interpolate_property(self, "rotation_degrees", Vector3(degrees.x, degrees.y, degrees.z+multiplier*-10), degrees, 0.1, Tween.TRANS_SINE, Tween.TRANS_SINE)
		$Tween.start()
		Net.rpc("network_sound", "res://sounds/weapons/glock18/fire.mp3", "SFX", global_transform.origin)
		if cast.is_colliding():
			var target = cast.get_collider()
			if target.is_in_group("player") or target.is_in_group("dummy"):
				print(cast.global_transform.origin.distance_to(cast.get_collision_point()))
				var damage = MAX_DAMAGE
				Game.player.hud.hit_enemy(damage)
				target.health -= damage

func secondary():
	pass
