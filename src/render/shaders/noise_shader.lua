return [[
    extern float time; // Time variable for animation
    extern vec2 resolution; // Screen resolution for normalized coordinates

    // Simplex noise function (unchanged from before)
    vec3 mod289(vec3 x) { return x - floor(x / 289.0) * 289.0; }
    vec2 mod289(vec2 x) { return x - floor(x / 289.0) * 289.0; }
    vec3 permute(vec3 x) { return mod289(((x * 34.0) + 1.0) * x); }

    float snoise(vec2 v) {
        const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                            0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                            -0.577350269189626, // -1.0 + 2.0 * C.x
                            0.024390243902439); // 1.0 / 41.0
        vec2 i  = floor(v + dot(v, C.yy));
        vec2 x0 = v - i + dot(i, C.xx);

        vec2 i1;
        i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);

        vec4 x12 = x0.xyxy + C.xxzz;
        x12.xy -= i1;

        i = mod289(i);
        vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))
                       + i.x + vec3(0.0, i1.x, 1.0));

        vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
        m = m * m;
        m = m * m;

        vec3 x = 2.0 * fract(p * C.www) - 1.0;
        vec3 h = abs(x) - 0.5;
        vec3 ox = floor(x + 0.5);
        vec3 a0 = x - ox;

        m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

        vec3 g;
        g.x = a0.x * x0.x + h.x * x0.y;
        g.yz = a0.yz * x12.xz + h.yz * x12.yw;
        return 130.0 * dot(m, g);
    }

    // RGB to HSV conversion
    vec3 rgb2hsv(vec3 c) {
        float cmax = max(c.r, max(c.g, c.b));
        float cmin = min(c.r, min(c.g, c.b));
        float delta = cmax - cmin;

        float h = 0.0;
        if (delta > 0.0) {
            if (cmax == c.r) {
                h = mod((c.g - c.b) / delta, 6.0);
            } else if (cmax == c.g) {
                h = (c.b - c.r) / delta + 2.0;
            } else {
                h = (c.r - c.g) / delta + 4.0;
            }
            h /= 6.0; // Normalize to [0, 1]
        }

        float s = cmax == 0.0 ? 0.0 : delta / cmax;
        float v = cmax;

        return vec3(h, s, v);
    }

    // HSV to RGB conversion
    vec3 hsv2rgb(vec3 c) {
        float h = c.x * 6.0;
        float s = c.y;
        float v = c.z;

        float c1 = v * s;
        float x = c1 * (1.0 - abs(mod(h, 2.0) - 1.0));
        float m = v - c1;

        vec3 rgb;
        if (h < 1.0) rgb = vec3(c1, x, 0.0);
        else if (h < 2.0) rgb = vec3(x, c1, 0.0);
        else if (h < 3.0) rgb = vec3(0.0, c1, x);
        else if (h < 4.0) rgb = vec3(0.0, x, c1);
        else if (h < 5.0) rgb = vec3(x, 0.0, c1);
        else rgb = vec3(c1, 0.0, x);

        return rgb + m;
    }

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        // Normalize screen coordinates
        vec2 uv = screen_coords / resolution;

        // Generate noise value
        float scale = 2.0; // Control noise scale
        float noise = snoise(uv * scale + vec2(time * 0.1));

        // Get texture color
        vec4 texColor = Texel(texture, texture_coords);

        // Convert to HSV
        vec3 hsv = rgb2hsv(texColor.rgb);

        // Modify hue with noise
        hsv.x += noise * 0.1; // Adjust this multiplier for more/less hue variation
        hsv.x = mod(hsv.x, 1.0); // Keep hue within [0, 1]

        // Convert back to RGB
        vec3 rgb = hsv2rgb(hsv);

        return vec4(rgb, texColor.a); // Preserve alpha
    }
]]
