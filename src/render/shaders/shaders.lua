local shaders = {
    gray = {
        uniforms = {},
        code = [[
            vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
                vec4 tex_color = Texel(tex, tex_coords);
                float gray = (tex_color.r + tex_color.g + tex_color.b) / 3;
                return vec4(gray, gray, gray, tex_color.a) * color;
            }
        ]]
    },
    checker = {
        uniforms = {
            {name = "time", default = 0.0}
        },
        code = [[
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
    },
    node_border = {
        uniforms = {
            {name = "borderColor", default = {1, 1, 1, 1}},
            {name = "borderWidth", default = 2},
            {name = "glowIntensity", default = 0.5}
        },
        code = [[
            extern vec4 borderColor;
            extern float borderWidth;
            extern float glowIntensity;

            vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
                vec4 tex_color = Texel(tex, tex_coords);
                vec2 size = love_ScreenSize.xy;
                vec2 pixel = 1.0 / size;
                vec2 pos = screen_coords / size;
                
                float border = 0.0;
                for(float i = 1.0; i <= borderWidth; i++) {
                    border += Texel(tex, tex_coords + vec2(i, 0) * pixel).a;
                    border += Texel(tex, tex_coords - vec2(i, 0) * pixel).a;
                    border += Texel(tex, tex_coords + vec2(0, i) * pixel).a;
                    border += Texel(tex, tex_coords - vec2(0, i) * pixel).a;
                }
                
                border = min(border / (4.0 * borderWidth), 1.0);
                float glow = border * glowIntensity;
                
                return mix(tex_color, borderColor, glow) * color;
            }
        ]]
    },
    noise = {
        uniforms = {
            {name = "noiseScale", default = 1.0},
            {name = "noiseIntensity", default = 0.1},
            {name = "time", default = 0.0}
        },
        code = [[
            extern float noiseScale;
            extern float noiseIntensity;
            extern float time;

            float random(vec2 st) {
                return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
            }

            vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
                vec4 tex_color = Texel(tex, tex_coords);
                vec2 noise_coords = screen_coords * noiseScale + time;
                float noise = random(noise_coords) * noiseIntensity;
                return tex_color * (1.0 + noise) * color;
            }
        ]]
    },
    shimmer = {
        uniforms = {
            {name = "shimmerColor", default = {1, 1, 1, 0}},
            {name = "shimmerSpeed", default = 2.0},
            {name = "shimmerWidth", default = 0.2},
            {name = "frequency", default = 10.0},
            {name = "time", default = 0.0}
        },
        code = [[
            extern vec4 shimmerColor;
            extern float shimmerSpeed;
            extern float shimmerWidth;
            extern float frequency;
            extern float time;

            vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
                vec4 tex_color = Texel(tex, tex_coords);
                vec2 pos = screen_coords / love_ScreenSize.xy;
                float shimmer = sin(pos.x * frequency + time * shimmerSpeed) * shimmerWidth;
                return mix(tex_color, shimmerColor, shimmer) * color;
            }
        ]]
    },
    outline = {
        uniforms = {
            {name = "outlineColor", default = {0, 0, 0, 1}},
            {name = "outlineWidth", default = 2}
        },
        code = [[
            extern float outlineWidth;
            extern vec4 outlineColor;

            vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 pixel = Texel(texture, texture_coords);
            if (pixel.a > 0.0) {
                return pixel * color;
            }

            float radius = outlineWidth / love_ScreenSize.x;
            for (float x = -radius; x <= radius; x += radius / 2.0) {
                for (float y = -radius; y <= radius; y += radius / 2.0) {
                    vec2 offset = vec2(x, y);
                    vec4 neighbor = Texel(texture, texture_coords + offset);
                    if (neighbor.a > 0.0) {
                        return outlineColor;
                    }
                }
            }

            return pixel;
        }
        ]]
    },
    impact = {
        uniforms = {
            {name = "impactColor", default = {1, 0, 0, 1}},
            {name = "impactIntensity", default = 0.5},
            {name = "time", default = 0.0}
        },
        code = [[
            extern vec4 impactColor;
            extern float impactIntensity;
            extern float time;

            vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
                vec4 tex_color = Texel(tex, tex_coords);
                float pulse = sin(time * 10.0) * impactIntensity;
                return mix(tex_color, impactColor, pulse) * color;
            }
        ]]
    },
    wobble = {
        uniforms = {
            {name = "time", default = 0.0},
            {name = "amount", default = 0.01},
            {name = "frequency", default = 10.0},
            {name = "speed", default = 3},
            {name = "quadInfo", default = {0.0, 0.0, 1.0, 1.0}}
        },
        code = [[
        extern float time;
        extern float amount;
        extern float frequency;
        extern float speed;
        extern vec4 quadInfo;

        vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {

            // Calculate normalized coordinates within the quad
            vec2 normalizedCoords = (tex_coords - quadInfo.xy) / quadInfo.zw;
            
            // Calculate wobble amount but don't apply it yet
            vec2 wobbleOffset = vec2(
                sin(time * speed + normalizedCoords.y * frequency) * amount,
                cos(time * speed + normalizedCoords.x * frequency) * amount
            );
            
            // Calculate potential new coordinates
            vec2 wobbledNormalized = normalizedCoords + wobbleOffset;
            
            // Only apply wobble if it keeps us inside the quad
            if (wobbledNormalized.x >= 0.0 && wobbledNormalized.x <= 1.0 &&
                wobbledNormalized.y >= 0.0 && wobbledNormalized.y <= 1.0) {
                vec2 wobbledCoords = quadInfo.xy + wobbledNormalized * quadInfo.zw;
                return Texel(tex, wobbledCoords) * color;
            }
            
            // If wobble would take us outside, use original coordinate
            return Texel(tex, tex_coords) * color;
        }
    ]]
    }
}

return shaders 