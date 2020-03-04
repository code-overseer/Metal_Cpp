#import "ViewerApp.h"
#import "AppWindow.h"
#import "Viewport.h"

@implementation ViewerApp
-(void) setup {
    [self finishLaunching];
    _shouldKeepRunning = true;
}

-(void) update {
    if (!_shouldKeepRunning) return;
    NSEvent* event = [self nextEventMatchingMask:NSEventMaskAny
                      untilDate:[NSDate distantFuture]
                         inMode:NSDefaultRunLoopMode
                        dequeue:YES];
    [self sendEvent:event];
    
//    AppView* v = [[self keyWindow] contentView];
//    [v callDraw];
    [self updateWindows];
}

-(void) terminate:(id)sender
{
    _shouldKeepRunning = false;
    for (NSWindow* window in self.windows) {
        [window close];
    }
}
@end

