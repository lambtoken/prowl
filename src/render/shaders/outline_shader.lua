return [[
    extern number outlineSize;
    extern vec4 outlineColor;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixel = Texel(texture, texture_coords);
        if (pixel.a > 0.0) {
            return pixel * color;
        }

        float radius = outlineSize / love_ScreenSize.x;
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