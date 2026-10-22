// Generated from Shaders/heart.fsh by tools/glsl_to_msl.py.
// Regenerate with that script. glslangValidator compiles the GLSL;
// spirv-cross emits MSL. Xcode compiles this file with metalc.
// Entry point: shader_heart

#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

#include "ShaderCommon.h"

using namespace metal;

// GLSL mod(), kept file-local so it does not collide across .metal files.
template<typename Tx, typename Ty>
static inline Tx mod(Tx x, Ty y)
{
    return x - y * floor(x / y);
}


struct shader_heart_out
{
    float4 fragColor [[color(0)]];
};

fragment shader_heart_out shader_heart(constant ShaderUniforms& _19 [[buffer(0)]], float4 fragCoordMetal [[position]])
{
    shader_heart_out out = {};
    // [[position]] is top-left. GLSL gl_FragCoord is bottom-left.
    float4 gl_FragCoord = fragCoordMetal;
    gl_FragCoord.y = _19.resolution.y - fragCoordMetal.y;
    float2 p = ((gl_FragCoord.xy * 2.0) - _19.resolution) / float2(_19.resolution.y);
    p.y -= 0.25;
    float tt = mod(_19.time, 2.0) / 2.0;
    float ss = (pow(tt, 0.20000000298023223876953125) * 0.5) + 0.5;
    ss -= (((ss * 0.20000000298023223876953125) * sin((tt * 6.283100128173828125) * 5.0)) * exp((-tt) * 6.0));
    p *= (float2(0.5, 1.5) + (float2(0.5, -0.5) * ss));
    float a = precise::atan2(p.x, p.y) / 3.14159297943115234375;
    float r = length(p);
    float h = abs(a);
    float d = (((13.0 * h) - ((22.0 * h) * h)) + (((10.0 * h) * h) * h)) / (6.0 - (5.0 * h));
    float f = step(r, d) * pow(1.0 - (r / d), 0.25);
    out.fragColor = float4(f, 0.0, 0.0, 1.0);
    return out;
}

