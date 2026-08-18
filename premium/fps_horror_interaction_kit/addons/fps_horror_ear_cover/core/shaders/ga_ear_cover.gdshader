shader_type canvas_item;

uniform float ear_value : hint_range(0.0, 1.0) = 0.0;
uniform float center_opening : hint_range(0.0, 0.5) = 0.15;
uniform vec4 dark_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 flesh_color : source_color = vec4(0.18, 0.03, 0.03, 1.0);

void fragment() {
	vec2 centered = UV - vec2(0.5, 0.5);
	centered.x *= 1.15;
	float dist = length(centered);
	float hole = smoothstep(center_opening, center_opening + 0.22, dist);
	float hands = clamp(ear_value * hole, 0.0, 1.0);
	vec3 col = mix(dark_color.rgb, flesh_color.rgb, hole * 0.45);
	COLOR = vec4(col, hands);
}
