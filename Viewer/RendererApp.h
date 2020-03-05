#ifndef RendererApp_h
#define RendererApp_h
#import <Cocoa/Cocoa.h>

@interface RendererApp : NSApplication

@property BOOL shouldKeepRunning;
- (void) setup;
- (void) update;


@end

#endif
