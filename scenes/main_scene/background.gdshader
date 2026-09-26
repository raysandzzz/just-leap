shader_type canvas_item;

// Scrolling speed in X and Y directions
uniform vec2 motion_speed = vec2(1.0, 1.0);

void fragment() {
    // Offset UV coordinates over time
    vec2 moving_uv = UV - (TIME * motion_speed);
    
    // repeat_enable forces texture wrapping, filter_nearest keeps crisp pixel art
    COLOR = texture(TEXTURE, moving_uv);
}