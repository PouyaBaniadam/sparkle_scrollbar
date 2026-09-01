#include <flutter/runtime_effect.glsl>

// -----------------------------------------------------------------------------
// Uniform Layout (Total 31 Floats: indices 0 through 30)
// -----------------------------------------------------------------------------
uniform vec2 uSize;                  // 0, 1: Viewport dimensions (width, height)
uniform float uTime;                 // 2: Elapsed runtime in seconds
uniform float uThumbTop;             // 3: Normalized start position (0.0 to 1.0)
uniform float uThumbBottom;          // 4: Normalized end position (0.0 to 1.0)
uniform float uActivity;             // 5: Activity interpolation weight (0.0: idle, 1.0: active)
uniform float uVelocity;             // 6: Scroll velocity with directional sign

uniform vec3 uThumbColor;            // 7, 8, 9: Base thumb capsule color (RGB)
uniform vec3 uGlowColor;             // 10, 11, 12: Aura glow highlight color (RGB)
uniform vec3 uSparkColor;            // 13, 14, 15: Primary particle color (RGB)
uniform vec3 uVelocityShiftColor;    // 16, 17, 18: High-speed velocity shift color (RGB)

uniform float uThumbThickness;       // 19: Thumb capsule radius thickness
uniform float uSparkIntensity;       // 20: Particle brightness multiplier
uniform float uSparkCount;           // 21: Active particle count (0 to 50)
uniform float uSparkMinSize;         // 22: Minimum particle radius
uniform float uSparkMaxSize;         // 23: Maximum particle radius
uniform float uSparkSpeed;           // 24: Particle ejection speed multiplier
uniform float uSparkShape;           // 25: Shape mode (0: Circle, 1: Star, 2: Diamond, 3: Square, 4: Bubble)
uniform float uColorShiftEnabled;    // 26: Flag to enable velocity color shift (1.0 = on, 0.0 = off)
uniform float uGripNotchCount;       // 27: Center mechanical grip notch count (0.0, 1.0, 3.0)
uniform float uWaveEffect;           // 28: Flag for animated traveling light wave (1.0 = on, 0.0 = off)
uniform float uTrackAlpha;           // 29: Background groove opacity (0.0 to 1.0)
uniform float uIsHorizontal;         // 30: Orientation mode (1.0 = Horizontal, 0.0 = Vertical)

out vec4 fragColor;

// Deterministic pseudo-random number generator
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// Signed distance function for a 2D capsule
float sdCapsule(vec2 p, vec2 a, vec2 b, float r) {
vec2 pa = p - a, ba = b - a;
float h = clamp(dot(pa, ba) / max(0.0001, dot(ba, ba)), 0.0, 1.0);
return length(pa - ba * h) - r;
}

void main() {
    vec2 rawP = FlutterFragCoord().xy;
    vec2 size = uSize;

    // Coordinate transformation for horizontal orientation support
    if (uIsHorizontal > 0.5) {
        rawP = rawP.yx;
        size = size.yx;
    }

    vec2 p = rawP / size.x;
    float aspect = size.y / size.x;

    float speed = abs(uVelocity);
    float normSpeed = clamp(speed * 0.6, 0.0, 1.0);

    // 1. Render Background Groove Track
    float trackDist = abs(p.x - 0.5);
    float trackGroove = smoothstep(0.12, 0.02, trackDist) * uTrackAlpha;
    vec3 col = uThumbColor * 0.3 * trackGroove;
    float alpha = trackGroove;

    // 2. Compute Thumb Capsule Endpoints
    float topY = min(uThumbTop, uThumbBottom);
    float botY = max(uThumbTop, uThumbBottom);

    float y1 = topY * aspect;
    float y2 = botY * aspect;
    float thumbRadius = uThumbThickness;

    vec2 capA = vec2(0.5, y1 + thumbRadius);
    vec2 capB = vec2(0.5, y2 - thumbRadius);
    if (capA.y > capB.y) {
        capA.y = (y1 + y2) * 0.5;
        capB.y = capA.y;
    }

    float thumbDist = sdCapsule(p, capA, capB, thumbRadius);

    // 3. Render Thumb Material, Highlights, Notches, and Wave
    if (thumbDist < 0.035) {
        float thumbMask = smoothstep(0.009, -0.009, thumbDist);
        float dx = (p.x - 0.5) / thumbRadius;
        float normalZ = sqrt(max(0.0, 1.0 - dx * dx));

        vec3 bodyCol = mix(uThumbColor * 0.6, uThumbColor * 1.15, normalZ * 0.7 + 0.3);
        float specLine = pow(max(0.0, 1.0 - abs(dx + 0.32) * 2.0), 3.0) * 0.35;
        bodyCol += mix(uGlowColor, vec3(1.0), 0.3) * specLine;

        if (uGripNotchCount > 0.5) {
            float centerY = (capA.y + capB.y) * 0.5;
            float dY = abs(p.y - centerY);
            float notchMask = smoothstep(0.07, 0.0, abs(p.x - 0.5));
            float notches = smoothstep(0.015, 0.0, abs(dY));
            if (uGripNotchCount > 2.5) {
                notches += smoothstep(0.015, 0.0, abs(dY - 0.05)) +
                           smoothstep(0.015, 0.0, abs(dY + 0.05));
            }
            bodyCol = mix(bodyCol, uThumbColor * 0.2, notches * notchMask * 0.7);
            bodyCol += uGlowColor * notches * notchMask * uActivity * 0.9;
        }

        if (uWaveEffect > 0.5) {
            float wave = 0.5 + 0.5 * sin(p.y * 5.0 - uTime * 4.0);
            bodyCol = mix(bodyCol, uGlowColor * 1.3, wave * (0.15 + normSpeed * 0.35) * uActivity);
        }

        float thumbAlpha = thumbMask * (0.55 + uActivity * 0.45);
        col = mix(col, bodyCol, thumbMask);
        alpha = max(alpha, thumbAlpha);
    }

    float thumbGlow = smoothstep(0.18, 0.0, max(0.0, thumbDist)) * (0.08 + uActivity * 0.35);
    col += uGlowColor * thumbGlow;
    alpha = max(alpha, thumbGlow * 0.5);

    // 4. Dynamic Particle FX Generator
    const int MAX_SPARKS = 50;
    int activeSparks = int(clamp(uSparkCount, 0.0, float(MAX_SPARKS)));

    if (uActivity > 0.01 && uSparkIntensity > 0.0 && activeSparks > 0) {
        float thumbHeight = max(0.35, y2 - y1);

        for (int i = 0; i < MAX_SPARKS; i++) {
            if (i >= activeSparks) break;

            float id = float(i);
            float seed1 = hash(id * 17.13 + 2.1);
            float seed2 = hash(id * 37.45 + 5.7);
            float seed3 = hash(id * 69.21 + 8.3);

            float life = 0.55 + 0.35 * seed1;
            float birth = hash(id * 8.19) * 2.0;
            float age = mod(uTime * 1.5 + birth, life);
            float progress = age / life;

            float spawnY = y1 + seed2 * thumbHeight;
            float launchSpeed = (0.5 + 0.9 * seed3) * (0.6 + speed * 0.9) * uSparkSpeed;
            float speedY = (uVelocity >= 0.0 ? -1.0 : 1.0) * launchSpeed;
            float y = spawnY + speedY * progress;

            float side = (seed1 > 0.5) ? 1.0 : -1.0;
            float scatter = 0.06 + 0.20 * progress * seed2;
            float x = 0.5 + side * scatter;

            // Side-to-side wobble effect specifically for bubbles (Shape 4)
            if (uSparkShape > 3.5) {
                x += sin(progress * 8.0 + id * 3.0) * 0.04;
            }

            vec2 deltaP = p - vec2(x, y);
            float d = length(deltaP);

            float sizeP = mix(uSparkMinSize, uSparkMaxSize, seed2) * (1.0 - progress * 0.35);
            float core = 0.0;
            float halo = 0.0;

            // Geometry Shape 4: Glossy Translucent Bubble with Specular Highlight
            if (uSparkShape > 3.5) {
                float r = sizeP * 1.2;
                float dist = d / r;
                float body = smoothstep(1.0, 0.9, dist) * 0.15;
                float rim = smoothstep(1.0, 0.85, dist) - smoothstep(0.85, 0.6, dist);
                core = body + rim * 0.95;

                vec2 highlightOffset = vec2(-0.35, 0.35) * r;
                float highlight = smoothstep(r * 0.35, 0.0, length(deltaP - highlightOffset));
                core = max(core, highlight * 0.95);
                halo = smoothstep(r * 1.5, r, d) * 0.25;
            }
                // Geometry Shape 1: 4-Point Star Flare
            else if (uSparkShape > 0.5 && uSparkShape < 1.5) {
                float rayX = max(0.0, 1.0 - abs(deltaP.y) / (sizeP * 0.25)) * max(0.0, 1.0 - abs(deltaP.x) / (sizeP * 2.2));
                float rayY = max(0.0, 1.0 - abs(deltaP.x) / (sizeP * 0.25)) * max(0.0, 1.0 - abs(deltaP.y) / (sizeP * 2.2));
                float centerDot = smoothstep(sizeP * 0.5, 0.0, d);
                core = max(centerDot, max(rayX, rayY));
                halo = smoothstep(sizeP * 1.8, 0.0, d) * 0.3;
            }
                // Geometry Shape 2: Crisp Diamond Rhombus
            else if (uSparkShape > 1.5 && uSparkShape < 2.5) {
                float diamondDist = (abs(deltaP.x) + abs(deltaP.y));
                core = smoothstep(sizeP * 1.2, 0.0, diamondDist);
                halo = smoothstep(sizeP * 2.0, 0.0, diamondDist) * 0.3;
            }
                // Geometry Shape 3: Pixel / Square Box
            else if (uSparkShape > 2.5) {
                float boxDist = max(abs(deltaP.x), abs(deltaP.y));
                core = smoothstep(sizeP * 0.8, 0.0, boxDist);
                halo = smoothstep(sizeP * 1.6, 0.0, boxDist) * 0.3;
            }
                // Geometry Shape 0: Radiant Glowing Circle
            else {
                core = smoothstep(sizeP, 0.0, d);
                halo = smoothstep(sizeP * 2.5, 0.0, d) * 0.4;
            }

            float lifeFade = smoothstep(0.0, 0.12, progress) * smoothstep(1.0, 0.20, progress);
            float sparkAlpha = (core + halo) * lifeFade * uActivity * (0.85 + normSpeed * 0.7) * uSparkIntensity;

            vec3 targetSparkCol = uSparkColor;
            if (uColorShiftEnabled > 0.5) {
                targetSparkCol = mix(uSparkColor, uVelocityShiftColor, normSpeed);
            }

            vec3 finalSparkCol = mix(targetSparkCol, mix(targetSparkCol, vec3(1.0), 0.4), core * 0.6);
            col += finalSparkCol * sparkAlpha;
            alpha = max(alpha, sparkAlpha);
        }
    }

    fragColor = vec4(col, clamp(alpha, 0.0, 1.0));
}