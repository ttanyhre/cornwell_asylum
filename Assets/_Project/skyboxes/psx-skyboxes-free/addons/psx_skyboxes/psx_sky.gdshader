shader_type sky;
// A sky's cubemap, unfiltered so its dithered pixels stay sharp, turned `rotation` degrees about
// the vertical and scaled by `energy`.

uniform samplerCube cubemap : source_color, filter_nearest;
uniform float rotation : hint_range(-180.0, 180.0) = 0.0;
uniform float energy : hint_range(0.0, 4.0) = 1.0;

void sky() {
	float a = radians(rotation);
	vec3 d = vec3(EYEDIR.x * cos(a) - EYEDIR.z * sin(a), EYEDIR.y, EYEDIR.x * sin(a) + EYEDIR.z * cos(a));
	COLOR = texture(cubemap, d).rgb * energy;
}
