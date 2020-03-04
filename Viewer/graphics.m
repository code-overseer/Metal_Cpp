#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <simd/simd.h>
#import "AppDelegate.h"
#import "ViewerApp.h"
#import "graphics.h"

void launch_app() {
    ViewerApp* app = [ViewerApp sharedApplication];
    [app setDelegate:[[AppDelegate alloc] init]];
    
    [app setup];
}

void update_view(bool* shouldEnd) {
    ViewerApp* app = [ViewerApp sharedApplication];
    if (app && app.shouldKeepRunning) [app update];
    *shouldEnd = app.shouldKeepRunning;
}
