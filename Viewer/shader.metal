#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

struct VertexOut {
    simd_float4 position [[position]];
};

constant constexpr static const float4 VERTS[3]
{
    {-0.5f, -0.5f, 0.f, 1.f},
    { 0.5f, -0.5f, 0.f, 1.f},
    {  0.f, 0.5f, 0.f, 1.f}
};

vertex VertexOut vertexShader(ushort vid [[vertex_id]]) {
    VertexOut output;
    output.position = VERTS[vid];
    
    return output;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]]) {
    return float4(1,0,0,1);
}
