#import "AppWindow.h"

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

@end
