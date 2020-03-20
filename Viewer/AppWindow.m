#import "AppWindow.h"
#import "include/Cocoa_API.h"
#import <simd/simd.h>

@implementation AppWindow
-(nonnull instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag];
    if (self) {
        [self setTitle:@"Viewer"];
        [self makeKeyAndOrderFront:nil];
        [self setReleasedWhenClosed:true];
    }
    return self;
}

-(void) mouseDown:(NSEvent *)event {
    switch (event.type) {
        case NSEventTypeLeftMouseDown: {
            INPUT->click_held[0] = true;
            INPUT->click_down[0] = true;
            break;
        }
        case NSEventTypeRightMouseDown: {
            INPUT->click_held[1] = true;
            INPUT->click_down[1] = true;
            break;
        }
        case NSEventTypeOtherMouseDown: {
            INPUT->click_held[2] = true;
            INPUT->click_down[2] = true;
            break;
        }
        default:
            break;
    }
}

-(void) mouseUp:(NSEvent *)event {
    switch (event.type) {
        case NSEventTypeLeftMouseUp: {
            INPUT->click_held[0] = false;
            INPUT->click_up[0] = true;
            break;
        }
        case NSEventTypeRightMouseUp: {
            INPUT->click_held[1] = false;
            INPUT->click_up[1] = true;
            break;
        }
        case NSEventTypeOtherMouseUp: {
            INPUT->click_held[2] = false;
            INPUT->click_up[2] = true;
            break;
        }
        default:
            break;
    }
    
}

-(void) keyDown:(NSEvent *)event {
    NSString* const character = [event charactersIgnoringModifiers];
    unichar const code = [character characterAtIndex:0];
    INPUT->horizontal -= (code == NSLeftArrowFunctionKey || code == 'a');
    INPUT->horizontal += (code == NSRightArrowFunctionKey || code == 'd' );
    INPUT->vertical -= (code == NSDownArrowFunctionKey || code == 's');
    INPUT->vertical += (code == NSUpArrowFunctionKey || code == 'w' );
    INPUT->horizontal = simd_clamp(INPUT->horizontal, -1.f, 1.f);
    INPUT->vertical = simd_clamp(INPUT->vertical, -1.f, 1.f);
}

-(void) keyUp:(NSEvent *)event {
    NSString* const character = [event charactersIgnoringModifiers];
    unichar const code = [character characterAtIndex:0];
    INPUT->horizontal += (code == NSLeftArrowFunctionKey || code == 'a');
    INPUT->horizontal -= (code == NSRightArrowFunctionKey || code == 'd' );
    INPUT->vertical += (code == NSDownArrowFunctionKey || code == 's');
    INPUT->vertical -= (code == NSUpArrowFunctionKey || code == 'w' );
    INPUT->horizontal = simd_clamp(INPUT->horizontal, -1.f, 1.f);
    INPUT->vertical = simd_clamp(INPUT->vertical, -1.f, 1.f);
}

-(void) magnifyWithEvent:(NSEvent *)event {
    INPUT->magnify = simd_clamp(-event.magnification*20, -1, 1);
}

-(void) scrollWheel:(NSEvent *)event {
    INPUT->scroll_y = simd_clamp(-(float)event.scrollingDeltaY/100.f, -1.f, 1.f);
    INPUT->scroll_x = simd_clamp(-(float)event.scrollingDeltaX/100.f, -1.f, 1.f);
}

@end
