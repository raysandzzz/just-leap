shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 current_pixel = SCREEN_UV * screen_size;
    vec2 screen_center = screen_size * 0.5;

    // Exact distance in pixels from center to corner (0, 0)
    float max_radius = length(screen_center);
    float current_radius = progress * max_radius;

    float dist = distance(current_pixel, screen_center);

    if (dist > current_radius) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}