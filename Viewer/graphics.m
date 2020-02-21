#import "graphics.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "ViewerApp.h"


void launch_app() {
    ViewerApp* app = [ViewerApp sharedApplication];
    
    [app setDelegate:[AppDelegate new]];
    
    [app setup];
}

char update_view() {
    ViewerApp* app = [ViewerApp sharedApplication];
    [app update];
    return app.shouldKeepRunning ? 1 : 0;
}

