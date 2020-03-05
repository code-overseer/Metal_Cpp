#ifndef metal_api_h
#define metal_api_h
#ifdef __OBJC__
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import <Foundation/Foundation.h>
#endif

#include <algorithm>
#include <functional>
#include <type_traits>
#include <unordered_map>
#include <utility>
#include <stdexcept>

namespace mtl_cpp {

enum ResourceOptions {
    Managed, Private, Shared
};

enum DispatchType {
    Concurrent, Serial
};

enum BarrierScope {
    Buffers, Textures, RenderTargets
};

enum RenderStage {
    Vertex, Fragment
};

enum PrimitiveType {
    Point, Line, LineStrip, Triangle, TriangleStrip
};

enum IndexType {
    UINT16, UINT32
};

#ifdef __OBJC__
template <typename T, typename U>
inline constexpr U GetEnum(T arg);

template <>
inline constexpr MTLBarrierScope GetEnum<BarrierScope, MTLBarrierScope>(BarrierScope scope) {
    switch (scope) {
        case Buffers:
            return MTLBarrierScopeBuffers;
        case Textures:
            return MTLBarrierScopeTextures;
        case RenderTargets:
            return MTLBarrierScopeRenderTargets;
    }
    return MTLBarrierScopeBuffers;
}

template <>
inline constexpr MTLResourceOptions GetEnum<ResourceOptions, MTLResourceOptions>(ResourceOptions mode) {
    switch (mode) {
        case Shared:
            return MTLResourceStorageModeShared;
        case Managed:
            return MTLResourceStorageModeManaged;
        case Private:
            return MTLResourceStorageModePrivate;
    }
    return MTLResourceStorageModeShared;
}

template <>
inline constexpr MTLDispatchType GetEnum<DispatchType, MTLDispatchType>(DispatchType type) {
    return type == Concurrent ? MTLDispatchTypeConcurrent : MTLDispatchTypeSerial;
}

template <>
inline constexpr MTLRenderStages GetEnum<RenderStage,MTLRenderStages>(RenderStage stage) {
    return stage == Vertex ? MTLRenderStageVertex : MTLRenderStageFragment;
}

template <>
inline constexpr MTLPrimitiveType GetEnum<PrimitiveType, MTLPrimitiveType>(PrimitiveType type) {
    switch (type) {
        case Point:
            return MTLPrimitiveTypePoint;
        case Line:
            return MTLPrimitiveTypeLine;
        case LineStrip:
            return MTLPrimitiveTypeLineStrip;
        case Triangle:
            return MTLPrimitiveTypeTriangle;
        case TriangleStrip:
            return MTLPrimitiveTypeTriangleStrip;
    }
    return MTLPrimitiveTypeTriangle;
}

template <>
inline constexpr MTLIndexType GetEnum<IndexType, MTLIndexType>(IndexType type) {
    return type == UINT16 ? MTLIndexTypeUInt16 : MTLIndexTypeUInt32;
}
#endif /* __OBJC__ **/

struct MetalObject {
protected:
    void* _ptr = nullptr;
    void _free();
    explicit MetalObject(void*& p) : _ptr(p) { p = nullptr; }
    MetalObject(MetalObject&& other) {
        _free();
        _ptr = other._ptr;
        other._ptr = nullptr;
    }
    MetalObject() = default;
public:
    MetalObject ( MetalObject const& other) = delete;
    virtual ~MetalObject() { _free(); }
};

#define DEF_WRAPPER(TYPE) \
struct TYPE : public MetalObject { \
TYPE(TYPE &&other) noexcept : MetalObject(std::move(other)) {} \
TYPE& operator=(TYPE &&other) noexcept { \
if (this == &other) return *this; \
_free(); \
_ptr = other._ptr; \
other._ptr = nullptr; \
return *this; \
} \
friend class Metal_API; \
private: \
TYPE(void*& p) : MetalObject(p) {}; \
};

DEF_WRAPPER(Device)
DEF_WRAPPER(CommandQueue)
DEF_WRAPPER(CommandBuffer)
DEF_WRAPPER(Library)
DEF_WRAPPER(Function)
DEF_WRAPPER(ComputePipelineState)
DEF_WRAPPER(ComputeCommandEncoder)
DEF_WRAPPER(RenderPipelineState)
DEF_WRAPPER(RenderCommandEncoder)
DEF_WRAPPER(BlitCommandEncoder)
DEF_WRAPPER(Texture) // TODO

struct Buffer : public MetalObject {
private:
    void* raw_ = nullptr;
    unsigned long length_;
    ResourceOptions mode_;
    Buffer(void*& p, void* contents, unsigned long size, ResourceOptions mode) : MetalObject(p), raw_(contents), length_(size), mode_(mode) {
        p = nullptr;
    }
public:
    friend class Metal_API;
    Buffer ( Buffer const &other ) = delete;
    Buffer ( Buffer &&other ) noexcept : MetalObject(std::move(other)) {
        raw_ = other.raw_;
        mode_ = other.mode_;
        other.raw_ = nullptr;
        other.length_ = 0;
    }
    Buffer& operator=( Buffer &&other ) noexcept {
        if (this == &other) return *this;
        _free();
        _ptr = other._ptr;
        raw_ = other.raw_;
        mode_ = other.mode_;
        other.raw_ = nullptr;
        other._ptr = nullptr;
        other.length_ = 0;
        return *this;
    }
    template<typename T>
    T* raw() { return reinterpret_cast<T*>(raw_); }
    void copy(void const* src, unsigned long size) {
        if (mode_ != Private && raw_) memcpy(raw_, src, size);
    }
    template<typename T = void>
    unsigned long length() const {
        if constexpr (std::is_same<void, T>::value) {
            return length_;
        }
        return length_ / sizeof(T);
    }
    ResourceOptions mode() const { return mode_; }
    void flush(int start = 0, int length = -1);
    ~Buffer() { raw_ = nullptr; length_ = 0; }
};

struct Metal_API {
private:
    static Metal_API* _context;
    static bool _assigned;
protected:
    Metal_API();
public:
    Metal_API(Metal_API const&) = delete;
    Metal_API(Metal_API &&) = delete;
    Metal_API& operator=(Metal_API const&) = delete;
    Metal_API& operator=(Metal_API &&) = delete;
    /* Do NOT call this from cpp, it closes connection to Obj-C */
    static void terminateContext();
    static void draw(void* view);
    static void resize(void* view, float const size[2]);
    virtual void onDraw(void* view) = 0;
    virtual void onSizeChange(void* view, float const size[2]) = 0;
    virtual ~Metal_API();
    static Device getDevice();
    static CommandQueue createCommandQueue(Device const& device);
    static Library compileLibrary(Device const& device, char const* metal_code, bool fast_math);
    static Function getFunction(char const* kernel_name, Library const& library);
    static CommandBuffer getCommandBuffer(CommandQueue const& command_queue);
    static ComputePipelineState createComputeState(Device const& device, Function const& kernel);
    static RenderPipelineState createRenderState(void* view,
                                                 Library const& library,
                                                 Device const& device,
                                                 unsigned long samples,
                                                 char const* vertex,
                                                 char const* fragment);
    static ComputeCommandEncoder getComputeCommandEncoder(CommandBuffer const& buffer, DispatchType mode);
    static RenderCommandEncoder getRenderCommandEncoder(void* view,
                                                        CommandBuffer const& buffer,
                                                        Texture const &texture,
                                                        int samples,
                                                        float const** sample_pos);
    static BlitCommandEncoder getBlitCommandEncoder(CommandBuffer const& buffer);
    static void setState(RenderCommandEncoder const& encoder, RenderPipelineState const &state);
    static void setState(ComputeCommandEncoder const& encoder, ComputePipelineState const &state);
    
    static void bufferToBuffer(BlitCommandEncoder const& encoder,
                               Buffer const& src, unsigned long src_offset,
                               Buffer const& dst, unsigned long dst_offset, unsigned long size);
    static void setBuffer(BlitCommandEncoder const& encoder,
                          Buffer const& buffer, unsigned long start,
                          unsigned long size, unsigned char byte);
    static void syncResource(BlitCommandEncoder const& encoder, Buffer const& resource);
    static void syncResource(BlitCommandEncoder const& encoder, Texture const& resource);
    
    static void endEncoding(ComputeCommandEncoder &encoder);
    static void endEncoding(RenderCommandEncoder &encoder);
    static void dispatchThreads(ComputeCommandEncoder const &encoder,
                                unsigned long const global_dim[3],
                                unsigned long const local_dim[3]);
    static void waitUntilScheduled(CommandBuffer const&buffer);
    static void waitUntilCompleted(CommandBuffer const&buffer);
    static unsigned long maxBlockSize(ComputePipelineState const& compute_pipeline_state);
    static unsigned long maxWarpSize(ComputePipelineState const& compute_pipeline_state);
    
    static Buffer mallocBuffer(Device const &device, void const* data, unsigned long size, ResourceOptions mode);
    static Buffer mallocBuffer(Device const &device, unsigned long size, ResourceOptions mode);
    static Texture createMultiSamplingTexture(void* view, Device const& device, unsigned long width, unsigned long height, unsigned long samples);
    static void setComputeBuffer(ComputeCommandEncoder const& encoder,
                                 Buffer const &buffer, unsigned long offset, unsigned long index);
    static void setVertexBuffer(RenderCommandEncoder const& encoder,
                                Buffer const &buffer, unsigned long offset, unsigned long index);
    static void setFragmentBuffer(RenderCommandEncoder const& encoder,
                                  Buffer const &buffer, unsigned long offset, unsigned long index);
    static void setBytes(ComputeCommandEncoder const& encoder,
                         void const* data, unsigned long size, unsigned long index);
    static void mallocSharedMemory(ComputeCommandEncoder const& encoder, unsigned long size, unsigned long index);
    static void addCompletionHandler(CommandBuffer const& command_buffer,
                                     std::function<void()> on_complete);
    static void addScheduleHandler(CommandBuffer const& command_buffer,
                                   std::function<void()> on_schedule);
    static double getTime();
    static void presentDrawable(void* view, CommandBuffer const& command_buffer, double at_time);
    static void commitCommandBuffer(CommandBuffer const& command_buffer);
#define ULONG unsigned long
    static void drawMesh(RenderCommandEncoder const& encoder, PrimitiveType type, ULONG vert_start,
                         ULONG vert_count, ULONG instances = 1, ULONG instance_base = 0);
    static void drawMesh(RenderCommandEncoder const& encoder, PrimitiveType type,
                         ULONG idx_count, IndexType idx_type, Buffer const& idx, ULONG buffer_offset,
                         ULONG instances = 1, ULONG vert_base = 0, ULONG instance_base = 0);
    
#undef ULONG
};

}


#undef DEF_WRAPPER
#endif /* metal_api_h */

