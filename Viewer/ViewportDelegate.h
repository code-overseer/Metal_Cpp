#ifndef ViewportDelegate_H
#define ViewportDelegate_H

#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
#import <Metal/Metal.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

@interface ViewportDelegate : NSObject <MTKViewDelegate>
-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;
@end

#endif /* Renderer_h */
