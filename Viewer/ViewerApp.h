#ifndef ViewApp_h
#define ViewApp_h
#import <Cocoa/Cocoa.h>

@interface ViewerApp : NSApplication

@property BOOL shouldKeepRunning;
- (void) setup;
- (void) update;


@end

#endif
