return [[
    extern float time;       // Time variable for animation
    extern vec4 rect;        // Rectangle dimensions (x, y, width, height)

    // Random function for starfield
    float rand(vec2 co) {
        return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
    }

    // Helper to create the swirling effect
    vec3 swirlEffect(vec2 uv, float time) {
        float swirlStrength = 1.5;
        float swirlSpeed = 0.2;

        float angle = atan(uv.y, uv.x) + time * swirlSpeed;
        float radius = length(uv);
        radius = pow(radius, 0.7); // Curve for intensity
        vec2 swirlUV = vec2(cos(angle), sin(angle)) * radius;

        // Gradient coloring for the swirl
        float gradient = smoothstep(0.8, 0.0, radius);
        vec3 swirlColor = mix(vec3(0.1, 0.0, 0.4), vec3(0.8, 0.0, 0.8), gradient);

        return swirlColor;
    }

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {

        // Map to rectangle bounds
        vec2 rectCenter = rect.xy + rect.zw * 0.5;
        vec2 relCoord = (screen_coords - rect.xy) / rect.zw * 2.0 - 1.0; // Normalize [-1, 1]

        // Check if pixel is in the border area
        float borderWidth = 0.2; // Thickness of the border as a fraction of the rect width
        float innerX = 1.0 - borderWidth * 2.0;
        float innerY = 1.0 - borderWidth * 2.0;

        bool inBorder = (abs(relCoord.x) > innerX || abs(relCoord.y) > innerY) &&
                        abs(relCoord.x) <= 1.0 && abs(relCoord.y) <= 1.0;

        if (!inBorder) {
            return vec4(0.0); // Transparent for areas outside the border
        }

        // Apply swirl effect
        vec3 swirlColor = swirlEffect(relCoord, time);

        // Add stars randomly
        float starDensity = 200.0;
        vec2 starUV = floor(relCoord * starDensity);
        float star = rand(starUV) * 0.5;
        star *= pow(abs(sin(time * 2.0 + rand(starUV) * 6.28)), 4.0); // Twinkle animation

        vec3 finalColor = swirlColor + vec3(star);

        return vec4(finalColor, 1.0);
    }
]]