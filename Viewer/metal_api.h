#ifndef metal_api_h
#define metal_api_h
#ifdef __OBJC__
    #import <Metal/Metal.h>
    #import <MetalKit/MetalKit.h>
    #import <simd/simd.h>
    #import <MetalPerformanceShaders/MetalPerformanceShaders.h>
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

template<typename T>
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
    MetalBuffer(T* content, int size, StorageMode mode);
    virtual ~MetalBuffer();
    inline StorageMode mode() const { return mode_; }
    inline size_t size() const { return size_; }
    inline size_t count() const { return size_ / sizeof(T); }
    void commit();
    T get(int i) const;
    void set(int i, T input);
    void operate(std::function<void(T*,size_t)>& operation);
};

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

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#include <unordered_map>
#include <algorithm>

typedef std::unordered_map<StorageMode, MTLStorageMode> StorageMap;

static MTLStorageMode storage(StorageMode mode) {
    static StorageMap map = {
        {Managed, MTLStorageModeManaged},
        {Private, MTLStorageModePrivate},
        {Shared, MTLStorageModeShared},
    };
    return map.at(mode);
}

static id <MTLDevice> getDevice() {
    static id <MTLDevice> device = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        device = MTLCreateSystemDefaultDevice();
    });
    return device;
}

#pragma mark MetalBuffer
template<typename T>
MetalBuffer<T>::MetalBuffer(int count, StorageMode mode) : size_(count*sizeof(T)), mode_(mode) {
    id <MTLDevice> device = getDevice();
    id <MTLBuffer> buffer = [device newBufferWithLength:size_ options:storage(mode_)];
    _raw = [buffer contents];
    _dirty = false;
    _bufferObject = (void*)CFBridgingRetain(buffer);
}

template<typename T>
MetalBuffer<T>::MetalBuffer(T* content, int count, StorageMode mode) : size_(count*sizeof(T)), mode_(mode) {
    id <MTLDevice> device = getDevice();
    id <MTLBuffer> buffer = [device newBufferWithLength:size_ options:storage(mode_)];
    if (mode_ != Private) _raw = [buffer contents];
    _dirty = false;
    _bufferObject = (void*)CFBridgingRetain(buffer);
}

template<typename T>
MetalBuffer<T>::~MetalBuffer() {
    if (_bufferObject) CFRelease(_bufferObject);
}

template<typename T>
MetalBuffer<T>::MetalBuffer(MetalBuffer<T> &&other) noexcept : size_(other.size_), mode_(other.mode), _dirty(other.dirty), _bufferObject(other._bufferObject), _raw(other._raw){
    other._bufferObject = nullptr;
    other._raw = nullptr;
    other.size_ = 0;
}

template<typename T>
MetalBuffer<T>& MetalBuffer<T>::operator=(MetalBuffer<T> &&other) noexcept {
    size_ = other.size_;
    mode_ = other.mode_;
    _dirty = other._dirty;
    _bufferObject = other._bufferObject;
    _raw = other._raw;
    other._bufferObject = nullptr;
    other._raw = nullptr;
    other.size_ = 0;
    return this;
}

template<typename T>
inline T MetalBuffer<T>::get(int i) const {
    if (mode_ != Private && _raw && i < count()) {
        return reinterpret_cast<T*>(_raw)[i];
    }
    return T();
}

template<typename T>
inline void MetalBuffer<T>::set(int i, T input) {
    if (mode_ != Private && _raw && i < count()) {
        *reinterpret_cast<T*>(_raw)[i] = input;
        _dirty = true;
    }
}

template<typename T>
inline void MetalBuffer<T>::operate(std::function<void(T*,size_t)>& operation) {
    if (mode_ != Private && _raw) {
        _dirty = true;
        operation(reinterpret_cast<T*>(_raw), count());
    }
}

template<typename T>
void MetalBuffer<T>::commit() {
    if (mode_ == Managed && _dirty) {
        id <MTLBuffer> buffer = CFBridgingRelease(_bufferObject);
        _bufferObject = (void*)CFBridgingRetain(buffer);
        [buffer didModifyRange:NSMakeRange(0, size_)];
    }
}
#pragma mark MetalTexture

#endif /* __OBJC__ **/


#endif /* metal_api_h */
