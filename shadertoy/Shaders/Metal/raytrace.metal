// Generated from Shaders/raytrace.fsh by tools/glsl_to_msl.py.
// Regenerate with that script. glslangValidator compiles the GLSL;
// spirv-cross emits MSL. Xcode compiles this file with metalc.
// Entry point: shader_raytrace

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


struct shader_raytrace_out
{
    float4 fragColor [[color(0)]];
};

static inline __attribute__((always_inline))
float2 appleShapeX(thread float3& p)
{
    p.y -= (0.75 * pow(dot(p.xz, p.xz), 0.20000000298023223876953125));
    float2 d1 = float2(length(p) - 1.0, 1.0);
    float2 d2 = float2(p.y + 0.550000011920928955078125, 2.0);
    if (d2.x < d1.x)
    {
        d1 = d2;
    }
    return d1;
}

static inline __attribute__((always_inline))
float biteNoise(thread const float3& p)
{
    return (sin(p.y * 50.0) * cos(p.x * 10.0)) * 0.0199999995529651641845703125;
}

static inline __attribute__((always_inline))
float2 sdSphere(thread const float3& p, thread const float& s)
{
    float3 param = p;
    float nse = biteNoise(param);
    return float2((length(p) - s) + nse, 1.0);
}

static inline __attribute__((always_inline))
float2 appleShape(thread float3& p, constant ShaderUniforms& v_305)
{
    p.x = (mod(p.x, 5.0) - 2.5) + (0.5 * sin(v_305.time));
    p.z = (mod(p.z, 5.0) - 2.5) + (0.5 * sin(v_305.time));
    float3 param = p;
    float2 _328 = appleShapeX(param);
    float2 d1 = _328;
    float3 param_1 = p - float3(1.2999999523162841796875, 1.0, 0.0);
    float param_2 = 0.60000002384185791015625;
    float2 d2 = sdSphere(param_1, param_2);
    return max(d1, -d2);
}

static inline __attribute__((always_inline))
float2 intersect(thread const float3& ro, thread const float3& rd, constant ShaderUniforms& v_305)
{
    float t = 0.0;
    float dt = 0.0500000007450580596923828125;
    float nh = 0.0;
    float lh = 0.0;
    float lm = -1.0;
    for (int i = 0; i < 256; i++)
    {
        float3 param = ro + (rd * t);
        float2 _595 = appleShape(param, v_305);
        float2 ma = _595;
        nh = ma.x;
        if (nh > 0.0)
        {
            lh = nh;
            t += dt;
        }
        lm = ma.y;
    }
    if (nh > 0.0)
    {
        return float2(-1.0);
    }
    t -= ((dt * nh) / (nh - lh));
    return float2(t, lm);
}

static inline __attribute__((always_inline))
float3 calcNormal(thread const float3& pos, constant ShaderUniforms& v_305)
{
    float3 eps = float3(0.001000000047497451305389404296875, 0.0, 0.0);
    float3 param = pos + eps.xyy;
    float2 _682 = appleShape(param, v_305);
    float3 param_1 = pos - eps.xyy;
    float2 _689 = appleShape(param_1, v_305);
    float3 nor = {};
    nor.x = _682.x - _689.x;
    float3 param_2 = pos + eps.yxy;
    float2 _698 = appleShape(param_2, v_305);
    float3 param_3 = pos - eps.yxy;
    float2 _705 = appleShape(param_3, v_305);
    nor.y = _698.x - _705.x;
    float3 param_4 = pos + eps.yyx;
    float2 _714 = appleShape(param_4, v_305);
    float3 param_5 = pos - eps.yyx;
    float2 _721 = appleShape(param_5, v_305);
    nor.z = _714.x - _721.x;
    return normalize(nor);
}

static inline __attribute__((always_inline))
float softshadow(thread const float3& ro, thread const float3& rd, thread const float& mint, thread const float& maxt, thread const float& k, constant ShaderUniforms& v_305)
{
    float res = 1.0;
    float dt = 0.0500000007450580596923828125;
    float t = mint;
    for (int i = 0; i < 80; i++)
    {
        float3 param = ro + (rd * t);
        float2 _651 = appleShape(param, v_305);
        float h = _651.x;
        if (h > 0.001000000047497451305389404296875)
        {
            res = min(res, (k * h) / t);
        }
        else
        {
            res = 0.0;
        }
        t += dt;
    }
    return res;
}

static inline __attribute__((always_inline))
float hash(thread const float& n)
{
    return fract(sin(n) * 43758.546875);
}

static inline __attribute__((always_inline))
float _noise(thread const float3& x)
{
    float3 p = floor(x);
    float3 f = fract(x);
    f = (f * f) * (float3(3.0) - (f * 2.0));
    float n = (p.x + (p.y * 57.0)) + (113.0 * p.z);
    float param = n + 0.0;
    float param_1 = n + 1.0;
    float param_2 = n + 57.0;
    float param_3 = n + 58.0;
    float param_4 = n + 113.0;
    float param_5 = n + 114.0;
    float param_6 = n + 170.0;
    float param_7 = n + 171.0;
    float res = mix(mix(mix(hash(param), hash(param_1), f.x), mix(hash(param_2), hash(param_3), f.x), f.y), mix(mix(hash(param_4), hash(param_5), f.x), mix(hash(param_6), hash(param_7), f.x), f.y), f.z);
    return res;
}

static inline __attribute__((always_inline))
float fbm(thread float3& p, thread float3x3& m)
{
    float f = 0.0;
    float3 param = p;
    f += (0.5 * _noise(param));
    p = (m * p) * 2.019999980926513671875;
    float3 param_1 = p;
    f += (0.25 * _noise(param_1));
    p = (m * p) * 2.0299999713897705078125;
    float3 param_2 = p;
    f += (0.125 * _noise(param_2));
    p = (m * p) * 2.0099999904632568359375;
    float3 param_3 = p;
    f += (0.0625 * _noise(param_3));
    return f / 0.9375;
}

static inline __attribute__((always_inline))
float3 appleColor(thread const float3& pos, thread const float3& nor, thread float2& spe, thread float3x3& m)
{
    spe.x = 1.0;
    spe.y = 1.0;
    float a = precise::atan2(pos.x, pos.z);
    float r = length(pos.xz);
    float3 param = pos * 1.0;
    float _359 = fbm(param, m);
    float f = smoothstep(0.0, 1.0, _359);
    float3 bite = pos - float3(1.2999999523162841796875, 1.0, 0.0);
    float3 param_1 = bite;
    float3 col = {};
    if ((length(bite) + biteNoise(param_1)) < 0.6150000095367431640625)
    {
        col = float3(0.800000011920928955078125);
        col = mix(col, float3(0.800000011920928955078125, 1.0, 0.20000000298023223876953125), float3(f));
    }
    else
    {
        col = float3(1.0, 0.0, 0.0);
    }
    col = mix(col, float3(0.800000011920928955078125, 1.0, 0.20000000298023223876953125), float3(f));
    float3 param_2 = pos * 4.0;
    float _391 = fbm(param_2, m);
    f = smoothstep(0.0, 1.0, _391);
    col *= (0.800000011920928955078125 + (0.20000000298023223876953125 * f));
    float3 param_3 = pos * 48.0;
    float _402 = fbm(param_3, m);
    f = smoothstep(0.0, 1.0, _402);
    f = smoothstep(0.699999988079071044921875, 0.89999997615814208984375, f);
    col = mix(col, float3(0.89999997615814208984375, 0.89999997615814208984375, 0.60000002384185791015625), float3(f * 0.5));
    float3 param_4 = float3((a * 7.0) + pos.z, 3.0 * pos.y, pos.x) * 2.0;
    float _428 = fbm(param_4, m);
    f = _428;
    f = smoothstep(0.20000000298023223876953125, 1.0, f);
    float3 param_5 = pos.zyx * 4.0;
    f *= smoothstep(0.4000000059604644775390625, 1.2000000476837158203125, pos.y + (0.75 * (_noise(param_5) - 0.5)));
    col = mix(col, float3(0.4000000059604644775390625, 0.20000000298023223876953125, 0.0), float3(0.5 * f));
    spe.x *= (1.0 - (0.3499999940395355224609375 * f));
    spe.y = 1.0 - (0.5 * f);
    f = 1.0 - smoothstep(0.14000000059604644775390625, 0.20000000298023223876953125, r);
    col = mix(col, float3(0.60000002384185791015625, 0.60000002384185791015625, 0.5), float3(f));
    spe.x *= (1.0 - f);
    float3 _479 = col;
    float2 _481 = _479.yz * 0.800000011920928955078125;
    col.y = _481.x;
    col.z = _481.y;
    float ao = 0.5 + (0.5 * nor.y);
    col *= (ao * 1.2000000476837158203125);
    return col;
}

static inline __attribute__((always_inline))
float3 floorColor(thread const float3& pos, thread const float3& nor, thread float2& spe, thread float3x3& m)
{
    spe.x = 1.0;
    spe.y = 1.0;
    float3 col = float3(0.85000002384185791015625, 0.680000007152557373046875, 0.5099999904632568359375);
    float3 param = (pos * 4.0) * float3(6.0, 0.0, 0.5);
    float _512 = fbm(param, m);
    float f = _512;
    col = mix(col, float3(0.5099999904632568359375, 0.3400000035762786865234375, 0.17000000178813934326171875), float3(f));
    spe.y = 1.0 + (4.0 * f);
    float3 param_1 = pos * 2.0;
    float _527 = fbm(param_1, m);
    f = _527;
    col *= (0.699999988079071044921875 + (0.300000011920928955078125 * f));
    float3 param_2 = pos * 48.0;
    float _537 = fbm(param_2, m);
    f = smoothstep(0.0, 1.0, _537);
    f = smoothstep(0.699999988079071044921875, 0.89999997615814208984375, f);
    col = mix(col, float3(0.20000000298023223876953125), float3(f * 0.75));
    f = smoothstep(0.100000001490116119384765625, 1.5499999523162841796875, length(pos.xz));
    col *= ((f * f) * 1.39999997615814208984375);
    col.x += (0.1500000059604644775390625 * (1.0 - f));
    return col;
}

fragment shader_raytrace_out shader_raytrace(constant ShaderUniforms& v_305 [[buffer(0)]], float4 fragCoordMetal [[position]])
{
    shader_raytrace_out out = {};
    // [[position]] is top-left. GLSL gl_FragCoord is bottom-left.
    float4 gl_FragCoord = fragCoordMetal;
    gl_FragCoord.y = v_305.resolution.y - fragCoordMetal.y;
    float3x3 m = float3x3(float3(0.0, 0.800000011920928955078125, 0.60000002384185791015625), float3(-0.800000011920928955078125, 0.9900000095367431640625, -0.4799999892711639404296875), float3(-0.60000002384185791015625, -0.89999997615814208984375, 0.63999998569488525390625));
    float2 q = gl_FragCoord.xy / v_305.resolution;
    float2 p = float2(-1.0) + (q * 2.0);
    p.x *= (v_305.resolution.x / v_305.resolution.y);
    float3 ro = normalize(float3(cos(0.20000000298023223876953125 * v_305.time), 1.14999997615814208984375 + (0.4000000059604644775390625 * cos(v_305.time * 0.10999999940395355224609375)), sin(0.20000000298023223876953125 * v_305.time))) * 5.5;
    float3 ww = normalize(float3(0.0, 0.5, 0.0) - ro);
    float3 uu = normalize(cross(float3(0.0, 1.0, 0.0), ww));
    float3 vv = normalize(cross(ww, uu));
    float3 rd = normalize(((uu * p.x) + (vv * p.y)) + (ww * 1.5));
    float3 col = float3(0.959999978542327880859375, 0.980000019073486328125, 1.0);
    float3 param = ro;
    float3 param_1 = rd;
    float2 tmat = intersect(param, param_1, v_305);
    if (tmat.y > 0.5)
    {
        float3 pos = ro + (rd * tmat.x);
        float3 param_2 = pos;
        float3 nor = calcNormal(param_2, v_305);
        float3 ref = reflect(rd, nor);
        float3 lig = float3(0.707106769084930419921875, 0.565685451030731201171875, -0.42426407337188720703125);
        float con = 1.0;
        float amb = 0.5 + (0.5 * nor.y);
        float dif = max(dot(nor, lig), 0.0);
        float bac = max(0.20000000298023223876953125 + (0.800000011920928955078125 * dot(nor, float3(-lig.x, lig.y, -lig.z))), 0.0);
        float rim = pow(1.0 + dot(nor, rd), 3.0);
        float spe = pow(clamp(dot(lig, ref), 0.0, 1.0), 16.0);
        float3 param_3 = pos;
        float3 param_4 = lig;
        float param_5 = 0.0599999986588954925537109375;
        float param_6 = 4.0;
        float param_7 = 4.0;
        float sh = softshadow(param_3, param_4, param_5, param_6, param_7, v_305);
        col = float3(0.800000011920928955078125, 0.89999997615814208984375, 1.0) * (0.100000001490116119384765625 * con);
        col += ((float3(1.0, 0.9700000286102294921875, 0.85000002384185791015625) * (0.699999988079071044921875 * dif)) * float3(sh, (sh + (sh * sh)) * 0.5, sh * sh));
        col += (float3(1.0, 0.9700000286102294921875, 0.85000002384185791015625) * (0.1500000059604644775390625 * bac));
        col += (float3(0.100000001490116119384765625, 0.1500000059604644775390625, 0.20000000298023223876953125) * (0.20000000298023223876953125 * amb));
        float2 pro = {};
        if (tmat.y < 1.5)
        {
            float3 param_8 = pos;
            float3 param_9 = nor;
            float2 param_10 = {};
            float3 _934 = appleColor(param_8, param_9, param_10, m);
            pro = param_10;
            col *= _934;
        }
        else
        {
            float3 param_11 = pos;
            float3 param_12 = nor;
            float2 param_13 = {};
            float3 _944 = floorColor(param_11, param_12, param_13, m);
            pro = param_13;
            col *= _944;
        }
        col += (((float3(1.0, 0.9700000286102294921875, 0.85000002384185791015625) * (0.60000002384185791015625 * rim)) * amb) * amb);
        col += (((float3(1.0) * (0.60000002384185791015625 * pow(spe, pro.y))) * pro.x) * sh);
        col = (col * 0.300000011920928955078125) + (sqrt(col) * 0.699999988079071044921875);
    }
    col *= (0.25 + (0.75 * pow((((16.0 * q.x) * q.y) * (1.0 - q.x)) * (1.0 - q.y), 0.1500000059604644775390625)));
    out.fragColor = float4(col, 1.0);
    return out;
}

