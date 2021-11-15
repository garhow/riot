extends Node

func initialize():
	Engine.target_fps = Save.user_data.get("video_fps")
	OS.window_fullscreen = Save.user_data.get("video_fullscreen")
