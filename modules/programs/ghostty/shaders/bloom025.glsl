// ghostty bloom shader with 0.25 strength
precision highp float;
uniform sampler2D source;
uniform vec2 resolution;
out vec4 out_color;

void main() {
    vec2 uv = gl_FragCoord.xy / resolution;
    vec4 color = texture(source, uv);
    
    // Bloom parameters
    float bloom_strength = 0.25;
    float bloom_radius = 0.005;
    
    // Sample neighboring pixels for bloom effect
    vec4 bloom = vec4(0.0);
    for(int x = -2; x <= 2; x++) {
        for(int y = -2; y <= 2; y++) {
            vec2 offset = vec2(float(x), float(y)) * bloom_radius;
            bloom += texture(source, uv + offset);
        }
    }
    
    // Average the bloom samples
    bloom /= 25.0;
    
    // Apply bloom to the original color
    out_color = mix(color, bloom, bloom_strength);
}