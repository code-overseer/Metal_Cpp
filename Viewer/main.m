#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Cocoa/Cocoa.h>
#import "include/Cocoa_API.h"

int main(int argc, const char * argv[]) {
    launch_app();
    bool u = true;

    CFTimeInterval startTime = CACurrentMediaTime();
    while (u) {
        process_event(&u);
        if (CACurrentMediaTime() - startTime < 0.016667) continue;
        startTime = CACurrentMediaTime();
        update_view(&u);
    }
    return 0;
}

