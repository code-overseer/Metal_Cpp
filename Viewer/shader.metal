#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

struct VertexOut {
    simd_float4 position [[position]];
    simd_float4 color;
};

constant constexpr static const float4 VERTS[3]
{
    {-0.5f, -0.5f, 0.f, 1.f},
    { 0.5f, -0.5f, 0.f, 1.f},
    {  0.f, 0.5f, 0.f, 1.f}
};

vertex VertexOut vertexShader(unsigned int vid [[vertex_id]], constant const simd_float4x4 & ltw [[buffer(0)]]) {
    VertexOut output;
    output.position = ltw * VERTS[vid];
    return output;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]]) {
    return float4(1,0,0,1);
}
