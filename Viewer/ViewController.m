#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "AppView.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppView* view = [[AppView alloc] init];
    [self.view addSubview:view];
    self.view.translatesAutoresizingMaskIntoConstraints = false;
    
    [self.view addConstraint:[NSLayoutConstraint
                          constraintWithItem:view
                          attribute:NSLayoutAttributeTrailing
                          relatedBy:NSLayoutRelationEqual
                          toItem:self.view
                          attribute:NSLayoutAttributeTrailing
                          multiplier:1.f
                          constant:0.f ]];

    [self.view addConstraint:[NSLayoutConstraint
                          constraintWithItem:view
                          attribute:NSLayoutAttributeLeading
                          relatedBy:NSLayoutRelationEqual
                          toItem:self.view
                          attribute:NSLayoutAttributeLeading
                          multiplier:1.f
                          constant:0.f ]];
    [self.view addConstraint:[NSLayoutConstraint
                          constraintWithItem:view
                          attribute:NSLayoutAttributeTop
                          relatedBy:NSLayoutRelationEqual
                          toItem:self.view
                          attribute:NSLayoutAttributeTop
                          multiplier:1.f
                          constant:0.f ]];
    [self.view addConstraint:[NSLayoutConstraint
                          constraintWithItem:view
                          attribute:NSLayoutAttributeBottom
                          relatedBy:NSLayoutRelationEqual
                          toItem:self.view
                          attribute:NSLayoutAttributeBottom
                          multiplier:1.f
                          constant:0.f ]];
    
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        constraint.active = true;
    }

}

@end
