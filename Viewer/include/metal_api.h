#ifndef metal_api_h
#define metal_api_h
#ifdef __OBJC__
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import "Renderer.h"
#else
#include <type_traits>
#include <cstdlib>
#endif
#include <functional>

enum StorageMode {
    Managed,
    Private,
    Shared
};
enum TextureUsage {
    Read,
    Write,
};



class MetalBuffer {
private:
    void* _raw = nullptr;
    void* _bufferObject = nullptr;
    bool _dirty;
    size_t size_;
    StorageMode mode_;
public:
    MetalBuffer() = delete;
    MetalBuffer(MetalBuffer const& other) = delete;
    MetalBuffer(MetalBuffer &&other) noexcept;
    MetalBuffer& operator=(MetalBuffer &&other) noexcept;
    MetalBuffer(int size, StorageMode mode);
    MetalBuffer(void const* content, int size, StorageMode mode);
    virtual ~MetalBuffer();
    inline StorageMode mode() const { return mode_; }
    inline size_t size() const { return size_; }
    template<typename T>
    inline size_t count() const { return size_ / sizeof(T); }
    void commit();
    template<typename T>
    inline T get(int i) const {
        if (mode_ != Private && _raw && i < count<T>()) {
            return reinterpret_cast<T*>(_raw)[i];
        }
        return T();
    }
    template<typename T>
    inline void set(int i, T input) {
        if (mode_ != Private && _raw && i < count<T>()) {
            reinterpret_cast<T*>(_raw)[i] = input;
            _dirty = true;
        }
    }
    template<typename T>
    void operate(std::function<void(T*,size_t)>& operation) {
        if (mode_ != Private && _raw) {
            _dirty = true;
            operation(reinterpret_cast<T*>(_raw), count<T>());
        }
    }
    void setBuffer() const;
};

#ifdef TEXTURE_DEFINED
class MetalTexture {
private:
    size_t width_;
    size_t height_;
    TextureUsage usage_;
    void* _textureObject = nullptr;
public:
    MetalTexture() = delete;
    MetalTexture(MetalTexture const& other) = delete;
    MetalTexture(MetalTexture &&other) noexcept;
    MetalTexture& operator=(MetalTexture &&other) noexcept;
    virtual ~MetalTexture();
    MetalTexture(size_t width, size_t height, TextureUsage usage);
    inline TextureUsage usage() { return usage_; }
    inline size_t width() { return width_; }
    inline size_t height() { return height_; }
};
#endif

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#include <unordered_map>
#include <algorithm>
#include "graphics.h"

typedef std::unordered_map<StorageMode, MTLStorageMode> StorageMap;

static inline MTLStorageMode storage(StorageMode mode) {
    static StorageMap map = {
        {Managed, MTLStorageModeManaged},
        {Private, MTLStorageModePrivate},
        {Shared, MTLStorageModeShared},
    };
    return map.at(mode);
}

static inline id <MTLDevice> getDevice() {
    static id <MTLDevice> device = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        device = MTLCreateSystemDefaultDevice();
    });
    return device;
}

#pragma mark MetalBuffer
void MetalBuffer::setBuffer() const {
    if (!RENDERER) { puts("No renderer!"); return; }
    Renderer* renderer = (__bridge Renderer*)(RENDERER);
    [renderer setBuffer:_bufferObject];
}

MetalBuffer::MetalBuffer(int size, StorageMode mode) : size_(size), mode_(mode) {
    id <MTLDevice> device = getDevice();
    id <MTLBuffer> buffer = [device newBufferWithLength:size_ options:storage(mode_)];
    _raw = [buffer contents];
    _dirty = false;
    _bufferObject = (void*)CFBridgingRetain(buffer);
}


MetalBuffer::MetalBuffer(void const* content, int size, StorageMode mode) : size_(size), mode_(mode) {
    id <MTLDevice> device = getDevice();
    id <MTLBuffer> buffer = [device newBufferWithBytes:content length:size options:storage(mode_)];
    if (mode_ != Private) _raw = [buffer contents];
    _dirty = false;
    _bufferObject = (void*)CFBridgingRetain(buffer);
}


MetalBuffer::~MetalBuffer() {
    if (_bufferObject) CFRelease(_bufferObject);
}


MetalBuffer::MetalBuffer(MetalBuffer &&other) noexcept : size_(other.size_), mode_(other.mode_), _dirty(other._dirty), _bufferObject(other._bufferObject), _raw(other._raw){
    other._bufferObject = nullptr;
    other._raw = nullptr;
    other.size_ = 0;
}


MetalBuffer& MetalBuffer::operator=(MetalBuffer &&other) noexcept {
    size_ = other.size_;
    mode_ = other.mode_;
    _dirty = other._dirty;
    _bufferObject = other._bufferObject;
    _raw = other._raw;
    other._bufferObject = nullptr;
    other._raw = nullptr;
    other.size_ = 0;
    return *this;
}


void MetalBuffer::commit() {
    if (mode_ == Managed && _dirty) {
        id <MTLBuffer> buffer = (__bridge id <MTLBuffer>)(_bufferObject);
        [buffer didModifyRange:NSMakeRange(0, size_)];
    }
}
#pragma mark MetalTexture

#endif /* __OBJC__ **/


#endif /* metal_api_h */
