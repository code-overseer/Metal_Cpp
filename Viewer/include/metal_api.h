#ifndef metal_api_h
#define metal_api_h
#ifdef __OBJC__
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import <Foundation/Foundation.h>
#include <unordered_map>
#include <algorithm>
#import "Renderer.h"
#include "graphics.h"
#endif
#ifdef __cplusplus
#include <functional>
#endif
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
template <typename T, T t>
NSUInteger GetEnum();

template <>
NSUInteger GetEnum<StorageMode, Shared>() { return MTLResourceStorageModeShared; };
template <>
NSUInteger GetEnum<StorageMode, Managed>() { return MTLResourceStorageModeManaged; };
template <>
NSUInteger GetEnum<StorageMode, Private>() { return MTLResourceStorageModePrivate; };


template <>
NSUInteger GetEnum<DispatchType, Concurrent>() { return MTLDispatchTypeConcurrent; };
template <>
NSUInteger GetEnum<DispatchType, Serial>() { return MTLDispatchTypeSerial; };
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

struct Buffer : public MetalObject {
private:
    void* raw_ = nullptr;
    unsigned long length_;
    StorageMode mode_;
    Buffer(void*& p, void* contents, unsigned long size, StorageMode mode) : MetalObject(p), raw_(contents), length_(size), mode_(mode) {
        // contents = nullptr if mode == Private
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
    void flush();
    ~Buffer() { raw_ = nullptr; length_ = 0; }
};

struct Metal_API {
private:
    static Device _getDevice();
    static CommandQueue _createCommandQueue(Device const& device);
protected:
    Device _device;
    CommandQueue _commandQueue;
    Metal_API();
public:
    virtual void run(void* view) = 0;
    virtual void reset(float const* size) = 0;
    
    static Library compileLibrary(char const* metal_code, bool fast_math); //MTLLibrary
    static Function getKernel(char const* kernel_name, Library const& library); //MTLFunction
    static CommandBuffer getCommandBuffer(CommandQueue const& command_queue); // MTLCommandBuffer
    static ComputePipelineState createComputeState(Function const& kernel); // MTLComputePipelineState
    static RenderPipelineState createRenderState(Library const& library, char const* vertex, char const* fragment);
    static ComputeCommandEncoder getCommandEncoder(DispatchType mode);
    static RenderCommandEncoder getCommandEncoder(void* view, RenderPipelineState const &state); // MTLRenderCommandEncoder
    static void endEncoding(ComputeCommandEncoder &&encoder);
    static void endEncoding(RenderCommandEncoder &&encoder);
    static void dispatchKernel(float const* global_dim, float const* local_dim);
    static unsigned long maxBlockSize(ComputePipelineState const& compute_pipeline_state);
    static unsigned long maxWarpSize(ComputePipelineState const& compute_pipeline_state);
    
    static Buffer mallocBuffer(void const* data, unsigned long size, StorageMode mode);
    static Buffer mallocBuffer(unsigned long size, StorageMode mode);
    static Buffer wrapMemoryToBuffer(void const* data, unsigned long size,
                                       StorageMode mode);
    static void setComputeBuffer(Buffer const &buffer, unsigned long offset, unsigned long index);
    static void setVertexBuffer(Buffer const &buffer, unsigned long offset, unsigned long index);
    static void setFragmentBuffer(Buffer const &buffer, unsigned long offset, unsigned long index);
    static void setBytes(void const* data, unsigned long size, unsigned long index);
    static double getTime();
    static void presentDrawable(void* view, double at_time);
    static void commitCommandBuffer(CommandBuffer const& command_buffer);
};

}

#endif /* metal_api_h */

