#import "../include/AppWindow.h"
#import "../include/AppView.h"

@implementation AppWindow

-(void)awakeFromNib{
    self.contentView = [[AppView alloc] init];
}

@end
