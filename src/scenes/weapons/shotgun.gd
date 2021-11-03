extends Spatial

var shot : int = 0

func _ready():
	pass

func _process(_delta):
	pass

func primary():
	$Animation.play("Fire")
	

func secondary():
	pass

func pump():
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
