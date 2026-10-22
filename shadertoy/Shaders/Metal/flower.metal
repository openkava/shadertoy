// Generated from Shaders/flower.fsh by tools/glsl_to_msl.py.
// Regenerate with that script. glslangValidator compiles the GLSL;
// spirv-cross emits MSL. Xcode compiles this file with metalc.
// Entry point: shader_flower

#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

#include "ShaderCommon.h"

using namespace metal;


struct shader_flower_out
{
    float4 fragColor [[color(0)]];
};

static inline __attribute__((always_inline))
float2 rot(thread const float2& p, thread const float& r)
{
    float2 ret = {};
    ret.x = (p.x * cos(r)) - (p.y * sin(r));
    ret.y = (p.x * sin(r)) + (p.y * cos(r));
    return ret;
}

static inline __attribute__((always_inline))
float2 rotsim(thread const float2& p, thread const float& s)
{
    float2 ret = p;
    float2 param = p;
    float param_1 = (-3.1400001049041748046875) / (s * 2.0);
    ret = rot(param, param_1);
    float2 param_2 = p;
    float param_3 = floor((precise::atan2(ret.x, ret.y) / 3.1400001049041748046875) * s) * (3.1400001049041748046875 / s);
    ret = rot(param_2, param_3);
    return ret;
}

static inline __attribute__((always_inline))
float2 makeSymmetry(thread const float2& p)
{
    float2 ret = p;
    float2 param = ret;
    float param_1 = 16.0;
    ret = rotsim(param, param_1);
    ret.x = abs(ret.x);
    return ret;
}

static inline __attribute__((always_inline))
float rand(thread const float2& co)
{
    return fract(sin(dot(co, float2(12.98980045318603515625, 78.233001708984375))) * 43758.546875);
}

static inline __attribute__((always_inline))
float sampleRand(thread const float2& P, thread const int& dx, thread const int& dy)
{
    float2 param = P + float2(float(dx), float(dy));
    return rand(param);
}

static inline __attribute__((always_inline))
float myNoise(thread const float2& P, thread float2& D)
{
    float2 i = floor(P);
    float2 u = P - i;
    float du = ((30.0 * u.x) * u.x) * ((u.x * (u.x - 2.0)) + 1.0);
    float dv = ((30.0 * u.y) * u.y) * ((u.y * (u.y - 2.0)) + 1.0);
    u.x = ((u.x * u.x) * u.x) * ((u.x * ((u.x * 6.0) - 15.0)) + 10.0);
    u.y = ((u.y * u.y) * u.y) * ((u.y * ((u.y * 6.0) - 15.0)) + 10.0);
    float2 param = i;
    int param_1 = 0;
    int param_2 = 0;
    float a = sampleRand(param, param_1, param_2);
    float2 param_3 = i;
    int param_4 = 1;
    int param_5 = 0;
    float b = sampleRand(param_3, param_4, param_5);
    float2 param_6 = i;
    int param_7 = 0;
    int param_8 = 1;
    float c = sampleRand(param_6, param_7, param_8);
    float2 param_9 = i;
    int param_10 = 1;
    int param_11 = 1;
    float d = sampleRand(param_9, param_10, param_11);
    float k0 = a;
    float k1 = b - a;
    float k2 = c - a;
    float k3 = ((a - b) - c) + d;
    D.x = du * (k1 + (k3 * u.y));
    D.y = dv * (k2 + (k3 * u.x));
    return ((k0 + (k1 * u.x)) + (k2 * u.y)) + (k3 * (u.x * u.y));
}

static inline __attribute__((always_inline))
float fbm(thread const float2& P, thread float2& D)
{
    float f = 0.0;
    float w = 0.5;
    float x = 1.0;
    D.x = 0.0;
    D.y = 0.0;
    float2 param_1 = {};
    for (int i = 0; i < 4; i++)
    {
        float2 param = P * x;
        float _332 = myNoise(param, param_1);
        float2 d = param_1;
        f += ((w * _332) / (1.0 + dot(D, D)));
        D += d;
        w *= 0.5;
        x *= 2.0;
    }
    return f;
}

static inline __attribute__((always_inline))
float3 rock(thread const float2& r, thread float4& gl_FragCoord, constant ShaderUniforms& v_362)
{
    float2 P = (gl_FragCoord.xy / v_362.resolution) * 13.0;
    P = mix(P, r, float2(0.100000001490116119384765625));
    P.x -= (v_362.time * 0.006000000052154064178466796875);
    P += (r * 0.00999999977648258209228515625);
    float2 param = P * 8.0;
    float2 param_1 = {};
    float _396 = fbm(param, param_1);
    float2 D = param_1;
    float N = _396;
    float3 stone = float3((D + float2(1.0)) * 0.5, 0.100000001490116119384765625);
    stone = normalize(stone);
    stone = float3(dot(stone, float3(0.639602124691009521484375, 0.426401436328887939453125, 0.639602124691009521484375)));
    return ((stone * stone) * stone) * 0.300000011920928955078125;
}

fragment shader_flower_out shader_flower(constant ShaderUniforms& v_362 [[buffer(0)]], float4 fragCoordMetal [[position]])
{
    shader_flower_out out = {};
    // [[position]] is top-left. GLSL gl_FragCoord is bottom-left.
    float4 gl_FragCoord = fragCoordMetal;
    gl_FragCoord.y = v_362.resolution.y - fragCoordMetal.y;
    float2 posScale = float2(2.0);
    float2 position = ((gl_FragCoord.xy / v_362.resolution) - float2(0.5)) * 2.0;
    float2 param = position;
    position = makeSymmetry(param);
    float sum = 0.0;
    float sum2 = 0.0;
    float qsum = 0.0;
    float t = v_362.time * 0.5;
    for (float i = 0.0; i < 40.0; i += 1.0)
    {
        float x2 = ((i * i) * 0.316500008106231689453125) + (i * 0.00999999977648258209228515625);
        float y2 = (i * 0.1612350046634674072265625) + (sin((t * i) * 0.12999999523162841796875) * 0.100000001490116119384765625);
        float2 p = (fract(position - float2(x2, y2)) - float2(0.5)) / posScale;
        float a = precise::atan2(p.y, p.x);
        float r = length(p) * 100.0;
        float e = exp((-r) * 0.20000000298023223876953125);
        float e2 = e * atan(r);
        sum += (sin((r + a) + v_362.time) * e2);
        sum2 += (cos((r + a) + v_362.time) * e2);
        qsum += e;
    }
    float color = sqrt((sum * sum) + (sum2 * sum2)) / qsum;
    float g = (1.0 - color) * 0.85000002384185791015625;
    out.fragColor = float4(g, (((g * g) * g) * g) * g, 0.0, 1.0);
    float2 r_1 = float2(-sum2, -sum) * 0.100000001490116119384765625;
    float2 param_1 = r_1;
    float4 stone = float4(rock(param_1, gl_FragCoord, v_362), 1.0);
    float a_1 = 1.0 - color;
    a_1 = smoothstep(0.4000000059604644775390625, 1.0, a_1);
    a_1 *= a_1;
    a_1 += 0.60000002384185791015625;
    out.fragColor = mix(stone, out.fragColor, float4((a_1 * a_1) * a_1));
    return out;
}

