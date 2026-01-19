shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0; // center UV
    float dist = length(uv);

    if (dist > 1.0) {
        discard;
    }

    COLOR = texture(TEXTURE, UV);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
