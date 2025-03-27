return [[
extern float force;        // Uniform for the force of the distortion
extern float size;         // Uniform for the size of the effect
extern float thickness;    // Uniform for the thickness of the effect
extern vec2 center;        // Uniform for the effect's center in UV coordinates
extern vec2 screen_size;   // Uniform for the screen size

vec2 screen_pixel_size = 1.0 / screen_size; // Calculate pixel size in UV coordinates

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // Calculate aspect ratio correction
    float ratio = screen_pixel_size.x / screen_pixel_size.y;
    vec2 scaled_uv = (texture_coords - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);

    // Calculate mask for the effect
    float dist_to_center = length(scaled_uv - center);
    float mask = (1.0 - smoothstep(size - 0.1, size, dist_to_center) *
                        smoothstep(size - thickness - 0.1, size - thickness, dist_to_center));

    // Apply displacement based on the mask
    vec2 disp = normalize(scaled_uv - center) * force * mask;

    // Sample the texture with the displaced UV coordinates
    vec4 tex_color = Texel(texture, texture_coords - disp);

    // Return the modified color
    return tex_color * color;
}
]]