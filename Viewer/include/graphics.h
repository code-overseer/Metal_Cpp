#ifndef graphics_h
#define graphics_h

extern void* RENDERER;
void launch_app(void);
void update_view(bool* should_end);
void* get_simd_float4x4(void);


#endif /* graphics_h */
