extends Control

func _ready():
	pass

func hit_enemy(damage : int):
	$Combat/DamageIndicator.text = str(damage)
	$Tween.interpolate_property($Combat/DamageIndicator, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), 2, Tween.EASE_IN, Tween.EASE_OUT)
	$Tween.interpolate_property($Combat/Crosshair, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 100), 2.4, Tween.EASE_IN, Tween.EASE_OUT)
	$Tween.start()
