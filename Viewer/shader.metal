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

vertex VertexOut vertexShader(ushort vid [[vertex_id]],
                              unsigned int iid [[instance_id]],
                              constant const simd_float3* verts [[buffer(0)]],
                              constant const simd_float4x4* model [[buffer(1)]],
                              constant const simd_float4& colour [[buffer(2)]],
                              constant const simd_float4x4& view [[buffer(3)]],
                              constant const simd_float4x4& proj [[buffer(4)]]) {
    VertexOut output;
    output.position = proj * view * model[iid] * simd_float4(verts[vid], 1);
    output.color = colour;
    
    return output;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]]) {
    return in.color;
}
