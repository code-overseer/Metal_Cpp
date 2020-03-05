#import "ViewportDelegate.h"
#import "include/Cocoa_API.h"
#import "include/Metal_API.h"

@implementation ViewportDelegate
{
//    id <MTLLibrary> library;
//    id <MTLDevice> device;
//    id <MTLRenderPipelineState> shader;
//    id <MTLCommandQueue> queue;
//    id <MTLTexture> msaa;
}

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view {
    self = [super init];
    if (self) {
        view.enableSetNeedsDisplay = NO;
        view.paused = YES;
        view.device = MTLCreateSystemDefaultDevice();
        view.delegate = self;
        mtl_cpp::Metal_API::initialize((__bridge void*)(view));
        [self mtkView:view drawableSizeWillChange:view.drawableSize];
//        device = view.device;
//        library = [device newDefaultLibrary];
//        queue = [device newCommandQueue];
//
//        NSError* error = nil;
//        MTLRenderPipelineDescriptor* d = [[MTLRenderPipelineDescriptor alloc] init];
//        d.sampleCount = 4;
//        d.vertexFunction = [library newFunctionWithName:@"vertexShader"];
//        d.fragmentFunction = [library newFunctionWithName:@"fragmentShader"];
//        d.colorAttachments[0].pixelFormat = view.colorPixelFormat;
//        d.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
//        shader = [device newRenderPipelineStateWithDescriptor:d error:&error];
//
//        if (!shader)
//        {
//            NSLog(@"Failed to created pipeline state, error %@", error);
//        }
    }
    
    return self;
}

- (void) drawInMTKView:(nonnull MTKView *)view {
//    @autoreleasepool {
//        double target = CACurrentMediaTime() + 1.0/60.0;
//        id <MTLCommandBuffer> buffer = [queue commandBuffer];
//        auto rpd = view.currentRenderPassDescriptor;
//        rpd.colorAttachments[0].texture = msaa;
//        rpd.colorAttachments[0].resolveTexture = view.currentDrawable.texture;
//        rpd.colorAttachments[0].loadAction = MTLLoadActionClear;
//        rpd.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
//        rpd.colorAttachments[0].storeAction = MTLStoreActionMultisampleResolve;
//        MTLSamplePosition samplePositions[4];
//        float const pos[4][2] = {{0.25,0.75},{0.75,0.75},{0.25,0.25},{0.75,0.25}};
//        for (int i = 0; i < 4; ++i)
//            samplePositions[i] = MTLSamplePositionMake(pos[i][0], pos[i][1]);
//        [rpd setSamplePositions:samplePositions count:4];
//
//        id <MTLRenderCommandEncoder> encoder = [buffer renderCommandEncoderWithDescriptor:rpd];
//        [encoder setRenderPipelineState:shader];
//        [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
//        [encoder endEncoding];
//        [buffer presentDrawable:view.currentDrawable atTime:target];
//        [buffer commit];
//    }
    mtl_cpp::Metal_API::draw((__bridge void*)(view));
}

- (void) mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
//    MTLTextureDescriptor* tex = [[MTLTextureDescriptor alloc] init];
//    tex.textureType = MTLTextureType2DMultisampleArray;
//    tex.width = size.width;
//    tex.height = size.height;
//    tex.sampleCount = 4;
//    tex.pixelFormat = view.colorPixelFormat;
//    tex.usage = MTLTextureUsageRenderTarget;
//    tex.storageMode = MTLStorageModePrivate;
//    msaa = [device newTextureWithDescriptor:tex];
    float s[2]{static_cast<float>(size.width), static_cast<float>(size.height)};
    mtl_cpp::Metal_API::resize((__bridge void*)(view), s);
}



@end


