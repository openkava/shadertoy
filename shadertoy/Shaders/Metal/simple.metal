// Generated from Shaders/simple.fsh by tools/glsl_to_msl.py.
// Regenerate with that script. glslangValidator compiles the GLSL;
// spirv-cross emits MSL. Xcode compiles this file with metalc.
// Entry point: shader_simple

#include <metal_stdlib>
#include <simd/simd.h>

#include "ShaderCommon.h"

using namespace metal;


struct shader_simple_out
{
    float4 fragColor [[color(0)]];
};

fragment shader_simple_out shader_simple(constant ShaderUniforms& _17 [[buffer(0)]], float4 fragCoordMetal [[position]])
{
    shader_simple_out out = {};
    // [[position]] is top-left. GLSL gl_FragCoord is bottom-left.
    float4 gl_FragCoord = fragCoordMetal;
    gl_FragCoord.y = _17.resolution.y - fragCoordMetal.y;
    float2 position = (gl_FragCoord.xy / _17.resolution) + (_17.mouse / float2(2.0));
    float color = 0.20000000298023223876953125;
    color += (sin((position.x * cos(_17.time / 10.0)) * 100.0) + cos((position.y * cos(_17.time / 5.0)) * 10.0));
    color += (sin((position.x * sin(_17.time / 10.0)) * 10.0) + sin((position.y * sin(_17.time / 5.0)) * 80.0));
    color *= (sin(_17.time / 100.0) * 2.5);
    out.fragColor = float4(float3(color * 0.5, color * 0.20000000298023223876953125, sin(color + _17.time) * 0.1500000059604644775390625), 1.0);
    return out;
}

