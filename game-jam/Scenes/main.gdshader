shader_type canvas_item;
uniform float alpha;
uniform float red_multiplier;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 color = texture(screen_texture, UV);
	
	float avg_color = color.r*0.299 + color.g * 0.587 + color.b * 0.114;
	COLOR = vec4(avg_color * red_multiplier, avg_color, avg_color, alpha);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
