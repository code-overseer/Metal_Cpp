#import "Viewport.h"
#import "Renderer.h"
#include <functional>

@interface Viewport()

-(void)setupMetal;

@end

@implementation Viewport
{
    MTKView* _view;
    id<MTKViewDelegate> _renderer;
}

-(nonnull instancetype)init
{
    self = [super initWithFrame:NSZeroRect];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = false;
        [self setupMetal];
    }
    return self;
}

-(void)draw {
    [_view draw];
}

-(void)setupMetal
{
    _view = [[MTKView alloc] init];
    [self addSubview:_view];
    _view.translatesAutoresizingMaskIntoConstraints = false;
    [_view setPreferredFramesPerSecond:60];
    
//    [self addConstraint:[NSLayoutConstraint
//                         constraintWithItem:_view
//                         attribute:NSLayoutAttributeTrailing
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:self
//                         attribute:NSLayoutAttributeTrailing
//                         multiplier:1.f
//                         constant:0.f ]];
//    [self addConstraint:[NSLayoutConstraint
//                         constraintWithItem:_view
//                         attribute:NSLayoutAttributeLeading
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:self
//                         attribute:NSLayoutAttributeLeading
//                         multiplier:1.f
//                         constant:0.f ]];
//    [self addConstraint:[NSLayoutConstraint
//                         constraintWithItem:_view
//                         attribute:NSLayoutAttributeTop
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:self
//                         attribute:NSLayoutAttributeTop
//                         multiplier:1.f
//                         constant:0.f ]];
//    [self addConstraint:[NSLayoutConstraint
//                         constraintWithItem:_view
//                         attribute:NSLayoutAttributeBottom
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:self
//                         attribute:NSLayoutAttributeBottom
//                         multiplier:1.f
//                         constant:0.f ]];
//
//    for (NSLayoutConstraint *constraint in self.constraints) {
//        constraint.active = true;
//    }
    _view.device = MTLCreateSystemDefaultDevice();
    _view.enableSetNeedsDisplay = true;
    
    _renderer = [[Renderer alloc] initWithMetalKitView:_view];
    _view.delegate = _renderer;
    
    _view.needsDisplay = true;
    
}

@end

