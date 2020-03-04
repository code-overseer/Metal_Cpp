#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Viewport.h"
#import "AppWindow.h"
#include "Renderer.h"
#include "include/graphics.h"

@implementation AppDelegate
{
    id _zoomMonitor;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    id menuNib =
    [[NSNib alloc] initWithNibNamed:@"MainMenu" bundle:[NSBundle mainBundle]];
    
    [menuNib instantiateWithOwner:NSApp topLevelObjects:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    
    //    id windowNib = [[NSNib alloc] initWithNibNamed:@"Window" bundle:[NSBundle mainBundle]];
    NSWindowStyleMask mask = NSWindowStyleMaskClosable | NSWindowStyleMaskTitled | NSWindowStyleMaskResizable;
    //    [windowNib instantiateWithOwner:NSApp topLevelObjects:nil];
    AppWindow* window = [[AppWindow alloc] initWithContentRect:CGRectMake(120, 120, 720, 480) styleMask:mask backing:NSBackingStoreBuffered defer:NO];
    window.contentView = [[Viewport alloc] init];
    [NSApp addWindowsItem:window title:@"Viewer" filename:false];
    

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
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return true;
}



@end

