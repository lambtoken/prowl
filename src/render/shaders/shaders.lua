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
            {name = "checkerSize", default = 32},
            {name = "color1", default = {0.2, 0.2, 0.2, 1}},
            {name = "color2", default = {0.3, 0.3, 0.3, 1}}
        },
        code = [[
            extern float checkerSize;
            extern vec4 color1;
            extern vec4 color2;

            vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
                vec2 pos = screen_coords / checkerSize;
                bool isEven = mod(floor(pos.x) + floor(pos.y), 2.0) == 0.0;
                return isEven ? color1 : color2;
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
            extern vec4 outlineColor;
            extern float outlineWidth;

            vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
                vec4 tex_color = Texel(tex, tex_coords);
                vec2 size = love_ScreenSize.xy;
                vec2 pixel = 1.0 / size;
                
                float outline = 0.0;
                for(float i = 1.0; i <= outlineWidth; i++) {
                    outline += Texel(tex, tex_coords + vec2(i, 0) * pixel).a;
                    outline += Texel(tex, tex_coords - vec2(i, 0) * pixel).a;
                    outline += Texel(tex, tex_coords + vec2(0, i) * pixel).a;
                    outline += Texel(tex, tex_coords - vec2(0, i) * pixel).a;
                }
                
                outline = min(outline / (4.0 * outlineWidth), 1.0);
                return mix(outlineColor, tex_color, tex_color.a) * color;
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

            vec2 quadClamp(vec2 coords, vec4 quadInfo) {
                float minX = quadInfo.x;
                float minY = quadInfo.y;
                float maxX = quadInfo.x + quadInfo.z;
                float maxY = quadInfo.y + quadInfo.w;
                
                return vec2(
                    clamp(coords.x, minX, maxX),
                    clamp(coords.y, minY, maxY)
                );
            }

            vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
                vec2 normalizedCoords = (tex_coords - quadInfo.xy) / quadInfo.zw;
                
                vec2 wobble = vec2(
                    normalizedCoords.x + sin(time * speed + normalizedCoords.y * frequency) * amount,
                    normalizedCoords.y + cos(time * speed + normalizedCoords.x * frequency) * amount
                );
                
                wobble = clamp(wobble, 0.0, 1.0);
                
                wobble = quadInfo.xy + wobble * quadInfo.zw;
                
                return Texel(tex, wobble) * color;
            }
        ]]
    }
}

return shaders 