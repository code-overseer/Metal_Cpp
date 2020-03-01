#import <Foundation/Foundation.h>
#import "../include/AppDelegate.h"
#import "../include/AppView.h"

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    id menuNib =
    [[NSNib alloc] initWithNibNamed:@"MainMenu" bundle:[NSBundle mainBundle]];
    
    [menuNib instantiateWithOwner:NSApp topLevelObjects:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    
    id windowNib = [[NSNib alloc] initWithNibNamed:@"Window" bundle:[NSBundle mainBundle]];

    [windowNib instantiateWithOwner:NSApp topLevelObjects:nil];
    
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return true;
}


@end
