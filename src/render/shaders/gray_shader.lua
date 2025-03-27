return [[
vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
    vec4 tex_color = Texel(tex, tex_coords);
    float gray = (tex_color.r + tex_color.g + tex_color.b) / 3;
    return vec4(gray, gray, gray, tex_color.a) * color;
}
]]