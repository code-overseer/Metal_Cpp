
#import "ViewerApp.h"


@implementation ViewerApp
-(void) setup {
    [self finishLaunching];
    _shouldKeepRunning = true;
}

-(void) update {
    @autoreleasepool {
        if (!_shouldKeepRunning) return;
            NSEvent* event =
        [self
         nextEventMatchingMask:NSEventMaskAny
         untilDate:[NSDate distantFuture]
         inMode:NSDefaultRunLoopMode
         dequeue:YES];
        [self sendEvent:event];
        [self updateWindows];
    }
}

-(void) terminate:(id)sender
{
    _shouldKeepRunning = false;
    for (NSWindow* window in self.windows) {
        [window close];
    }
}
@end

