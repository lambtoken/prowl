return [[
extern float time;

// Helper function to adjust saturation
vec3 adjustSaturation(vec3 color, float saturationFactor) {
    float gray = dot(color, vec3(0.299, 0.587, 0.114)); // Calculate luminance (perceptual grayscale)
    return mix(vec3(gray), color, saturationFactor); // Interpolate between grayscale and original color
}

// Helper function to adjust hue
vec3 adjustHue(vec3 color, float hueShift) {
    const mat3 rgbToYIQ = mat3(
        0.299,  0.587,  0.114,
        0.596, -0.275, -0.321,
        0.212, -0.523,  0.311
    );
    const mat3 yiqToRGB = mat3(
        1.0,  0.956,  0.621,
        1.0, -0.272, -0.647,
        1.0, -1.106,  1.703
    );

    vec3 yiq = rgbToYIQ * color;
    float angle = hueShift * 3.14159; // Convert to radians
    float cosAngle = cos(angle);
    float sinAngle = sin(angle);

    mat3 hueRotation = mat3(
        1.0,       0.0,       0.0,
        0.0,  cosAngle, -sinAngle,
        0.0,  sinAngle,  cosAngle
    );

    yiq = hueRotation * yiq; // Apply hue rotation
    return clamp(yiqToRGB * yiq, 0.0, 1.0); // Convert back to RGB
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // Generate shimmer using screen coordinates and time
    vec4 pixel = Texel(texture, texture_coords);
    float offset = time * 30;
    float shimmer = abs(sin((screen_coords.x + screen_coords.y + time + offset) * 0.1)) * 0.5 / 5;

    // Adjust saturation based on shimmer
    float saturationFactor = 1.0 + shimmer * 0.5; // Increase saturation slightly with shimmer
    vec3 saturatedColor = adjustSaturation(pixel.rgb, saturationFactor);

    // Adjust brightness to make it slightly darker
    vec3 darkerColor = saturatedColor * (1.0 - shimmer * 0.5); // Reduce brightness based on shimmer

    // Adjust hue based on shimmer
    float hueShift = shimmer * 0.3; // Small hue shift proportional to shimmer
    vec3 hueShiftedColor = adjustHue(darkerColor, hueShift);

    return vec4(hueShiftedColor, pixel.a);
}
]]
