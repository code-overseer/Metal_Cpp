#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "ViewerApp.h"
#import "graphics.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        launch_app();
        
        while (update_view()) {}
    }
    return 0;
}

