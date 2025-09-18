// ghostty cursor smear shader
precision highp float;
uniform sampler2D source;
uniform sampler2D previous;
uniform vec2 resolution;
uniform float cursor_x;
uniform float cursor_y;
uniform float cursor_width;
uniform float cursor_height;
out vec4 out_color;

void main() {
    vec2 uv = gl_FragCoord.xy / resolution;
    vec4 color = texture(source, uv);
    vec4 prev_color = texture(previous, uv);
    
    // Cursor position and size
    vec2 cursor_pos = vec2(cursor_x, cursor_y) / resolution;
    vec2 cursor_size = vec2(cursor_width, cursor_height) / resolution;
    
    // Calculate distance from cursor
    float dist = length((uv - cursor_pos) / cursor_size);
    
    // Apply smear effect - blend between current and previous frame
    float blend_factor = 0.85; // Higher values create longer smear effect
    
    if (dist < 2.0) {
        // More smearing near the cursor
        float smear_strength = max(0.0, 1.0 - dist / 2.0) * 0.5;
        color = mix(color, prev_color, blend_factor * smear_strength);
    }
    
    out_color = color;
}