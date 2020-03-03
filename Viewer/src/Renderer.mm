#import "../include/Renderer.h"
#import "../include/graphics.h"
#import <QuartzCore/QuartzCore.h>
#include <iostream>

static const NSUInteger MaxFrames = 3;

void* RENDERER = NULL;

@interface Renderer()

-(MTLRenderPassDescriptor*) getPassDescriptor:(nonnull MTKView *)view;
-(void) updateBuffers;

@end

@implementation Renderer
{
    dispatch_semaphore_t _frameSemaphore;
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;
    id <MTLLibrary> _defaultLibrary;
    id <MTLRenderPipelineState> _simpleShader;
    id <MTLTexture> _sampleTexture;
    GPUPayload* _payload;
    id <MTLBuffer> _localToWorlds[MaxFrames];
    id <MTLBuffer> _viewMatrix[MaxFrames];
    id <MTLBuffer> _projectionMatrix[MaxFrames];
    int _frameIdx;
    
}
-(void)setPayload:(nonnull GPUPayload*) payload {
    _payload = payload;
    for (int i =0; i < MaxFrames; ++i) {
        _localToWorlds[i] = [_device newBufferWithBytes: payload->localToWorld length:payload->instance_count*sizeof(simd_float4x4) options:MTLResourceStorageModeShared];
    }
}

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view {
    self = [super init];
    if(self)
    {
        _frameIdx = 0;
        _device = view.device;
        _frameSemaphore = dispatch_semaphore_create(MaxFrames);
        _defaultLibrary = [_device newDefaultLibrary];
        _commandQueue = [_device newCommandQueue];
        [self createPipeline:view];
        _payload = nil;
        _camera.zoom(10.f);
        _camera.position(simd_make_float2(0, 0));
        auto v = _camera.view();
        for (int i = 0; i < MaxFrames; ++i) {
            _projectionMatrix[i] = [_device newBufferWithLength:sizeof(simd_float4x4)
                                                    options:MTLResourceStorageModeShared];
            _viewMatrix[i] = [_device newBufferWithBytes:&v
                                                  length:sizeof(simd_float4x4)
                                                 options:MTLResourceStorageModeShared];
        }
        
        RENDERER = (__bridge void*)(self);
        
    }
    
    return self;
}

- (void) drawInMTKView:(nonnull MTKView *)view {
    if (!_payload || !_projectionMatrix[_frameIdx]) return;
    dispatch_semaphore_wait(_frameSemaphore, DISPATCH_TIME_FOREVER);
    CFTimeInterval target = CACurrentMediaTime() + 1.0/60.0;
    [self updateBuffers];
    
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    
    auto rpd = [self getPassDescriptor:view];
    auto encoder = [commandBuffer renderCommandEncoderWithDescriptor:rpd];
    
    [encoder setRenderPipelineState: _simpleShader];
    [encoder setVertexBuffer: (__bridge id<MTLBuffer>)(_payload->vertices.getBuffer())
                      offset:0 atIndex:0];
    [encoder setVertexBuffer: _localToWorlds[_frameIdx]
                      offset:0 atIndex:1];
    [encoder setVertexBuffer: (__bridge id<MTLBuffer>)(_payload->colour.getBuffer())
                      offset:0 atIndex:2];
    [encoder setVertexBuffer: _viewMatrix[_frameIdx] offset:0 atIndex:3];
    [encoder setVertexBuffer: _projectionMatrix[_frameIdx] offset:0 atIndex:4];
    
    [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                        indexCount:_payload->triangles.count<uint16>()
                         indexType:MTLIndexTypeUInt16
                       indexBuffer:(__bridge id<MTLBuffer>)(_payload->triangles.getBuffer()) indexBufferOffset:0];
    
    [encoder endEncoding];
    [commandBuffer presentDrawable:view.currentDrawable atTime:target];
    
    __block dispatch_semaphore_t block_sema = _frameSemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer)
     {
        dispatch_semaphore_signal(block_sema);
    }];
    
    [commandBuffer commit];
    _frameIdx = (_frameIdx + 1) % MaxFrames;
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
    _sampleTexture = [_device newTextureWithDescriptor:tex];
    _camera.rcp_aspect(size.height/size.width);
}

-(void) updateBuffers {
    auto ptr = reinterpret_cast<simd_float4x4*>([_localToWorlds[_frameIdx] contents]);
    memcpy(ptr, _payload->localToWorld, _payload->instance_count*sizeof(simd_float4x4));
    auto tmp = _camera.projection();
    ptr = reinterpret_cast<simd_float4x4*>([_projectionMatrix[_frameIdx] contents]);
    memcpy(ptr, &tmp, sizeof(simd_float4x4));
    tmp = _camera.view();
    ptr = reinterpret_cast<simd_float4x4*>([_viewMatrix[_frameIdx] contents]);
    memcpy(ptr, &tmp, sizeof(simd_float4x4));
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
    _simpleShader = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    
    if (!_simpleShader)
    {
        NSLog(@"Failed to created pipeline state, error %@", error);
    }
}

- (MTLRenderPassDescriptor*) getPassDescriptor:(nonnull MTKView *)view {
    auto rpd = view.currentRenderPassDescriptor;
    
    rpd.colorAttachments[0].texture = _sampleTexture;

    rpd.colorAttachments[0].resolveTexture = view.currentDrawable.texture;
    rpd.colorAttachments[0].loadAction = MTLLoadActionClear;
    rpd.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    rpd.colorAttachments[0].storeAction = MTLStoreActionMultisampleResolve;
    MTLSamplePosition samplePositions[4];
    samplePositions[0] = MTLSamplePositionMake(0.25, 0.25);
    samplePositions[1] = MTLSamplePositionMake(0.75, 0.25);
    samplePositions[2] = MTLSamplePositionMake(0.75, 0.75);
    samplePositions[3] = MTLSamplePositionMake(0.25, 0.75);
    [rpd setSamplePositions:samplePositions count:4];
    return rpd;
}

@end

