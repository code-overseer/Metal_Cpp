#import "RendererApp.h"
#import <MetalKit/MetalKit.h>
#import "include/Metal_API.h"

@interface RendererApp()
-(void) processNextEvent;
@end

@implementation RendererApp
{
    BOOL _startup;
    NSEventMask _mask;
}
-(void) processNextEvent {
    @autoreleasepool {
        NSEvent* event = [self nextEventMatchingMask:_mask
                                       untilDate:[NSDate distantPast]
                                          inMode:NSDefaultRunLoopMode
                                         dequeue:YES];
        if(event) [self sendEvent:event];
    }
}

-(void) setup {
    @autoreleasepool {
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

