#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <simd/simd.h>
#import "AppDelegate.h"
#import "RendererApp.h"
#import "graphics.h"

void launch_app() {
    RendererApp* app = [RendererApp sharedApplication];
    [app setDelegate:[[AppDelegate alloc] init]];
    
    [app setup];
}

void update_view(bool* shouldEnd) {
    RendererApp* app = [RendererApp sharedApplication];
    if (app && app.shouldKeepRunning) [app update];
    *shouldEnd = app.shouldKeepRunning;
}
