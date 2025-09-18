// ghostty cursor blaze shader (no trail)
precision highp float;
uniform sampler2D source;
uniform vec2 resolution;
uniform float time;
uniform float cursor_x;
uniform float cursor_y;
uniform float cursor_width;
uniform float cursor_height;
out vec4 out_color;

void main() {
    vec2 uv = gl_FragCoord.xy / resolution;
    vec4 color = texture(source, uv);
    
    // Cursor position and size
    vec2 cursor_pos = vec2(cursor_x, cursor_y) / resolution;
    vec2 cursor_size = vec2(cursor_width, cursor_height) / resolution;
    
    // Calculate distance from cursor
    float dist = length((uv - cursor_pos) / cursor_size);
    
    // Create blaze effect
    float blaze = 0.0;
    if (dist < 1.0) {
        blaze = (1.0 - dist) * 0.5 * (sin(time * 4.0) * 0.25 + 0.75);
    }
    
    // Apply blaze effect
    color.rgb += vec3(1.0, 0.7, 0.3) * blaze;
    
    out_color = color;
}