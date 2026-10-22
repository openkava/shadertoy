// Generated from Shaders/monjori.fsh by tools/glsl_to_msl.py.
// Regenerate with that script. glslangValidator compiles the GLSL;
// spirv-cross emits MSL. Xcode compiles this file with metalc.
// Entry point: shader_monjori

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


struct shader_monjori_out
{
    float4 fragColor [[color(0)]];
};

fragment shader_monjori_out shader_monjori(constant ShaderUniforms& _20 [[buffer(0)]], float4 fragCoordMetal [[position]])
{
    shader_monjori_out out = {};
    // [[position]] is top-left. GLSL gl_FragCoord is bottom-left.
    float4 gl_FragCoord = fragCoordMetal;
    gl_FragCoord.y = _20.resolution.y - fragCoordMetal.y;
    float2 p = float2(-1.0) + ((gl_FragCoord.xy * 2.0) / _20.resolution);
    float a = _20.time * 40.0;
    float g = 0.02500000037252902984619140625;
    float e = 400.0 * ((p.x * 0.5) + 0.5);
    float f = 400.0 * ((p.y * 0.5) + 0.5);
    float i = 200.0 + (sin((e * g) + (a / 150.0)) * 20.0);
    float d = (200.0 + (cos((f * g) / 2.0) * 18.0)) + (cos(e * g) * 7.0);
    float r = sqrt(pow(i - e, 2.0) + pow(d - f, 2.0));
    float q = f / r;
    e = (r * cos(q)) - (a / 2.0);
    f = (r * sin(q)) - (a / 2.0);
    d = ((sin(e * g) * 176.0) + (sin(e * g) * 164.0)) + r;
    float h = ((f + d) + (a / 2.0)) * g;
    i = (cos(h + ((r * p.x) / 1.2999999523162841796875)) * ((e + e) + a)) + (cos((q * g) * 6.0) * (r + (h / 3.0)));
    h = (sin(f * g) * 144.0) - ((sin(e * g) * 212.0) * p.x);
    h = (((h + ((f - e) * q)) + (sin(r - ((a + h) / 7.0)) * 10.0)) + (i / 4.0)) * g;
    i += (((cos((h * 2.2999999523162841796875) * sin((a / 350.0) - q)) * 184.0) * sin(q - (((r * 4.30000019073486328125) + (a / 12.0)) * g))) + ((tan((r * g) + h) * 184.0) * cos((r * g) + h)));
    i = mod(i / 5.599999904632568359375, 256.0) / 64.0;
    if (i < 0.0)
    {
        i += 4.0;
    }
    if (i >= 2.0)
    {
        i = 4.0 - i;
    }
    d = r / 350.0;
    d += (sin((d * d) * 8.0) * 0.519999980926513671875);
    f = (sin(a * g) + 1.0) / 2.0;
    out.fragColor = float4(((float3((f * i) / 1.60000002384185791015625, (i / 2.0) + (d / 13.0), i) * d) * p.x) + ((float3((i / 1.2999999523162841796875) + (d / 8.0), (i / 2.0) + (d / 18.0), i) * d) * (1.0 - p.x)), 1.0);
    return out;
}

