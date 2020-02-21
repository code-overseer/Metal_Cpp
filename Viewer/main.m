#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [[NSApplication sharedApplication] setDelegate:[AppDelegate new]];
        
        [NSApp run];
    }
    return 0;
}

