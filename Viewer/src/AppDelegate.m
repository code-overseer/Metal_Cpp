#import <Foundation/Foundation.h>
#import "../include/AppDelegate.h"
#import "../include/AppView.h"
#import "../include/AppWindow.h"

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    id menuNib =
    [[NSNib alloc] initWithNibNamed:@"MainMenu" bundle:[NSBundle mainBundle]];
    
    [menuNib instantiateWithOwner:NSApp topLevelObjects:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    
//    id windowNib = [[NSNib alloc] initWithNibNamed:@"Window" bundle:[NSBundle mainBundle]];
    NSWindowStyleMask mask = NSWindowStyleMaskClosable | NSWindowStyleMaskTitled | NSWindowStyleMaskResizable;
//    [windowNib instantiateWithOwner:NSApp topLevelObjects:nil];
    id window = [[AppWindow alloc] initWithContentRect:CGRectMake(120, 120, 720, 480) styleMask:mask backing:NSBackingStoreBuffered defer:NO];
    
    [NSApp addWindowsItem:window title:@"Viewer" filename:false];
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return true;
}



@end
