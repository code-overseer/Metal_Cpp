#import "AppWindow.h"
#import "Viewport.h"

@implementation AppWindow
-(nonnull instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag];
    if (self) {
        [self setTitle:@"Viewer"];
        [self makeKeyAndOrderFront:nil];
    }
    return self;
}

@end
