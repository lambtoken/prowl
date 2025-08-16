return [[
extern float time;
extern vec2 boardSize;
extern float tileSize;
extern vec2 cameraPos;
extern vec2 screenSize;
extern vec2 scaleFactor;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    float boardWidth = boardSize.x * tileSize * scaleFactor.y;
    float boardHeight = boardSize.y * tileSize * scaleFactor.y;
    
    vec2 screenCenter = screenSize / 2.0;
    
    vec2 worldPos = (screen_coords - screenCenter + cameraPos * scaleFactor.y);
    
    float distFromLeft = worldPos.x;
    float distFromRight = boardWidth - worldPos.x;
    float distFromTop = worldPos.y;
    float distFromBottom = boardHeight - worldPos.y;
    
    float borderSize = 10.0 * scaleFactor.y;
    
    float wobbleIntensity = 4.0 * scaleFactor.y;
    float wobbleFrequency = 0.02 / scaleFactor.y;
    float wobbleSpeed = 2.0;
    
    float leftWobble = sin(worldPos.y * wobbleFrequency + time * wobbleSpeed) * wobbleIntensity;
    float rightWobble = sin(worldPos.y * wobbleFrequency + time * wobbleSpeed + 3.14) * wobbleIntensity;
    float topWobble = sin(worldPos.x * wobbleFrequency + time * wobbleSpeed) * wobbleIntensity;
    float bottomWobble = sin(worldPos.x * wobbleFrequency + time * wobbleSpeed + 3.14) * wobbleIntensity;
    
    float wobbledLeft = borderSize + leftWobble;
    float wobbledRight = borderSize + rightWobble;
    float wobbledTop = borderSize + topWobble;
    float wobbledBottom = borderSize + bottomWobble;
    
    float leftFactor = step(distFromLeft, wobbledLeft);
    float rightFactor = step(distFromRight, wobbledRight);
    float topFactor = step(distFromTop, wobbledTop);
    float bottomFactor = step(distFromBottom, wobbledBottom);
    
    float borderFactor = max(max(leftFactor, rightFactor), max(topFactor, bottomFactor));
    
    vec4 texColor = Texel(texture, texture_coords);
    
    vec3 borderColor = vec3(0.0);
    
    vec3 finalColor = mix(texColor.rgb, borderColor, borderFactor);
    
    return vec4(finalColor, texColor.a);
}
]]