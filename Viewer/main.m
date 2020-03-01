#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "include/AppDelegate.h"
#import "include/ViewerApp.h"
#import "include/graphics.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        launch_app();
        
        while (update_view()) {}
    }
    return 0;
}

