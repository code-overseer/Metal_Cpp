#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Cocoa/Cocoa.h>
#import "include/graphics.h"

int main(int argc, const char * argv[]) {
    launch_app();
    bool u;
    update_view(&u);
    CFTimeInterval startTime = CACurrentMediaTime();
    while (u) {
        if (CACurrentMediaTime() - startTime < 0.016667) continue;
        startTime = CACurrentMediaTime();
        update_view(&u);
    }
    return 0;
}

