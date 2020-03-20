#ifndef cocoa_api_h
#define cocoa_api_h

typedef struct {
    float scroll_x;
    float scroll_y;
    float magnify;
    float horizontal;
    float vertical;
    bool click_down[4];
    bool click_held[4];
    bool click_up[4];
} input_t;

extern input_t* INPUT;

void launch_app(void);
void update_view(bool* should_end);
void process_event(bool* should_end);
void clear_input(void);

#endif /* graphics_h */
