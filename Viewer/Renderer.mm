#import "Renderer.h"
#import "include/graphics.h"

static const NSUInteger MaxFrames = 3;
@interface Renderer()

-(void)create_state:(MTKView*) view;
-(void)create_msaa:(MTKView*) view;

@end

@implementation Renderer
{
    id <MTLLibrary> library;
    id <MTLDevice> device;
    id <MTLRenderPipelineState> shader;
    id <MTLCommandQueue> queue;
    id <MTLTexture> msaa;
}

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view {
    self = [super init];
    if (self) {
        device = view.device;
        library = [device newDefaultLibrary];
        queue = [device newCommandQueue];
        
        NSError* error = nil;
        MTLRenderPipelineDescriptor* d = [[MTLRenderPipelineDescriptor alloc] init];
        d.sampleCount = 4;
        d.vertexFunction = [library newFunctionWithName:@"vertexShader"];
        d.fragmentFunction = [library newFunctionWithName:@"fragmentShader"];
        d.colorAttachments[0].pixelFormat = view.colorPixelFormat;
        d.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
        shader = [device newRenderPipelineStateWithDescriptor:d error:&error];
        
        if (!shader)
        {
            NSLog(@"Failed to created pipeline state, error %@", error);
        }
    }
    
    return self;
}

- (void) drawInMTKView:(nonnull MTKView *)view {
  
}

- (void) mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {

}

- (void)create_state:(MTKView*) view {
    
}
-(void)create_msaa:(MTKView*) view {
    MTLTextureDescriptor* tex = [[MTLTextureDescriptor alloc] init];
    tex.textureType = MTLTextureType2DMultisampleArray;
    tex.width = view.;
    tex.height = height;
    tex.sampleCount = 4;
    tex.pixelFormat = view.colorPixelFormat;
    tex.usage = MTLTextureUsageRenderTarget;
    tex.storageMode = MTLStorageModePrivate;
    auto texture = [(__bridge id <MTLDevice>)(device._ptr) newTextureWithDescriptor:tex];
}
@end


