#import "RendererApp.h"
#import "AppWindow.h"
#import <MetalKit/MetalKit.h>

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
    if (_startup && !self.windows.count) _shouldKeepRunning = NO;
    if (!_shouldKeepRunning) return;
    
    [self processNextEvent];
    [(MTKView*)[[self keyWindow] contentView] draw];
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

