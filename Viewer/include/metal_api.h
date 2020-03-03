#ifndef metal_api_h
#define metal_api_h
#ifdef __OBJC__
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import <Foundation/Foundation.h>
#import "Renderer.h"
#endif

#include "graphics.h"
#include <algorithm>
#include <functional>
#include <type_traits>
#include <unordered_map>
#include <utility>
#include <stdexcept>

namespace metal_cpp {

enum StorageMode {
    Managed, Private, Shared
};

enum DispatchType {
    Concurrent, Serial
};

#ifdef __OBJC__
template <typename T>
inline constexpr NSUInteger GetEnum(T arg);

template <>
inline constexpr NSUInteger GetEnum<StorageMode>(StorageMode mode) {
    switch (mode) {
        case Shared:
            return MTLResourceStorageModeShared;
        case Managed:
            return MTLResourceStorageModeManaged;
        case Private:
            return MTLResourceStorageModePrivate;
    }
    return -1;
}

template <>
inline constexpr NSUInteger GetEnum<DispatchType>(DispatchType type) {
    return type == Concurrent ? MTLDispatchTypeConcurrent : MTLDispatchTypeSerial;
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
DEF_WRAPPER(Texture) // TODO

struct Buffer : public MetalObject {
private:
    void* raw_ = nullptr;
    unsigned long length_;
    StorageMode mode_;
    Buffer(void*& p, void* contents, unsigned long size, StorageMode mode) : MetalObject(p), raw_(contents), length_(size), mode_(mode) {
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
    StorageMode mode() const { return mode_; }
    void flush(int start = 0, int length = -1);
    ~Buffer() { raw_ = nullptr; length_ = 0; }
};

struct Metal_API {
private:
    static Device _getDevice();
protected:
    Device _device;
    Metal_API();
public:
    virtual void run(void* view) = 0;
    virtual void reset(float const* size) = 0;
    
    static CommandQueue createCommandQueue(Device const& device);
    static Library compileLibrary(Device const& device, char const* metal_code, bool fast_math);
    static Function getKernel(char const* kernel_name, Library const& library); //MTLFunction
    static CommandBuffer getCommandBuffer(CommandQueue const& command_queue); // MTLCommandBuffer
    static ComputePipelineState createComputeState(Device const& device, Function const& kernel); // MTLComputePipelineState
    static RenderPipelineState createRenderState(void* view,
                                                 Library const& library,
                                                 Device const& device,
                                                 char const* vertex,
                                                 char const* fragment);
    static ComputeCommandEncoder getCommandEncoder(CommandBuffer const& buffer, DispatchType mode);
    static RenderCommandEncoder getCommandEncoder(void* view,
                                                  CommandBuffer const& buffer,
                                                  Texture const &texture,
                                                  RenderPipelineState const &state,
                                                  int samples,
                                                  float const** sample_pos);
    static void endEncoding(ComputeCommandEncoder &encoder);
    static void endEncoding(RenderCommandEncoder &encoder);
    static void dispatchThreads(ComputeCommandEncoder const &encoder,
                               unsigned long const global_dim[3],
                               unsigned long const local_dim[3]);
    static unsigned long maxBlockSize(ComputePipelineState const& compute_pipeline_state);
    static unsigned long maxWarpSize(ComputePipelineState const& compute_pipeline_state);
    
    static Buffer mallocBuffer(Device const &device, void const* data, unsigned long size, StorageMode mode);
    static Buffer mallocBuffer(Device const &device, unsigned long size, StorageMode mode);
    static Texture createMultiSamplingTexture(void* view, Device const& device, unsigned long width, unsigned long height, unsigned long samples);
    static void setComputeBuffer(ComputeCommandEncoder const& encoder,
                                 Buffer const &buffer, unsigned long offset, unsigned long index);
    static void setVertexBuffer(RenderCommandEncoder const& encoder,
                                Buffer const &buffer, unsigned long offset, unsigned long index);
    static void setFragmentBuffer(RenderCommandEncoder const& encoder,
                                  Buffer const &buffer, unsigned long offset, unsigned long index);
    static void setBytes(ComputeCommandEncoder const& encoder,
                         void const* data, unsigned long size, unsigned long index);
    static void addCompletionHandler(CommandBuffer const& command_buffer,
                                     std::function<void()> on_complete);
    static double getTime();
    static void presentDrawable(void* view, CommandBuffer const& command_buffer, double at_time);
    static void commitCommandBuffer(CommandBuffer const& command_buffer);
};

}

#endif /* metal_api_h */

