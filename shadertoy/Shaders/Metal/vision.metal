// Generated from Shaders/vision.fsh by tools/glsl_to_msl.py.
// Regenerate with that script. glslangValidator compiles the GLSL;
// spirv-cross emits MSL. Xcode compiles this file with metalc.
// Entry point: shader_vision

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


struct shader_vision_out
{
    float4 fragColor [[color(0)]];
};

static inline __attribute__((always_inline))
float sharpen(thread const float& v, thread const float& dist)
{
    float d = 0.0500000007450580596923828125 + (pow(1.0 - dist, 4.0) * 0.5);
    return smoothstep(0.5 - d, 0.5 + d, v);
}

fragment shader_vision_out shader_vision(constant ShaderUniforms& _41 [[buffer(0)]], float4 fragCoordMetal [[position]])
{
    shader_vision_out out = {};
    // [[position]] is top-left. GLSL gl_FragCoord is bottom-left.
    float4 gl_FragCoord = fragCoordMetal;
    gl_FragCoord.y = _41.resolution.y - fragCoordMetal.y;
    float2 position = (gl_FragCoord.xy / _41.resolution) - float2(0.5);
    float4 color = float4(1.0);
    float2 abspos = abs(position * 2.0);
    float depth = clamp(sqrt((abspos.y * abspos.y) + (abspos.x * abspos.x)), 0.0, 2.0);
    float lc = mix(20.0, 10.0, depth);
    float2 pos = mod((((abspos * 0.5) - float2(0.75)) * lc) + float2(_41.time * 0.25), float2(1.0));
    float mx = 0.5;
    float ao = 1.0;
    if (abs(position.x) > abs(position.y))
    {
        float param = abs((pos.x * 2.0) - 1.0);
        float param_1 = depth;
        float param_2 = abs(mod(((abspos.y / abspos.x) * 10.0) * 0.5, 2.0) - 1.0);
        float param_3 = abspos.x;
        mx = abs((1.0 - sharpen(param, param_1)) - sharpen(param_2, param_3));
        ao = 1.0 - (abspos.y / abspos.x);
        ao *= clamp(abspos.x * abspos.x, 0.0, 1.0);
    }
    else
    {
        float param_4 = abs((pos.y * 2.0) - 1.0);
        float param_5 = depth;
        mx = sharpen(param_4, param_5);
        ao = 1.0 - (abspos.x / abspos.y);
        ao *= clamp(abspos.y * abspos.y, 0.0, 1.0);
    }
    float3 _184 = mix(float3(0.100000001490116119384765625, 0.300000011920928955078125, 0.100000001490116119384765625), float3(0.89999997615814208984375, 0.300000011920928955078125, 0.100000001490116119384765625), float3(mx));
    color.x = _184.x;
    color.y = _184.y;
    color.z = _184.z;
    float4 _195 = color;
    float3 _197 = _195.xyz * pow(ao, 0.3499999940395355224609375);
    color.x = _197.x;
    color.y = _197.y;
    color.z = _197.z;
    out.fragColor = color;
    return out;
}

