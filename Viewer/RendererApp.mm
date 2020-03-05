#import "RendererApp.h"
#import <MetalKit/MetalKit.h>
#import "include/Metal_API.h"

@interface RendererApp()
-(void) processNextEvent;
@end

@implementation RendererApp
{
    BOOL _startup;
}
-(void) processNextEvent {
    NSEvent* event = [self nextEventMatchingMask:NSEventMaskAny
                                       untilDate:[NSDate distantFuture]
                                          inMode:NSDefaultRunLoopMode
                                         dequeue:YES];
    [self sendEvent:event];
}

-(void) setup {
    [self finishLaunching];
    _shouldKeepRunning = true;
    [self processNextEvent]; // to start up window
    _startup = YES;
}

-(void) update {
    if (_startup && !self.windows.count) [self terminate:nil];
    if (!_shouldKeepRunning) return;
    
    [self processNextEvent];
    [(MTKView*)[[self keyWindow] contentView] draw];
    [self updateWindows];
}

-(void) terminate:(id)sender
{
    _shouldKeepRunning = false;
    mtl_cpp::Metal_API::terminateContext();
    for (NSWindow* window in self.windows) {
        [window close];
    }
}
@end

