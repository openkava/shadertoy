// Generated from Shaders/julia.fsh by tools/glsl_to_msl.py.
// Regenerate with that script. glslangValidator compiles the GLSL;
// spirv-cross emits MSL. Xcode compiles this file with metalc.
// Entry point: shader_julia

#include <metal_stdlib>
#include <simd/simd.h>

#include "ShaderCommon.h"

using namespace metal;


struct shader_julia_out
{
    float4 fragColor [[color(0)]];
};

fragment shader_julia_out shader_julia(constant ShaderUniforms& _26 [[buffer(0)]], float4 fragCoordMetal [[position]])
{
    shader_julia_out out = {};
    // [[position]] is top-left. GLSL gl_FragCoord is bottom-left.
    float4 gl_FragCoord = fragCoordMetal;
    gl_FragCoord.y = _26.resolution.y - fragCoordMetal.y;
    float2 c = float2(gl_FragCoord.x - 200.0, gl_FragCoord.y) / _26.resolution;
    float2 z = c;
    bool diverged = false;
    for (int i = 0; i < 50; i++)
    {
        z = float2(((z.x * z.x) - (z.y * z.y)) + c.x, ((2.0 * z.x) * z.y) + c.y);
        if (((z.x * z.x) + (z.y * z.y)) > 100.0)
        {
            diverged = true;
            break;
        }
    }
    if (diverged)
    {
        out.fragColor = float4(1.0);
    }
    else
    {
        out.fragColor = float4(0.0, 0.0, 0.0, 1.0);
    }
    return out;
}

