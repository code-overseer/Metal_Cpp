#import "RendererApp.h"
#import <MetalKit/MetalKit.h>
#import "include/Metal_API.h"


@implementation RendererApp
{
    BOOL _startup;
    NSEventMask _mask;
}

-(void) processNextEvent {
    if (_startup && !self.windows.count) [self terminate:nil];
    if (!_shouldKeepRunning) return;
    NSEvent* event = [self nextEventMatchingMask:NSEventMaskAny
                                       untilDate:[NSDate distantPast]
                                          inMode:NSDefaultRunLoopMode
                                         dequeue:YES];
    if(event) [self sendEvent:event];
}

-(void) setup {
    [self finishLaunching];
    _shouldKeepRunning = true;
    _mask = NSEventMaskAppKitDefined | NSEventMaskApplicationDefined | NSEventMaskSystemDefined;
    _mask |= NSEventMaskMouseMoved | NSEventMaskMouseExited | NSEventMaskMouseEntered;
    _mask |= NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDown | NSEventMaskMagnify;
    _mask |= NSEventMaskScrollWheel | NSEventMaskCursorUpdate | NSEventMaskKeyUp | NSEventMaskKeyDown;
    NSEvent* event = [self nextEventMatchingMask:NSEventMaskAny
                                       untilDate:[NSDate distantFuture]
                                          inMode:NSDefaultRunLoopMode
                                         dequeue:YES];
    [self sendEvent:event];
    _startup = YES;
}

-(void) updateView {
    if (_startup && !self.windows.count) [self terminate:nil];
    if (!_shouldKeepRunning) return;
    
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

