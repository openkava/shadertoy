// Generated from Shaders/test.fsh by tools/glsl_to_msl.py.
// Regenerate with that script. glslangValidator compiles the GLSL;
// spirv-cross emits MSL. Xcode compiles this file with metalc.
// Entry point: shader_test

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


struct shader_test_out
{
    float4 fragColor [[color(0)]];
};

static inline __attribute__((always_inline))
float3 field(thread float3& p)
{
    p = abs(fract(p) - float3(0.5));
    p *= p;
    return sqrt(p + (p.yzx * p.zzy)) - float3(0.014999999664723873138427734375);
}

fragment shader_test_out shader_test(constant ShaderUniforms& _44 [[buffer(0)]], float4 fragCoordMetal [[position]])
{
    shader_test_out out = {};
    // [[position]] is top-left. GLSL gl_FragCoord is bottom-left.
    float4 gl_FragCoord = fragCoordMetal;
    gl_FragCoord.y = _44.resolution.y - fragCoordMetal.y;
    float3 dir = normalize(float3((gl_FragCoord.xy - (_44.resolution * 0.5)) / float2(_44.resolution.x), 1.0));
    float a = _44.time * 0.4000000059604644775390625;
    float3 pos = float3((_44.time * 0.60000002384185791015625) + (sin(_44.time) * 0.20000000298023223876953125), sin(_44.time) * 0.25, -3.0);
    float3 color = float3(0.0);
    for (int i = 0; i < 90; i++)
    {
        float3 param = pos;
        float3 _106 = field(param);
        float3 f2 = _106;
        float3 rep = float3(1.0);
        float f = min(min(min(f2.x, f2.y), f2.z), length(mod(pos - float3(0.5, 0.5, 0.20000000298023223876953125), rep) - (rep * 0.5)) - 0.1500000059604644775390625);
        pos += (dir * f);
        color += (float3(float(90 - i)) / (f2 + float3(9.9999997473787516355514526367188e-06)));
    }
    float3 color3 = float3(-1.0) / (float3(1.0) + (color * 6.1728394939564168453216552734375e-05));
    color3 *= color3;
    out.fragColor = float4(float3(color3.x + color3.y, color3.y + color3.z, color3.z + color3.y), 1.0);
    return out;
}

