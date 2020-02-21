#ifndef Renderer_h
#define Renderer_h

#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
#import <Metal/Metal.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

@interface Renderer : NSObject <MTKViewDelegate>

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;

@end

#endif /* Renderer_h */
