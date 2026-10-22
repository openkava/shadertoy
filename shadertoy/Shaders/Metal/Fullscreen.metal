#include <metal_stdlib>

using namespace metal;

struct FullscreenOut {
    float4 position [[position]];
};

// One triangle large enough to cover clip space. Metal's NDC Y axis points up,
// matching OpenGL, so the fragment Y flip lives with gl_FragCoord instead.
vertex FullscreenOut fullscreen_vertex(uint vid [[vertex_id]]) {
    const float2 positions[3] = {
        float2(-1.0, -1.0),
        float2( 3.0, -1.0),
        float2(-1.0,  3.0)
    };
    FullscreenOut out;
    out.position = float4(positions[vid], 0.0, 1.0);
    return out;
}
