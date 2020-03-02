#import "../include/Renderer.h"
#import "../include/graphics.h"
#import "../include/metal_api.h"
#import <QuartzCore/QuartzCore.h>
#include <iostream>

static const NSUInteger MaxFrames = 1;

void* RENDERER = NULL;

@interface Renderer()

-(MTLRenderPassDescriptor*) getPassDescriptor:(nonnull MTKView *)view;

@end

@implementation Renderer
{
    dispatch_semaphore_t _frameSemaphore;
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;
    id <MTLLibrary> _defaultLibrary;
    id <MTLRenderPipelineState> _pipelineState;
    id <MTLTexture> _sampleTexture;
    id <MTLBuffer> _testBuffer;
    MTLSamplePosition _samplePositions[4];
    
}
-(void)setBuffer:(nonnull void*) buffer {
    _testBuffer = (__bridge id <MTLBuffer>)(buffer);
    float* v = reinterpret_cast<float*>([_testBuffer contents]);
    printf("%f,%f,%f,%f\n", v[0],v[1],v[2],v[3]);
    
}

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view {
    self = [super init];
    if(self)
    {
        _device = view.device;
        _frameSemaphore = dispatch_semaphore_create(MaxFrames);
        _defaultLibrary = [_device newDefaultLibrary];
        _commandQueue = [_device newCommandQueue];
        [self createPipeline:view];
        _samplePositions[0] = MTLSamplePositionMake(0.25, 0.25);
        _samplePositions[1] = MTLSamplePositionMake(0.75, 0.25);
        _samplePositions[2] = MTLSamplePositionMake(0.75, 0.75);
        _samplePositions[3] = MTLSamplePositionMake(0.25, 0.75);
        _testBuffer = nil;
        RENDERER = (__bridge void*)(self);
        
        simd_float4x4 ltw = simd_matrix(simd_make_float4(1,0,0,0),
                                        simd_make_float4(0,1,0,0),
                                        simd_make_float4(0,0,1,0),
                                        simd_make_float4(0,0,0,1));
        _testBuffer = [_device newBufferWithBytes:&ltw length:sizeof(simd_float4x4) options:MTLResourceStorageModeManaged];
    }
    
    return self;
}

- (void) drawInMTKView:(nonnull MTKView *)view {
    if (!_testBuffer) return;
    CFTimeInterval target = CACurrentMediaTime() + 1.0/60.0;
    
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"DrawCommand";
    
    auto rpd = [self getPassDescriptor:view];
    auto encoder = [commandBuffer renderCommandEncoderWithDescriptor:rpd];
    
    [encoder setRenderPipelineState: _pipelineState];
    [encoder setVertexBuffer:_testBuffer offset:0 atIndex:0];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
    
    [encoder endEncoding];
    [commandBuffer presentDrawable:view.currentDrawable atTime:target];
    [commandBuffer commit];
}

- (void) mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    MTLTextureDescriptor* tex = [[MTLTextureDescriptor alloc] init];
    tex.textureType = MTLTextureType2DMultisampleArray;
    tex.width = size.width;
    tex.height = size.height;
    tex.sampleCount = 4;
    tex.pixelFormat = view.colorPixelFormat;
    tex.usage = MTLTextureUsageRenderTarget;
    tex.storageMode = MTLStorageModePrivate;
    dispatch_semaphore_wait(_frameSemaphore, DISPATCH_TIME_FOREVER);
    _sampleTexture = [_device newTextureWithDescriptor:tex];
    dispatch_semaphore_signal(_frameSemaphore);
}

- (void) createPipeline:(nonnull MTKView*)view {
    NSError* error = nil;
    MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    
    pipelineDescriptor.vertexFunction = [_defaultLibrary newFunctionWithName:@"vertexShader"];
    pipelineDescriptor.fragmentFunction = [_defaultLibrary newFunctionWithName:@"fragmentShader"];
    
    pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    pipelineDescriptor.colorAttachments[0].blendingEnabled = true;
    pipelineDescriptor.sampleCount = 4;
    
    pipelineDescriptor.colorAttachments[0].rgbBlendOperation =    MTLBlendOperationAdd;
    pipelineDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
    pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;
    
    pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    pipelineDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    
    if (!_pipelineState)
    {
        NSLog(@"Failed to created pipeline state, error %@", error);
    }
}

- (MTLRenderPassDescriptor*) getPassDescriptor:(nonnull MTKView *)view {
    auto rpd = view.currentRenderPassDescriptor;
    dispatch_semaphore_wait(_frameSemaphore, DISPATCH_TIME_FOREVER);
    rpd.colorAttachments[0].texture = _sampleTexture;
    dispatch_semaphore_signal(_frameSemaphore);
    //    printf("%lu, %lu\n", (unsigned long)_sampleTexture.width, _sampleTexture.height);
    rpd.colorAttachments[0].resolveTexture = view.currentDrawable.texture;
    rpd.colorAttachments[0].loadAction = MTLLoadActionClear;
    rpd.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    rpd.colorAttachments[0].storeAction = MTLStoreActionMultisampleResolve;
    [rpd setSamplePositions:_samplePositions count:4];
    return rpd;
}

@end

