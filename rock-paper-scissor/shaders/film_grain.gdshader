shader_type canvas_item;
uniform float elapsed = 0.0;
uniform float strength = 0.09;
uniform float pixel_size = 2.0;
uniform float frame_rate = 12.0;
uniform float vignette_strength = 0.18;

void fragment() {
	vec2 cell = floor(FRAGCOORD.xy / max(pixel_size, 1.0));
	float frame = floor(elapsed * frame_rate);
	float noise = fract(sin(dot(cell + vec2(frame, -frame), vec2(12.9898, 78.233))) * 43758.5453);
	float vignette = smoothstep(0.25, 0.75, length(UV - vec2(0.5))) * vignette_strength;
	float alpha = strength + vignette;
	COLOR = vec4(vec3(noise * strength / max(alpha, 0.001)), alpha);
}
