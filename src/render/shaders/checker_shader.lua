return [[
    extern float time;
    vec3 color = vec3(0.1, 0, 0.09); // Custom bright color
    float size = 120; // 90

    // Checkerboard pattern function
    float checkerboard(vec2 coord, float size) {
        vec2 pos = floor(coord / size); 
        return mod(pos.x + pos.y, 2.0);
    }

    // Effect function with sine distortion
    vec4 effect(vec4 baseColor, Image texture, vec2 texture_coords, vec2 screen_coords) {
        // Apply sine distortion to the coordinates
        float sineDistortion = sin(screen_coords.y * 0.01 + time * 0.5) * 10.0; // Adjust sine wave frequency and amplitude
        vec2 distortedCoord = screen_coords + vec2(sineDistortion, 0.0) + time * 20;

        // Generate the checkerboard pattern with distorted coordinates
        float c = checkerboard(distortedCoord, size);

        // Mix gray with the custom color based on the checkerboard pattern
        vec3 gray = mix(vec3(0.15, 0.01, 0.2), color, c); 
        return vec4(vec3(gray), 1.0);
    }
]]
