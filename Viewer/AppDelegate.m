#import <Foundation/Foundation.h>
#import "RendererApp.h"
#import "AppDelegate.h"
#import "AppWindow.h"
#include "ViewportDelegate.h"

@interface AppDelegate()
-(void)quit;
@end

@implementation AppDelegate
{
    MTKView* _view;
    ViewportDelegate* _renderer;
}

- (void) quit{
    [NSApp terminate:self];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {

    id quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit Viewer"
                                                 action:@selector(quit)
                                          keyEquivalent:@"q"];
    
    id appMenu = [[NSMenu alloc] init];
    [appMenu addItem:quitMenuItem];
    
    
    id appMenuItem = [[NSMenuItem alloc] init];
    [appMenuItem setSubmenu:appMenu];
    
    id mainMenu = [[NSMenu alloc] init];
    [mainMenu addItem:appMenuItem];
    
    [NSApp setMainMenu:mainMenu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    NSWindowStyleMask wmask = NSWindowStyleMaskClosable | NSWindowStyleMaskTitled | NSWindowStyleMaskResizable;
    AppWindow* window = [[AppWindow alloc] initWithContentRect:CGRectMake(120, 120, 720, 480)
                                                     styleMask:wmask
                                                       backing:NSBackingStoreBuffered
                                                         defer:NO];
    _view = [[MTKView alloc] init];
    [window setContentView:_view];
    _renderer = [[ViewportDelegate alloc] initWithMetalKitView:_view];
    
    
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app {
    return YES;
}



@end

