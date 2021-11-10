extends Spatial

var shot : int = 0
var muzzle_flash = preload("res://particles/weapons/shotgun/muzzle_flash.tscn")

onready var cast : RayCast = get_node("../../Guncast")

func _ready():
	pass

func _process(_delta):
	pass

func primary():
	if not $Animation.is_playing():
		$Animation.play("Fire")
		var flash = muzzle_flash.instance()
		flash.emitting = true
		if cast.is_colliding():
			var target = cast.get_collider()
			if target.is_in_group("player") or target.is_in_group("dummy"):
				var damage = 30 / cast.global_transform.origin.distance_to(cast.get_collision_point()) * 4
				Game.player.hud.hit_enemy(damage)
				target.health -= damage

func secondary():
	pass

func _on_Animation_animation_started(_anim_name):
	pass

func _on_Animation_animation_finished(anim_name):
	if anim_name == "Fire":
		shot += 1
	elif anim_name == "Pump":
		shot -= 1
	if shot > 0:
		$Animation.play("Pump")
