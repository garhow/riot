shader_type canvas_item;

uniform float blur_amount = 0.0;

void fragment() {
	COLOR.rgba = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount).rgba;
}