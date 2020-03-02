#import "../include/AppWindow.h"
#import "../include/AppView.h"

@implementation AppWindow
-(nonnull instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag];
    if (self) {
        self.contentView =[[AppView alloc] init];
        [self setTitle:@"Viewer"];
        [self makeKeyAndOrderFront:nil];
//        [self setReleasedWhenClosed:true];
    }
    return self;
}

-(void)awakeFromNib{
    puts("Awakened from NIB");
    self.contentView = [[AppView alloc] init];
}

@end
