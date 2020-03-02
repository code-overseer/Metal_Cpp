#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Cocoa/Cocoa.h>
#import "include/AppDelegate.h"
#import "include/ViewerApp.h"
#import "include/graphics.h"

int main(int argc, const char * argv[]) {
    launch_app();
    bool u = update_view();
    CFTimeInterval startTime = CACurrentMediaTime();
    while (u) {
        if (CACurrentMediaTime() - startTime < 0.016667) continue;
        startTime = CACurrentMediaTime();
        u = update_view();
    }
    return 0;
}

