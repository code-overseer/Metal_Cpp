#ifndef graphics_h
#define graphics_h

#ifdef __cplusplus
extern "C" {
#endif

    extern void* RENDERER;
    void launch_app(void);
    void update_view(bool* should_end);
    void* get_simd_float4x4(void);

#ifdef __cplusplus
}
#endif

#endif /* graphics_h */
