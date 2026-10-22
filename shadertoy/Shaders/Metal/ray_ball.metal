// Generated from Shaders/ray_ball.fsh by tools/glsl_to_msl.py.
// Regenerate with that script. glslangValidator compiles the GLSL;
// spirv-cross emits MSL. Xcode compiles this file with metalc.
// Entry point: shader_ray_ball

#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

#include "ShaderCommon.h"

using namespace metal;


struct shader_ray_ball_out
{
    float4 fragColor [[color(0)]];
};

static inline __attribute__((always_inline))
float sphere(thread const float3& p)
{
    return length(p) - 5.0;
}

static inline __attribute__((always_inline))
float displacement(thread const float3& p)
{
    return (sin(p.x) * sin(p.y)) * sin(p.z);
}

static inline __attribute__((always_inline))
float opDisplace(thread const float3& p)
{
    float3 param = p;
    float d1 = sphere(param);
    float3 param_1 = p;
    float d2 = displacement(param_1);
    return d1 + d2;
}

fragment shader_ray_ball_out shader_ray_ball(constant ShaderUniforms& _69 [[buffer(0)]], float4 fragCoordMetal [[position]])
{
    shader_ray_ball_out out = {};
    // [[position]] is top-left. GLSL gl_FragCoord is bottom-left.
    float4 gl_FragCoord = fragCoordMetal;
    gl_FragCoord.y = _69.resolution.y - fragCoordMetal.y;
    float2 p = float2(-1.0) + ((gl_FragCoord.xy * 2.0) / _69.resolution);
    p.x *= (_69.resolution.x / _69.resolution.y);
    float3 vuv = float3(0.0, 1.0, 0.0);
    float3 vrp = float3(0.0, 1.0, 0.0);
    float3 prp = float3(sin(_69.time) * 8.0, 4.0, cos(_69.time) * 8.0);
    float3 vpn = normalize(vrp - prp);
    float3 u = normalize(cross(vuv, vpn));
    float3 v = cross(vpn, u);
    float3 vcv = prp + vpn;
    float3 scrCoord = (vcv + (u * p.x)) + (v * p.y);
    float3 scp = normalize(scrCoord - prp);
    float s = 0.100000001490116119384765625;
    float f = 1.0;
    float3 p1 = {};
    for (int i = 0; i < 30; i++)
    {
        f += s;
        p1 = prp + (scp * f);
        float3 param = p1;
        s = opDisplace(param);
    }
    float3 c = float3(0.20000000298023223876953125, 0.60000002384185791015625, 0.800000011920928955078125);
    float3 param_1 = p1 - float3(0.100000001490116119384765625, 0.0, 0.0);
    float3 param_2 = p1 - float3(0.0, 0.100000001490116119384765625, 0.0);
    float3 param_3 = p1 - float3(0.0, 0.0, 0.100000001490116119384765625);
    float3 n = normalize(float3(s - opDisplace(param_1), s - opDisplace(param_2), s - opDisplace(param_3)));
    float b = dot(n, normalize(prp - p1));
    float4 tex = float4(((c * b) + float3(pow(b, 128.0))) * (1.0 - (f * 0.00999999977648258209228515625)), 1.0);
    tex += ((float4(0.9900000095367431640625, 0.660000026226043701171875, 0.20000000298023223876953125, 1.0) / float4(f)) * 2.0);
    float4 background = float4(0.0, 0.0, 0.0, 1.0);
    float4 Color = select(background, tex, bool4(f < 16.0));
    out.fragColor = Color;
    return out;
}

