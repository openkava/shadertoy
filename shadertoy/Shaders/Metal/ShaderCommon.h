#ifndef ShaderCommon_h
#define ShaderCommon_h

#include <metal_stdlib>

using namespace metal;

// Shared with MetalShaderView's ShaderUniforms. Offsets are checked there:
// time at 0, mouse at 8, resolution at 16. Every generated fragment shader
// uses this layout, including samples that do not read every member.
struct ShaderUniforms {
    float time;
    float2 mouse;
    float2 resolution;
};

#endif
