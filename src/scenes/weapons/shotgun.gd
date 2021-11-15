extends Spatial

const MAX_DAMAGE = 128

var shot : int = 0
var muzzle_flash = preload("res://particles/weapons/shotgun/muzzle_flash.tscn")

onready var cast : RayCast = get_node("../../Guncast")

func _ready():
	pass

func _process(_delta):
	if not $Animation.is_playing() and not $Tween.is_active():
		if shot > 0:
			$Animation.play("Pump")
			Net.rpc("network_sound", "res://sounds/weapons/shotgun/pump.mp3", "SFX", global_transform.origin)

func primary():
	if not $Animation.is_playing() and not $Tween.is_active():
		var origin = transform.origin
		var degrees = rotation_degrees
		var multiplier = rand_range(0.25, 1)
		$Tween.interpolate_property(self, "translation", origin, Vector3(origin.x, origin.y, origin.z+multiplier), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		$Tween.interpolate_property(self, "translation", Vector3(origin.x, origin.y, origin.z+multiplier), origin, 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		$Tween.interpolate_property(self, "rotation_degrees", degrees, Vector3(degrees.x, degrees.y, degrees.z+multiplier*5), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		$Tween.interpolate_property(self, "rotation_degrees", Vector3(degrees.x, degrees.y, degrees.z+multiplier*5), degrees, 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		$Tween.start()
		shot += 1
		Net.rpc("network_sound", "res://sounds/weapons/shotgun/fire.mp3", "SFX", global_transform.origin)
		if cast.is_colliding():
			var target = cast.get_collider()
			if target.is_in_group("player") or target.is_in_group("dummy"):
				var damage = 30 / cast.global_transform.origin.distance_to(cast.get_collision_point()) * 4
				if damage > MAX_DAMAGE:
					damage = MAX_DAMAGE
				Game.player.hud.hit_enemy(damage)
				target.health -= damage

func secondary():
	pass

func _on_Animation_animation_started(_anim_name):
	pass

func _on_Animation_animation_finished(anim_name):
	if anim_name == "Pump":
		shot -= 1
