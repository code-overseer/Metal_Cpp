#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "../include/graphics.h"
#import "../include/AppDelegate.h"
#import "../include/ViewerApp.h"


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

