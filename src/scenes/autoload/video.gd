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

const PRESETS = [
	{ # Low
		"environment/glow_enabled": false,
		"environment/ss_reflections_enabled": false,
		"environment/ssao_enabled": false,
		"environment/ssao_blur": Environment.SSAO_BLUR_1x1,
		"environment/ssao_quality": Environment.SSAO_QUALITY_LOW,
		"rendering/quality/filters/msaa": Viewport.MSAA_DISABLED,
	}, { # Medium
		"environment/glow_enabled": false,
		"environment/ss_reflections_enabled": false,
		"environment/ssao_enabled": false,
		"environment/ssao_blur": Environment.SSAO_BLUR_1x1,
		"environment/ssao_quality": Environment.SSAO_QUALITY_LOW,
		"rendering/quality/filters/msaa": Viewport.MSAA_2X
	}, { # High
		"environment/glow_enabled": true,
		"environment/ss_reflections_enabled": false,
		"environment/ssao_enabled": true,
		"environment/ssao_blur": Environment.SSAO_BLUR_1x1,
		"environment/ssao_quality": Environment.SSAO_QUALITY_LOW,
		"rendering/quality/filters/msaa": Viewport.MSAA_4X
	}, { # Ultra
		"environment/glow_enabled": true,
		"environment/ss_reflections_enabled": true,
		"environment/ssao_enabled": true,
		"environment/ssao_blur": Environment.SSAO_BLUR_2x2,
		"environment/ssao_quality": Environment.SSAO_QUALITY_MEDIUM,
		"rendering/quality/filters/msaa": Viewport.MSAA_8X
	}
]

func initialize():
	Engine.target_fps = Save.user_data.get("video_fps")
	video_mode()
	video_preset()
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

func video_preset():
	var environment : Environment
	if Game.main.get_node("WorldEnvironment") == null:
		var worldenv = WorldEnvironment.new()
		Game.main.add_child(worldenv)
		environment = worldenv.environment
	else:
		environment = Game.main.get_node("WorldEnvironment").environment
	for setting in PRESETS[Save.user_data.get("video_preset")]:
		var value = PRESETS[Save.user_data.get("video_preset")][setting]
		match setting:
			"environment/glow_enabled":
				environment.glow_enabled = value
			"environment/ss_reflections_enabled":
				environment.ss_reflections_enabled = value
			"environment/ssao_enabled":
				environment.ssao_enabled = value
			"environment/ssao_blur":
				environment.ssao_blur = value
			"environment/ssao_quality":
				environment.ssao_quality = value
			"rendering/quality/filters/msaa":
				get_viewport().msaa = value
