#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "AppWindow.h"
#include "ViewportDelegate.h"

@implementation AppDelegate
{
    id _zoomMonitor;
    MTKView* _view;
    ViewportDelegate* _renderer;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    id menuNib =
    [[NSNib alloc] initWithNibNamed:@"MainMenu" bundle:[NSBundle mainBundle]];
    
    [menuNib instantiateWithOwner:NSApp topLevelObjects:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    NSWindowStyleMask mask = NSWindowStyleMaskClosable | NSWindowStyleMaskTitled | NSWindowStyleMaskResizable;
    AppWindow* window = [[AppWindow alloc] initWithContentRect:CGRectMake(120, 120, 720, 480) styleMask:mask backing:NSBackingStoreBuffered defer:NO];
    _view =[[MTKView alloc] init];
    [window setContentView:_view];
    _renderer = [[ViewportDelegate alloc] initWithMetalKitView:_view];
    
    //    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskScrollWheel handler:^NSEvent * _Nullable(NSEvent * event) {
    //        float f = cam.zoom() + simd_clamp(-event.scrollingDeltaY/100, -1, 1);
    //        cam.zoom(simd_clamp(f, 0.25f, 200.f));
    //        return nil;
    //    }];
//    __block Camera cam = ((__bridge Renderer*)RENDERER).camera;
//    _zoomMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskMagnify handler:^NSEvent * _Nullable(NSEvent * event) {
//        float f = cam.zoom() + simd_clamp(-event.magnification*20, -1, 1);
//        cam.zoom(simd_clamp(f, 0.25f, 200.f));
//        return nil;
//    }];
}
-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app {
    return YES;
}



@end

