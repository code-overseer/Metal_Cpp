#import "AppWindow.h"
#import "AppView.h"

@implementation AppWindow

-(void)awakeFromNib{
    self.contentView = [[AppView alloc] init];
}

@end
