#ifndef Renderer_h
#define Renderer_h

#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
#import <Metal/Metal.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

struct Camera {
private:
    float zoom_ = 10.f;
    float rcp_aspect_ = 1.f;
    simd_float2 position_;
public:
    simd_float4x4 view() const {
        return simd_matrix(simd_make_float4(1, 0, 0, 0),
                    simd_make_float4(0, 1, 0, 0),
                    simd_make_float4(0, 0, 1, 0),
                    simd_make_float4(-position_, 1, 1));
    }
    simd_float4x4 projection() const {
        return simd_matrix(simd_make_float4(2 * rcp_aspect_/zoom_, 0,0,0),
                           simd_make_float4(0, 2/zoom_, 0, 0),
                           simd_make_float4(0, 0,-0.002f,0),
                           simd_make_float4(0, 0,-1.002f,1));
    }
    float zoom() const { return zoom_; }
    float rcp_aspect() const { return rcp_aspect_; }
    simd_float2 position() const { return position_; }
    void zoom(float z) { zoom_ = z; }
    void rcp_aspect(float a) { rcp_aspect_ = a; }
    void position(simd_float2 p) { position_ = p; }
};

@interface Renderer : NSObject <MTKViewDelegate>

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;
@property Camera camera;
@end

#endif /* Renderer_h */
