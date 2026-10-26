shader_type canvas_item;
uniform float scroll_offset = 0.0;
uniform vec4 pattern_color : source_color = vec4(0.12, 0.20, 0.34, 0.22);
void fragment() {
	vec2 uv = vec2(fract(UV.x + scroll_offset), UV.y);
	COLOR = texture(TEXTURE, uv) * pattern_color;
}
