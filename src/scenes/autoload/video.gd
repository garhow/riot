extends Node

const RESOLUTIONS = [
	Vector2(1280, 720),
	Vector2(1366, 768),
	Vector2(1600, 900),
	Vector2(1920, 1080),
	Vector2(2560, 1440),
	Vector2(3200, 1800),
	Vector2(3840, 2160),
]

func _ready():
	pass

func initialize():
	Engine.target_fps = Save.user_data.get("video_fps")
	video_mode()
	OS.window_size = RESOLUTIONS[Save.user_data.get("video_resolution")]

func video_mode():
	if Save.user_data.get("video_mode") == 0:
		OS.window_borderless = false
		OS.window_fullscreen = false
	elif Save.user_data.get("video_mode") == 1:
		OS.window_borderless = false
		OS.window_fullscreen = true
	elif Save.user_data.get("video_mode") == 2:
		OS.window_borderless = true
		OS.window_fullscreen = true
